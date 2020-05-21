import 'package:flutter/material.dart';
import 'oee_model.dart';
import 'oee_controller.dart';
import 'dynamic_treeview.dart';
import 'oee_services.dart';

class ReasonPage extends StatefulWidget {
  final String title = 'Choose a Reason';
  final bool isAvailability;

  ReasonPage(this.isAvailability);

  @override
  _ReasonPageState createState() => _ReasonPageState();
}

class _ReasonPageState extends State<ReasonPage> {
  OeeReason reason;

  Future<ReasonList> refreshReasons() async {
    return EquipmentPageController.fetchReasons();
  }

  DynamicTreeView createReasonView(ReasonList reasonList) {
    return DynamicTreeView(
      data: EquipmentPageController.fromReasonList(reasonList),
      config: Config(
          parentTextStyle:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          rootId: HierarchicalDataModel.ROOT_ID,
          parentPaddingEdgeInsets:
              EdgeInsets.only(left: 16, top: 0, bottom: 0)),
      onTap: (reasonMap) {
        reason = ReasonDataModel.getReason(reasonMap);
      },
      width: MediaQuery.of(context).size.width,
    );
  }

  Future<bool> _onBackPressed() {
    // cache reason in execution service
    if (widget.isAvailability) {
      OeeExecutionService.getInstance.availabilityReason = reason;
    } else {
      OeeExecutionService.getInstance.productionReason = reason;
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: FutureBuilder<ReasonList>(
              future: refreshReasons(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return createReasonView(snapshot.data);
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return Center(child: CircularProgressIndicator());
              }),
        ));
  }
}
