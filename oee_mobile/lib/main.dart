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

  // root of OEE application
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Point85 OEE Application',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new OeeHomePage(title: 'Point85 OEE Home Page'),
    );
  }
}

class OeeHomePage extends StatefulWidget {
  OeeHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _OeeHomePageState createState() => _OeeHomePageState();
}

class _OeeHomePageState extends State<OeeHomePage> {
  Future<MaterialList> materialListFuture;
  List<BaseData> materialData;

  int _bottomNavBarIndex = 0;

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showBottomSheetCallback() {
    _scaffoldKey.currentState.showBottomSheet<void>((BuildContext context) {
      return Container(
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black)),
            color: Colors.grey),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'This is a Material persistent bottom sheet. Drag downwards to dismiss it.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.0,
            ),
          ),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    fetchMaterials();
  }

  void fetchMaterials() {
    materialListFuture = OeeHttpService.fetchMaterials();
  }

  void _showAboutDialog() {
    final TextStyle textStyle = Theme.of(context).textTheme.body1;
    final List<Widget> aboutBoxChildren = <Widget>[
      SizedBox(height: 24),
      RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
                style: textStyle,
                text: 'Flutter is Google’s UI toolkit for building beautiful, '
                    'natively compiled applications for mobile, web, and desktop '
                    'from a single codebase. Learn more about Flutter at '),
            TextSpan(
                style: textStyle.copyWith(color: Theme.of(context).accentColor),
                text: 'https://flutter.dev'),
            TextSpan(style: textStyle, text: '.'),
          ],
        ),
      ),
    ];

    showAboutDialog(
      context: context,
      applicationIcon: FlutterLogo(),
      applicationName: 'Show About Example',
      applicationVersion: 'August 2019',
      applicationLegalese: '© 2019 The Chromium Authors',
      children: aboutBoxChildren,
    );
  }

  void _showSettings() {
    //_showBottomSheetCallback();
    //_scaffoldKey.currentState.showBottomSheet<void>((BuildContext context) {
//return BottomSheetWidget();

  }

  PersistentBottomSheetController _sheetController;

  @override
  Widget build(BuildContext context) {
    final _showBottomSheet = () {
      //var bottomSheetController = showBottomSheet(
      //    context: context,
       //   builder: (context) => BottomSheetWidget());
      _sheetController = _scaffoldKey.currentState.showBottomSheet((context) {
      return BottomSheetWidget();
          /*
          Container(
            color: Colors.grey[200],
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              RadioListTile(dense: true, title: Text('Test'), groupValue: 'test', onChanged: (value) {}, value: true),
              RadioListTile(dense: true, title: Text('Test'), groupValue: 'test', onChanged: (value) {}, value: true),
            ]));

           */
      });
    };

    void _onBottomNavBarItemTapped(int index) {
      setState(() {
        _bottomNavBarIndex = index;
      });

      switch (index) {
        case 0:
        //_showBottomSheetCallback();
          _showBottomSheet();
          break;
        case 1:
          fetchMaterials();
          break;
        case 2:
          _showAboutDialog();
          break;
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      // top app bar
      appBar: AppBar(
        title: Text(widget.title),
      ),

      // body
      body: FutureBuilder<MaterialList>(
        future: materialListFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            MaterialList matList = snapshot.data;
            Widget widget = createMaterialView(matList);
            //widget = Text(dto.name);
            return widget;
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner.
          return CircularProgressIndicator();
        },
      ),

      // bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('Settings'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.refresh),
            title: Text('Refresh'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            title: Text('About'),
          ),
        ],
        currentIndex: _bottomNavBarIndex,
        selectedItemColor: Colors.amber[800],
        onTap: //_showBottomSheet,
        _onBottomNavBarItemTapped,
      ),

      // floating button
      //floatingActionButton: MyFloatingActionButton(),
/*
      floatingActionButton: FloatingActionButton(
        onPressed: _showBottomSheetCallback,
        /*
        onPressed: () {
          showBottomSheet(
              context: context,
              builder: (context) => Container(
                color: Colors.red,
              ));
        },

         */
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
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
    this.subTitle = material.description;
    this.icon = Icon(
      Icons.category,
      color: Colors.green,
      size: 30.0,
    );
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

class DecoratedTextField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
        child: TextField(
          decoration: InputDecoration.collapsed(
            hintText: 'Enter your reference number',
          ),
        ));
  }
}

class SheetButton extends StatefulWidget {
  _SheetButtonState createState() => _SheetButtonState();
}

class _SheetButtonState extends State<SheetButton> {
  bool checkingFlight = false;
  bool success = false;
  @override
  Widget build(BuildContext context) {
    return !checkingFlight
        ? MaterialButton(
            color: Colors.grey[800],
            onPressed: () async {
              setState(() {
                checkingFlight = true;
              });
              await Future.delayed(Duration(seconds: 1));
              setState(() {
                success = true;
              });
              await Future.delayed(Duration(milliseconds: 500));
              Navigator.pop(context);
            },
            child: Text(
              'Check Flight',
              style: TextStyle(color: Colors.white),
            ),
          )
        : !success
            ? CircularProgressIndicator()
            : Icon(
                Icons.check,
                color: Colors.green,
              );
  }
}

class BottomSheetWidget extends StatefulWidget {
  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5, left: 15, right: 15),
      height: 160,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 125,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 10, color: Colors.grey[300], spreadRadius: 5)
                ]),
            child: Column(
              children: <Widget>[
                DecoratedTextField(),
                SheetButton(),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MyFloatingActionButton extends StatefulWidget {
  @override
  _MyFloatingActionButtonState createState() => _MyFloatingActionButtonState();
}

class _MyFloatingActionButtonState extends State<MyFloatingActionButton> {
  bool showFab = true;
  @override
  Widget build(BuildContext context) {
    return showFab
        ? FloatingActionButton(
            onPressed: () {
              var bottomSheetController = showBottomSheet(
                  context: context,
                  builder: (context) => BottomSheetWidget());
                      /*
                      Container(
                        decoration: BoxDecoration(
                            border:
                                Border(top: BorderSide(color: Colors.black)),
                            color: Colors.grey),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'This is a Material persistent bottom sheet. Drag downwards to dismiss it.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24.0,
                            ),
                          ),
                        ),
                      ));

                       */
              /*
                Container(
              color: Colors.grey[900],
              height: 250,
            ));

           */
              showFloatingActionButton(false);
              bottomSheetController.closed.then((value) {
                showFloatingActionButton(true);
              });
            },
          )
        : Container();
  }

  void showFloatingActionButton(bool value) {
    setState(() {
      showFab = value;
    });
  }
}
