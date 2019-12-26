import 'dart:async';
//import 'dart:convert';

import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
//import 'package:oee_mobile/TreeViewMain.dart';
//import 'package:dynamic_treeview/dynamic_treeview.dart';
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

  @override
  void initState() {
    super.initState();
    //post = fetchPost();
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
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
                  OeeMaterial dto = matList.materialList[_counter];
                  return Text(dto.name);
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                // By default, show a loading spinner.
                return CircularProgressIndicator();
              },
            ),
            DynamicTreeView(
              data: getData(),
              config: Config(
                  parentTextStyle: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                  rootId: "1",
                  parentPaddingEdgeInsets:
                      EdgeInsets.only(left: 16, top: 0, bottom: 0)),
              onTap: (m) {
                print("onChildTap -> $m");
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (ctx) => EquipmentEvent(
                              data: m,
                            )));
              },
              width: MediaQuery.of(context).size.width,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  List<BaseData> getData() {
    //if (materialListFuture == null) {
      materialListFuture = OeeHttpService.fetchMaterials();
      //this.materialListFuture.whenComplete(() => print("i am done"));
      materialListFuture.then((value) {
        print('completed with value $value');
      }, onError: (error) {
        print('completed with error $error');
      });
    //}

    return [
      MaterialDataModel(
        id: 1,
        name: 'Root',
        parentId: -1,
        extras: {'key': 'extradata1'},
      ),
      MaterialDataModel(
        id: 2,
        name: 'Men',
        parentId: 1,
        extras: {'key': 'extradata2'},
      ),
      MaterialDataModel(
        id: 3,
        name: 'Shorts',
        parentId: 2,
        extras: {'key': 'extradata3'},
      ),
      MaterialDataModel(
        id: 4,
        name: 'Shoes',
        parentId: 2,
        extras: {'key': 'extradata4'},
      ),
      MaterialDataModel(
        id: 5,
        name: 'Women',
        parentId: 1,
        extras: {'key': 'extradata5'},
      ),
      MaterialDataModel(
        id: 6,
        name: 'Shoes',
        parentId: 5,
        extras: {'key': 'extradata6'},
      ),
      MaterialDataModel(
        id: 7,
        name: 'Shorts',
        parentId: 5,
        extras: {'key': 'extradata7'},
      ),
      MaterialDataModel(
        id: 8,
        name: 'Tops',
        parentId: 5,
        extras: {'key': 'extradata8'},
      ),
      MaterialDataModel(
        id: 9,
        name: 'Electronics',
        parentId: 1,
        extras: {'key': 'extradata9'},
      ),
      MaterialDataModel(
        id: 10,
        name: 'Phones',
        parentId: 9,
        extras: {'key': 'extradata10'},
      ),
      MaterialDataModel(
        id: 11,
        name: 'Tvs',
        parentId: 9,
        extras: {'key': 'extradata11'},
      ),
      MaterialDataModel(
        id: 12,
        name: 'Laptops',
        parentId: 9,
        extras: {'key': 'extradata12'},
      ),
      MaterialDataModel(
        id: 13,
        name: 'Nike shooes',
        parentId: 4,
        extras: {'key': 'extradata13'},
      ),
      MaterialDataModel(
        id: 14,
        name: 'puma shoes',
        parentId: 4,
        extras: {'key': 'extradata14'},
      ),
      MaterialDataModel(
        id: 15,
        name: 'puma shoes 1',
        parentId: 14,
        extras: {'key': 'extradata15'},
      ),
      MaterialDataModel(
        id: 16,
        name: 'puma shoes 2',
        parentId: 14,
        extras: {'key': 'extradata16'},
      ),
      MaterialDataModel(
        id: 17,
        name: 'puma shoes 3',
        parentId: 14,
        extras: {'key': 'extradata17'},
      ),
    ];
  }
}

class MaterialDataModel implements BaseData {
  final int id;
  final int parentId;
  String name;
  String subTitle;
  Icon icon;

  ///Any extra data you want to get when tapped on children
  Map<String, dynamic> extras;
  MaterialDataModel({this.id, this.parentId, this.name, this.extras});
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
