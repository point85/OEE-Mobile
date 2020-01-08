import 'package:flutter/material.dart';
import 'oee_model.dart';
import 'oee_controller.dart';
import 'dynamic_treeview.dart';
import 'oee_services.dart';

class MaterialPage extends StatefulWidget {
  final String title = 'Choose a Material';

  MaterialPage();

  @override
  _MaterialPageState createState() => _MaterialPageState();
}

class _MaterialPageState extends State<MaterialPage> {
  OeeMaterial material;

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
      },
      width: MediaQuery.of(context).size.width,
    );
  }

  Future<bool> _onBackPressed() {
    OeeExecutionService.getInstance.material = this.material;
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

          body: FutureBuilder<MaterialList>(
              future: refreshMaterials(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return createMaterialView(snapshot.data);
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return CircularProgressIndicator();
              }),
        ));
  }
}