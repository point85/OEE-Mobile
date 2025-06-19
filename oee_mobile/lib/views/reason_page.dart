import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arborio/tree_view.dart';
import 'package:oee_mobile/l10n/app_localizations.dart';
import '../controllers/reason_controller.dart';
import 'tree_nodes.dart';
import 'common.dart';

// manages OEE reasons
class OeeReasonPage extends ConsumerStatefulWidget {
  const OeeReasonPage({super.key});

  @override
  ConsumerState<OeeReasonPage> createState() => OeeReasonPageState();
}

class OeeReasonPageState extends ConsumerState<OeeReasonPage> {
  TreeNode<OeeReasonNode>? selectedNode;

  final treeViewKey = const TreeViewKey<OeeReasonNode>();

  String? _appBarTitle;

  void _updateAppBar() {
    if (!mounted) return; // Check if widget is still mounted

    final node = selectedNode;
    if (node != null) {
      setState(() {
        _appBarTitle = node.data.toString();
      });
    }
  }

  void _refreshReasons() {
    if (!mounted) return; // Check if widget is still mounted

    // re-read reasons from the database
    ref.invalidate(ReasonController.reasonProvider);

    // notify user
    final localizations = AppLocalizations.of(context);
    if (localizations != null) {
      UIUtils.showSnackBar(context, localizations.refreshedReasons);
    }
  }

  void _onSelectionChanged(TreeNode<OeeReasonNode> node) {
    selectedNode = node;
    _updateAppBar();
  }

  TreeView<OeeReasonNode> _buildReasonTree(
          List<TreeNode<OeeReasonNode>> reasonNodes) =>
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
                    node.data.name, node.data.description, Icons.edit),
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
        nodes: reasonNodes,
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
    return localizations?.reasonTitle ?? 'Reasons'; // Fallback title
  }

  @override
  Widget build(BuildContext context) {
    final asynchReasons = ref.watch(ReasonController.reasonProvider);

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
          onPressed: _refreshReasons,
          child: const Icon(Icons.refresh),
        ),
        body: asynchReasons.when(
          data: (reasons) {
            final treeNodes = ReasonController.buildTreeNodes(reasons);

            return Stack(
              children: [
                _buildReasonTree(treeNodes),
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
                  'Error loading reasons',
                  style: Theme.of(context).textTheme.headlineSmall,
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
                  onPressed: _refreshReasons,
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
