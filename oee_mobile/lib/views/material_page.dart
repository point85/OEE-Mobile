import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arborio/tree_view.dart';
import 'package:oee_mobile/l10n/app_localizations.dart';
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
    if (!mounted) return; // Check if widget is still mounted

    final node = selectedNode;
    if (node != null) {
      // Check if it's a production material (has category)
      final isProductionMaterial = node.data.category.isNotEmpty;

      setState(() {
        if (isProductionMaterial) {
          _appBarTitle = node.data.toString();
        } else {
          // For non-production materials, show equipment name or default title
          final localizations = AppLocalizations.of(context);
          _appBarTitle = localizations?.materialTitle ?? 'Materials';
        }
      });
    }
  }

  void _refreshMaterials() {
    if (!mounted) return; // Check if widget is still mounted

    // re-read materials from the database
    ref.invalidate(EntityController.equipmentProvider(widget.equipment));

    // notify user
    final localizations = AppLocalizations.of(context);
    if (localizations != null) {
      UIUtils.showSnackBar(context, localizations.refreshedMaterials);
    }
  }

  void _onSelectionChanged(TreeNode<OeeMaterialNode> node) {
    selectedNode = node;
    _updateAppBar();
  }

  TreeView<OeeMaterialNode> _buildMaterialTree(
          List<TreeNode<OeeMaterialNode>> materialNodes) =>
      TreeView(
        onSelectionChanged: _onSelectionChanged,
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
          NodeType.child => InkWell(
              onTap: () => select(node),
              child: Container(
                margin: TreeUtils.edgeInsets,
                decoration: TreeUtils.buildBoxDecoration(context, isSelected),
                child: TreeUtils.buildTreeRow(
                    node.data.name, node.data.description, Icons.group_work),
              ),
            ),
          NodeType.parent => Row(
              children: [
                RotationTransition(
                  turns: expansionAnimation,
                  child: TreeUtils.folderIcon,
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
        nodes: materialNodes,
        expanderBuilder: (context, node, animationValue) => RotationTransition(
          turns: animationValue,
          child: TreeUtils.chevronIcon,
        ),
      );

  String _getAppBarTitle(BuildContext context) {
    if (_appBarTitle != null) {
      return _appBarTitle!;
    }

    final localizations = AppLocalizations.of(context);
    return localizations?.materialTitle ?? 'Materials'; // Fallback title
  }

  @override
  Widget build(BuildContext context) {
    final asynchEquipment =
        ref.watch(EntityController.equipmentProvider(widget.equipment));

    return Scaffold(
        appBar: AppBar(
            title: Center(
              child: Column(
                children: [
                  Text(
                    _getAppBarTitle(context),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: UIUtils.getBackIcon(context),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            backgroundColor: UIUtils.getAppBarBackground(context)),
        floatingActionButton: FloatingActionButton(
          onPressed: _refreshMaterials,
          child: const Icon(Icons.refresh),
        ),
        body: asynchEquipment.when(
          data: (equipment) {
            final treeNodes = MaterialController.buildTreeNodes(
                equipment.getProducedMaterials());

            return Stack(
              children: [
                _buildMaterialTree(treeNodes),
              ],
            );
          },
          error: (err, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading materials',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Equipment: ${widget.equipment}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshMaterials,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        ));
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}
