import 'package:flutter/material.dart';
import 'oee_model.dart';
import 'oee_controller.dart';
import 'dynamic_treeview.dart';
import 'oee_services.dart';

class ReasonPage extends StatefulWidget {
  final String title = 'Choose a Reason';

  //ReasonPage({Key key, this.title}) : super(key: key);
  ReasonPage();


  //ReasonPage(this.reason, {Key key}):
  //    super(key: key);

  @override
  _ReasonPageState createState() => _ReasonPageState();
}

class _ReasonPageState extends State<ReasonPage> {
  OeeReason reason;
  Map _reasonData;
  Future<ReasonList> reasonListFuture;
  List<ReasonDataModel> reasonData;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<ReasonList> refreshReasons() async {
    return EquipmentPageController.fetchReasons();
  }

  void _handleReason(Map value) {
    setState(() {
      _reasonData = value;
    });
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
        reason = reasonMap['extra']['reason'];
      },
      width: MediaQuery.of(context).size.width,
    );
  }

  Future<bool> _onBackPressed() {
    OeeExecutionService.getInstance.reason = this.reason;
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          key: _scaffoldKey,
          // top app bar
          appBar: AppBar(
            title: Text(widget.title),
          ),

          body: FutureBuilder<ReasonList>(
              future: refreshReasons(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  ReasonList reasonList = snapshot.data;
                  return createReasonView(reasonList);
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return CircularProgressIndicator();
              }),
        ));
  }
}
