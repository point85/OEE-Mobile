import 'dart:async';
import 'package:flutter/material.dart';
import 'dynamic_treeview.dart';
import 'oee_model.dart';
import 'oee_equipment_page.dart';
import 'oee_controller.dart';
import 'oee_services.dart';
import 'oee_persistence_service.dart';
import 'oee_ui_shared.dart';

void main() => runApp(OeeMobileApp());

class OeeMobileApp extends StatelessWidget {
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
  // nav bar index
  int _bottomNavBarIndex = 0;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // fetch the HTTP server info
  Future<EntityList> refreshEntities() async {
    var value = await PersistenceService.getInstance.getServerInfo();

    if (value == null || value[0] == null || value[1] == null) {
      UIUtils.showAlert(context, 'Server Not Defined',
          'The HTTP server name and port must be defined under Settings.');
      return null;
    }
    OeeHttpService.getInstance.setUrl(value[0], value[1]);
    return OeeHomePageController.fetchEntities();
  }

  void _showAboutDialog() {
    final TextStyle textStyle = Theme.of(context).textTheme.bodyText2;
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
    final _showSettings = () {
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
          // settings
          _showSettings();
          break;
        case 1:
          // refresh
          refreshEntities();
          break;
        case 2:
          // about dialog
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
      body: FutureBuilder<EntityList>(
        future: refreshEntities(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return createEntityView(snapshot.data);
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
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

  DynamicTreeView createEntityView(EntityList entityList) {
    return DynamicTreeView(
      data: OeeHomePageController.fromEntityList(entityList),
      config: Config(
          parentTextStyle:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          rootId: HierarchicalDataModel.ROOT_ID,
          parentPaddingEdgeInsets:
              EdgeInsets.only(left: 16, top: 0, bottom: 0)),
      onTap: (dataMap) {
        OeeEntity entity = EntityDataModel.getEntity(dataMap);

        if (entity.level == EntityLevel.EQUIPMENT) {
          // get current status
          Future<OeeEquipmentStatus> future =
              OeeHttpService.getInstance.fetchEquipmentStatus(entity);

          future.then((status) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (ctx) => EquipmentEventPage(
                        equipment: entity, equipmentStatus: status)));
          }, onError: (error) {
            UIUtils.showAlert(context, 'Equipment Status Error', '$error');
          });
        }
      },
      width: MediaQuery.of(context).size.width,
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

    PersistenceService.getInstance.getServerInfo().then((value) {
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

      PersistenceService.getInstance.saveServerInfo(serverName, serverPort);

      final snackBar = SnackBar(
        content: Text('Settings saved'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      );

      Scaffold.of(context).showSnackBar(snackBar);
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
                  onPressed: _onSave,
                  icon: Icon(Icons.save),
                  label: Text('Save'),
                ),
              ],
            ),
          ],
        ));
  }
}
