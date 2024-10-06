import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arborio/tree_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    setState(() {
      _appBarTitle = selectedNode!.data.toString();
    });
  }

  void _refreshReasons() {
    // re-read reasons from the database
    // ignore: unused_local_variable
    final value = ref.refresh(ReasonController.reasonProvider);

    // notify user
    UIUtils.showSnackBar(
        context, AppLocalizations.of(context)!.refreshedReasons);
  }

  TreeView<OeeReasonNode> _buildReasonTree(
          List<TreeNode<OeeReasonNode>> reasonNodes) =>
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
                    node.data.name, node.data.description, Icons.edit),
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
        nodes: reasonNodes,
        expanderBuilder: (context, node, animationValue) => RotationTransition(
          turns: animationValue,
          child: TreeUtils.chevronIcon,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final asynchReasons = ref.watch(ReasonController.reasonProvider);
    _appBarTitle ??= AppLocalizations.of(context)!.reasonTitle;

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
            _refreshReasons();
          },
          child: const Icon(Icons.refresh),
        ),
        body: asynchReasons.when(
          data: (reasons) {
            List<TreeNode<OeeReasonNode>> treeNodes =
                ReasonController.buildTreeNodes(reasons);

            return Stack(
              children: [
                _buildReasonTree(treeNodes),
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
