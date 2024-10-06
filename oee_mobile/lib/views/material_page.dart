import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arborio/tree_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:oee_mobile/controllers/entity_controller.dart';
import '../controllers/material_controller.dart';
import 'tree_nodes.dart';
import 'common.dart';

// manages OEE materials
class OeeMaterialPage extends ConsumerStatefulWidget {
  const OeeMaterialPage({super.key, required this.equipment});

  // equipment
  final String equipment;

  @override
  ConsumerState<OeeMaterialPage> createState() => OeeMaterialPageState();
}

class OeeMaterialPageState extends ConsumerState<OeeMaterialPage> {
  TreeNode<OeeMaterialNode>? selectedNode;

  final treeViewKey = const TreeViewKey<OeeMaterialNode>();

  String? _appBarTitle;

  void _updateAppBar() {
    if (selectedNode!.data.category.isNotEmpty) {
      // it is a production material
      setState(() {
        _appBarTitle = selectedNode!.data.toString();
      });
    }
  }

  void _refreshMaterials() {
    // re-read materials from the database
    // ignore: unused_local_variable
    final value =
        ref.refresh(EntityController.equipmentProvider(widget.equipment));

    // notify user
    UIUtils.showSnackBar(
        context, AppLocalizations.of(context)!.refreshedMaterials);
  }

  TreeView<OeeMaterialNode> _buildMaterialTree(
          List<TreeNode<OeeMaterialNode>> materialNodes) =>
      TreeView(
        onSelectionChanged: (node) => {selectedNode = node, _updateAppBar()},
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
                    node.data.name, node.data.description, Icons.group_work),
              ),
            ),
          (NodeType.parent) => Row(
              children: [
                RotationTransition(
                  turns: expansionAnimation,
                  child: TreeUtils.folderIcon,
                ),
                TreeUtils.parentPadding,
                Text(node.data.name),
              ],
            ),
        },
        nodes: materialNodes,
        expanderBuilder: (context, node, animationValue) => RotationTransition(
          turns: animationValue,
          child: TreeUtils.chevronIcon,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final asynchEquipment =
        ref.watch(EntityController.equipmentProvider(widget.equipment));
    _appBarTitle ??= AppLocalizations.of(context)!.materialTitle;

    return Scaffold(
        appBar: AppBar(
            title: Center(
              child: Column(
                children: [
                  Text(_appBarTitle!,
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
            leading: IconButton(
              icon: UIUtils.backIcon,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            backgroundColor: UIUtils.appBarBackground),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _refreshMaterials();
          },
          child: const Icon(Icons.refresh),
        ),
        body: asynchEquipment.when(
          data: (equipment) {
            List<TreeNode<OeeMaterialNode>> treeNodes =
                MaterialController.buildTreeNodes(
                    equipment.getProducedMaterials());

            return Stack(
              children: [
                _buildMaterialTree(treeNodes),
              ],
            );
          },
          error: (err, s) => Text(err.toString()),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        ));
  }
}
