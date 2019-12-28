import 'dart:async';
//import 'dart:convert';

import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
//import 'package:oee_mobile/TreeViewMain.dart';
//import 'package:dynamic_treeview/dynamic_treeview.dart';
//import 'TreeViewDataModel.dart';
import 'dynamic_treeview.dart';
import 'model.dart';
import 'EquipmentEvent.dart';
import 'http_service.dart';
//import 'lists_expansion_tile_ex.dart';

void main() => runApp(OeeMobileApp());
//void main() => runApp(ExpansionTileExample());
//void main() => runApp(TreeViewApp());

class OeeMobileApp extends StatelessWidget {
  //const OeeMobileApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Point85 OEE Application',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new OeeHomePage(title: 'Point85 OEE Home Page'),
    );
  }
}

class OeeHomePage extends StatefulWidget {
  OeeHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _OeeHomePageState createState() => _OeeHomePageState();
}

class _OeeHomePageState extends State<OeeHomePage> {
  int _counter = 0;
  Future<MaterialList> materialListFuture;
  List<BaseData> materialData;

  @override
  void initState() {
    super.initState();

    fetchMaterials();
  }

  void fetchMaterials() {
    materialListFuture = OeeHttpService.fetchMaterials();
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;

      // send the HTTP request
      //post = fetchPost();
      materialListFuture = OeeHttpService.fetchMaterials();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<MaterialList>(
        future: materialListFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            MaterialList matList = snapshot.data;
            OeeMaterial dto = matList.materialList[0];
            //return Text(dto.name);
            Widget widget = this.createMaterialView(matList);
            //widget = Text(dto.name);
            return widget;
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner.
          return CircularProgressIndicator();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),

      /*
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),

            FutureBuilder<MaterialList>(
              future: materialListFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  MaterialList matList = snapshot.data;
                  OeeMaterial dto = matList.materialList[0];
                  //return Text(dto.name);
                  Widget widget =  this.createMaterialView(matList);
                  widget = Text(dto.name);
                  return widget;
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                // By default, show a loading spinner.
                return CircularProgressIndicator();
              },
            )
          ],
        ),
      )
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.

       */
    );
  }

  DynamicTreeView createMaterialView(MaterialList materialList) {
    return DynamicTreeView(
      data: fromMaterialList(materialList),
      config: Config(
          parentTextStyle:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          rootId: "root",
          parentPaddingEdgeInsets:
              EdgeInsets.only(left: 16, top: 0, bottom: 0)),
      onTap: (m) {
        //print("onChildTap -> $m");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (ctx) => EquipmentEvent(
                      data: m,
                    )));
      },
      width: MediaQuery.of(context).size.width,
    );
  }

  List<BaseData> getMaterialData() {
    //if (materialData == null) {
    materialListFuture = OeeHttpService.fetchMaterials();
    //this.materialListFuture.whenComplete(() => print("i am done"));
    materialListFuture.then((value) {
      materialData = fromMaterialList(value);
    }, onError: (error) {
      print('completed with error $error');
    });
    //}
    return materialData;
  }

  List<BaseData> fromMaterialList(MaterialList materialList) {
    List<BaseData> materialData = List();
    // root
    OeeMaterial rootMaterial = OeeMaterial("root", "root", null);
    MaterialDataModel root = MaterialDataModel(rootMaterial);
    materialData.add(root);

    List<String> categories = List();

    // materials
    List<OeeMaterial> materials = materialList.materialList;
    for (OeeMaterial material in materials) {
      MaterialDataModel matModel = MaterialDataModel(material);

      if (!categories.contains(material.category)) {
        categories.add(material.category);
        matModel.parentId = material.category;
      }
      materialData.add(matModel);
    }

    // add categories
    for (String category in categories) {
      OeeMaterial catMaterial = OeeMaterial(category, category, "root");
      MaterialDataModel cat = MaterialDataModel(catMaterial);
      materialData.add(cat);
    }
    return materialData;
  }
}

class MaterialDataModel implements BaseData {
  static const String MAT_KEY = "material";

  String id;
  String parentId;
  String name;
  String subTitle;
  Icon icon;

  ///Any extra data you want to get when tapped on children
  Map<String, dynamic> extras;

  MaterialDataModel(OeeMaterial material) {
    this.parentId = material.category;
    this.id = material.name;
    this.name = material.name;

    extras = {MAT_KEY: material};
  }

  //MaterialDataModel({this.id, this.parentId, this.name, this.extras});
  @override
  String getId() {
    return this.id.toString();
  }

  @override
  Map<String, dynamic> getExtraData() {
    return this.extras;
  }

  @override
  String getParentId() {
    return this.parentId.toString();
  }

  @override
  String getTitle() {
    return this.name;
  }

  @override
  String getSubTitle() {
    return this.subTitle;
  }

  @override
  Icon getIcon() {
    //return Icon( Icons.audiotrack, color: Colors.green, size: 30.0, );
    return icon;
  }
}
