import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arborio/tree_view.dart';
import 'package:oee_mobile/l10n/app_localizations.dart';
import '../models/oee_entity.dart';
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
    // re-read entities from the database
    ref.invalidate(EntityController.entitiesProvider);

    // notify user
    if (mounted) {
      UIUtils.showSnackBar(
          context, AppLocalizations.of(context)!.refreshedEntities);
    }
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
          const Image(image: AssetImage('assets/icons/Point85_48x48.png')),
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
        onSelectionChanged: (node) {
          selectedNode = node;
          _entitySelected(node);
        },
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
                Expanded(
                  child: Text(
                    node.data.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
    final asynchEntities = ref.watch(EntityController.entitiesProvider);

    void showSettings() {
      _homeScaffoldKey.currentState?.showBottomSheet((context) {
        return const SettingsPage();
      });
    }

    void onBottomNavBarItemTapped(int index) {
      setState(() {
        _bottomNavBarIndex = index;
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;

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
      });
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
          if (entities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.business,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.errNoEntities,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.errConnection,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            );
          }

          List<TreeNode<OeeEntityNode>> treeNodes =
              EntityController.buildTreeNodes(entities);
          return RefreshIndicator(
            onRefresh: () async {
              _refreshEntities();
            },
            child: _buildEntityTree(treeNodes),
          );
        },
        error: (err, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.errFailedLoadingEntities,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.red,
                    ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshEntities,
                child: Text(AppLocalizations.of(context)!.retry),
              ),
            ],
          ),
        ),
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.loading),
            ],
          ),
        ),
      ),
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
    final entityName = node.data.name;

    if (node.data.level == EntityLevel.equipment) {
      // get current status
      ref
          .read(EntityController.equipmentStatusProvider(entityName).future)
          .then(
        (status) {
          if (!mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => EquipmentEventPage(
                equipment: selectedNode!.data,
                status: status,
              ),
            ),
          );
        },
        onError: (error) {
          if (!mounted) return;

          final response = EquipmentEventResponse.fromResponseBody('$error');
          UIUtils.showErrorDialog(context, response.errorText);
        },
      );
    }
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}
