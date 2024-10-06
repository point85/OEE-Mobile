import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arborio/tree_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/oee_entity.dart';
import '../models/oee_equipment_status.dart';
import '../models/oee_event.dart';
import '../controllers/entity_controller.dart';
import 'common.dart';
import 'tree_nodes.dart';
import 'settings_page.dart';
import 'equipment_event_page.dart';

// home page widget
class OeeEntityPage extends ConsumerStatefulWidget {
  const OeeEntityPage({super.key});

  @override
  ConsumerState<OeeEntityPage> createState() => _OeeEntityPageState();
}

class _OeeEntityPageState extends ConsumerState<OeeEntityPage> {
  // selected entity in the tree
  TreeNode<OeeEntityNode>? selectedNode;

  final treeViewKey = const TreeViewKey<OeeEntityNode>();
  final _homeScaffoldKey = GlobalKey<ScaffoldState>();

  // nav bar button index
  int _bottomNavBarIndex = 0;

  void _refreshEntities() {
    // refresh server URL
    EntityController.setServerUrl();

    // re-read entities from the database
    // ignore: unused_local_variable
    final value = ref.refresh(EntityController.entityProvider);

    // notify user
    UIUtils.showSnackBar(
        context, AppLocalizations.of(context)!.refreshedEntities);
  }

// about dialog
  void _showAboutDialog() {
    final TextStyle? textStyle = Theme.of(context).textTheme.bodyMedium;
    final List<Widget> aboutBoxChildren = <Widget>[
      const SizedBox(height: 24),
      RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
                style: textStyle,
                text: AppLocalizations.of(context)!.homeAboutText),
          ],
        ),
      ),
    ];

    // flutter About dialog
    showAboutDialog(
      context: context,
      applicationIcon:
          const Image(image: AssetImage('assets/icons/Point85_48.png')),
      applicationName: AppLocalizations.of(context)!.appName,
      applicationVersion: AppLocalizations.of(context)!.appVersion,
      children: aboutBoxChildren,
    );
  }

  // build the tree view from the list of parent/child nodes
  TreeView<OeeEntityNode> _buildEntityTree(
          List<TreeNode<OeeEntityNode>> entityNodes) =>
      TreeView(
        indentation: const SizedBox(width: 8),
        onSelectionChanged: (node) =>
            {selectedNode = node, _entitySelected(node)},
        key: treeViewKey,
        animationDuration: TreeUtils.animationDuration,
        animationCurve: Curves.easeInOut,
        builder: (
          context,
          node,
          isSelected,
          expansionAnimation,
          select,
        ) =>
            switch (node.data.nodeType) {
          (NodeType.child) => InkWell(
              onTap: () => select(node),
              child: Container(
                margin: TreeUtils.edgeInsets,
                decoration: TreeUtils.buildBoxDecoration(context, isSelected),
                child: TreeUtils.buildTreeRow(
                    node.data.name, node.data.description, node.data.getIcon()),
              ),
            ),
          (NodeType.parent) => Row(
              children: [
                RotationTransition(
                  turns: expansionAnimation,
                  child: Icon(node.data.getIcon()),
                ),
                TreeUtils.parentPadding,
                Text(node.data.name),
              ],
            ),
        },
        nodes: entityNodes,
        expanderBuilder: (context, node, animationValue) => RotationTransition(
          turns: animationValue,
          child: TreeUtils.chevronIcon,
        ),
      );

  @override
  Widget build(BuildContext context) {
    // entity provider
    final asynchEntities = ref.watch(EntityController.entityProvider);

    showSettings() {
      _homeScaffoldKey.currentState!.showBottomSheet((context) {
        return const SettingsPage();
      });
    }

    void onBottomNavBarItemTapped(int index) {
      setState(() {
        _bottomNavBarIndex = index;
      });

      switch (index) {
        case 0:
          // settings
          showSettings();
          break;
        case 1:
          // refresh page
          _refreshEntities();
          break;
        case 2:
          // about dialog
          _showAboutDialog();
          break;
      }
    }

    return Scaffold(
      key: _homeScaffoldKey,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.homePageTitle,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: asynchEntities.when(
          data: (entities) {
            List<TreeNode<OeeEntityNode>> treeNodes =
                EntityController.buildTreeNodes(entities);
            return Stack(
              children: [
                _buildEntityTree(treeNodes),
              ],
            );
          },
          error: (err, s) => Text(err.toString()),
          loading: () => const Center(
                child: CircularProgressIndicator(),
              )),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: AppLocalizations.of(context)!.homeSettings,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.refresh),
            label: AppLocalizations.of(context)!.homeRefresh,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.info),
            label: AppLocalizations.of(context)!.homeAbout,
          ),
        ],
        currentIndex: _bottomNavBarIndex,
        selectedItemColor: Colors.amber[800],
        onTap: onBottomNavBarItemTapped,
        backgroundColor: const Color.fromARGB(255, 235, 235, 235),
      ),
    );
  }

  // show equipment event page
  void _entitySelected(TreeNode<OeeEntityNode> node) {
    String entityName = node.data.name;

    if (node.data.level == EntityLevel.equipment) {
      // get current status
      Future<OeeEquipmentStatus> future =
          EntityController.getEquipmentStatus(entityName);

      future.then((status) {
        if (!mounted) return;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (ctx) => EquipmentEventPage(
                      equipment: selectedNode!.data,
                      status: status,
                    )));
      }, onError: (error) {
        EquipmentEventResponse response =
            EquipmentEventResponse.fromResponseBody('$error');

        if (!mounted) return;

        UIUtils.showErrorDialog(context, response.errorText);
      });
    }
  }
}
