import 'package:flutter/material.dart';
import 'oee_model.dart';
import 'oee_controller.dart';
import 'oee_localization.dart';
import 'dynamic_treeview.dart';

// manages OEE materials
class MaterialPage extends StatefulWidget {
  MaterialPage({Key key}) : super(key: key);

  @override
  MaterialPageState createState() => MaterialPageState();
}

class MaterialPageState extends State<MaterialPage> {
  // selected material
  OeeMaterial material;

  var _appBarTitle = Text('');

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
        OeeMaterial selectedMaterial =
            MaterialDataModel.getMaterial(materialMap);
        _updateAppBar(selectedMaterial);
      },
      width: MediaQuery.of(context).size.width,
    );
  }

  Future<bool> _onBackPressed() {
    return Future.value(true);
  }

  void _updateAppBar(OeeMaterial material) {
    if (material.category == null) {
      // it is a category
      return;
    }

    this.material = material;
    setState(() {
      _appBarTitle = Text(material.toString() ??
          AppLocalizations.of(context).translate('material.title'));
    });
  }

  @override
  Widget build(BuildContext context) {
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
