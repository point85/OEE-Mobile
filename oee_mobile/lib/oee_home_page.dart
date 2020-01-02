import 'dart:async';
import 'package:flutter/material.dart';
import 'dynamic_treeview.dart';
import 'oee_model.dart';
import 'oee_equipment_page.dart';
import 'oee_controller.dart';
import 'oee_http_service.dart';

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

  Future setUrl() async {
    var value = await PersistentStorage.getInstance.getServerInfo();
    OeeHttpService.getInstance.setUrl(value[0], value[1]);
  }

  @override
  void initState() {
    super.initState();
    setUrl();
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
        return SettingsWidget();
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

class SettingsWidget extends StatefulWidget {
  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  String serverName;
  String serverPort;

  final nameController = TextEditingController();
  final portController = TextEditingController();

  @override
  void initState() {
    super.initState();

    PersistentStorage.getInstance.getServerInfo().then((value) {
      String name = value[0];
      String port = value[1];
      nameController.text = name;
      portController.text = port;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    portController.dispose();
    super.dispose();
  }

  String _validateName(String value) {
    if (value.isEmpty) return 'Server name is required.';
    final RegExp nameExp = new RegExp(r'^[A-Za-z ]+$');
    if (!nameExp.hasMatch(value))
      return 'Please enter only alphabetical characters.';
    return null;
  }

  String _validatePort(String value) {
    if (value.isEmpty) return 'Server port is required.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final _onSave = () {
      serverName = nameController.text;
      serverPort = portController.text;

      PersistentStorage.getInstance.saveServerInfo(serverName, serverPort);
    };

    return Container(
        margin: const EdgeInsets.only(top: 5, left: 15, right: 15),
        height: 250,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                filled: true,
                icon: Icon(Icons.computer),
                hintText: 'HTTP server name or IP address',
                labelText: 'Server *',
              ),
              keyboardType: TextInputType.text,
              onSaved: (String value) {
                this.serverName = value;
              },
              validator: _validateName,
            ),
            // port
            TextFormField(
              controller: portController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                filled: true,
                icon: Icon(Icons.panorama_fish_eye),
                hintText: 'HTTP server port',
                labelText: 'Port *',
              ),
              keyboardType: TextInputType.number,
              onSaved: (String value) {
                this.serverPort = value;
              },
              validator: _validatePort,
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton.icon(
                  //child: Text('Save'),
                  onPressed: _onSave,
                  icon: Icon(Icons.save), //`Icon` to display
                  label: Text('Save'), //`Text` to display
                ),
              ],
            ),
          ],
        )
        );
  }
}
