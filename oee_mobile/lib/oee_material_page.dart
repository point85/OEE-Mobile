import 'package:flutter/material.dart';
import 'oee_model.dart';
import 'oee_controller.dart';
import 'oee_localization.dart';
import 'dynamic_treeview.dart';

// manages OEE materials
class OeeMaterialPage extends StatefulWidget {
  OeeMaterialPage({Key key}) : super(key: key);

  @override
  OeeMaterialPageState createState() => OeeMaterialPageState();
}

class OeeMaterialPageState extends State<OeeMaterialPage> {
  // selected material
  OeeMaterial material;

  var _appBarTitle;

  Future<MaterialList> refreshMaterials() async {
    return EquipmentPageController.fetchMaterials();
  }

  DynamicTreeView createMaterialView(MaterialList materialList) {
    return DynamicTreeView(
      data: EquipmentPageController.fromMaterialList(materialList),
      config: Config(
          parentTextStyle:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          rootId: HierarchicalDataModel.ROOT_ID,
          parentPaddingEdgeInsets:
              EdgeInsets.only(left: 16, top: 0, bottom: 0)),
      onTap: (materialMap) {
        material = MaterialDataModel.getMaterial(materialMap);

        // update the title
        _updateAppBar();
      },
      width: MediaQuery.of(context).size.width,
    );
  }

  Future<bool> _onBackPressed() {
    return Future.value(true);
  }

  void _updateAppBar() {
    if (material.category == null) {
      // it is a category
      return;
    }

    setState(() {
      _appBarTitle = Text(material.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_appBarTitle == null) {
      _appBarTitle =
          Text(AppLocalizations.of(context).translate('material.title'));
    }

    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          appBar: AppBar(
            title: _appBarTitle,
          ),
          body: FutureBuilder<MaterialList>(
              future: refreshMaterials(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return createMaterialView(snapshot.data);
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return Center(child: CircularProgressIndicator());
              }),
        ));
  }
}
