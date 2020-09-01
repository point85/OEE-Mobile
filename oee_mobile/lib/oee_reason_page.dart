import 'package:flutter/material.dart';
import 'oee_model.dart';
import 'oee_controller.dart';
import 'oee_localization.dart';
import 'dynamic_treeview.dart';

// manages OEE reasons
class OeeReasonPage extends StatefulWidget {
  OeeReasonPage({Key key}) : super(key: key);

  @override
  OeeReasonPageState createState() => OeeReasonPageState();
}

class OeeReasonPageState extends State<OeeReasonPage> {
  OeeReason reason;

  var _appBarTitle;

  Future<ReasonList> refreshReasons() async {
    return EquipmentPageController.fetchReasons();
  }

  void _updateAppBar() {
    setState(() {
      _appBarTitle = Text(reason.toString());
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
        reason = ReasonDataModel.getReason(reasonMap);

        // update the title
        _updateAppBar();
      },
      width: MediaQuery.of(context).size.width,
    );
  }

  Future<bool> _onBackPressed() {
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    if (_appBarTitle == null) {
      _appBarTitle =
          Text(AppLocalizations.of(context).translate('reason.title'));
    }

    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          appBar: AppBar(
            title: _appBarTitle,
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
