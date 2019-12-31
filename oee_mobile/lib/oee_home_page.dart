import 'dart:async';
import 'package:flutter/material.dart';
import 'dynamic_treeview.dart';
import 'oee_model.dart';
import 'oee_equipment_page.dart';
import 'oee_controller.dart';

void main() => runApp(OeeMobileApp());

class OeeMobileApp extends StatelessWidget {
  // root of OEE application
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Point85 OEE Application',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new OeeHomePage(title: 'Point85 OEE'),
    );
  }
}

class OeeHomePage extends StatefulWidget {
  final String title;

  OeeHomePage({Key key, this.title}) : super(key: key);

  @override
  _OeeHomePageState createState() => _OeeHomePageState();
}

class _OeeHomePageState extends State<OeeHomePage> {
  // list of entities
  //Future<MaterialList> materialListFuture;
  //List<BaseData> materialData;
  //Future<EntityList> entityListFuture;
  //List<EntityDataModel> entityData;
  Future<ReasonList> reasonListFuture;
  List<ReasonDataModel> reasonData;

  int _bottomNavBarIndex = 0;

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    //materialListFuture = EquipmentPageController.fetchMaterials();
    //entityListFuture = OeeHomePageController.fetchEntities();
    reasonListFuture = EquipmentPageController.fetchReasons();
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
                text:
                    'The Point85 Overall Equipment Effectiveness (OEE) applications enable '
                    'collection of equipment data from multiple sources to support OEE calculations of performance, availability and quality.'),
          ],
        ),
      ),
    ];

    showAboutDialog(
      context: context,
      applicationIcon: FlutterLogo(),
      applicationName: 'Point OEE',
      applicationVersion: '3.0.0',
      children: aboutBoxChildren,
    );
  }

  @override
  Widget build(BuildContext context) {
    final _showBottomSheet = () {
      //PersistentBottomSheetController _sheetController =
      _scaffoldKey.currentState.showBottomSheet((context) {
        return BottomSheetWidget();
      });
    };

    void _onBottomNavBarItemTapped(int index) {
      setState(() {
        _bottomNavBarIndex = index;
      });

      switch (index) {
        case 0:
          _showBottomSheet();
          break;
        case 1:
          reasonListFuture = EquipmentPageController.fetchReasons();
          //entityListFuture = OeeHomePageController.fetchEntities();
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
      body: FutureBuilder<ReasonList>(
        future: reasonListFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            ReasonList reasonList = snapshot.data;
            return createReasonView(reasonList);
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
        onTap: _onBottomNavBarItemTapped,
      ),
    );
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

  DynamicTreeView createEntityView(EntityList entityList) {
    return DynamicTreeView(
      data: OeeHomePageController.fromEntityList(entityList),
      config: Config(
          parentTextStyle:
          TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          rootId: HierarchicalDataModel.ROOT_ID,
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

  DynamicTreeView createReasonView(ReasonList reasonList) {
    return DynamicTreeView(
      data: EquipmentPageController.fromReasonList(reasonList),
      config: Config(
          parentTextStyle:
          TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          rootId: HierarchicalDataModel.ROOT_ID,
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
