import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'dynamic_treeview.dart';
import 'oee_model.dart';
import 'oee_equipment_page.dart';
import 'oee_controller.dart';
import 'oee_http_service.dart';
import 'oee_persistence_service.dart';
import 'oee_ui_shared.dart';
import 'oee_localization.dart';

// the application widget
class OeeMobileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      supportedLocales: [
        Locale('en', 'US'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new OeeHomePage(),
    );
  }
}

class OeeHomePage extends StatefulWidget {
  OeeHomePage({Key key}) : super(key: key);

  @override
  _OeeHomePageState createState() => _OeeHomePageState();
}

class _OeeHomePageState extends State<OeeHomePage> {
  // nav bar index
  int _bottomNavBarIndex = 0;

  final _homeScaffoldKey = GlobalKey<ScaffoldState>();

  // fetch the HTTP server info
  Future<EntityList> refreshEntities() async {
    var value = await PersistenceService.getInstance.getServerInfo();

    if (value == null || value[0] == null || value[1] == null) {
      UIUtils.showErrorDialog(
          context, AppLocalizations.of(context).translate('no.http.server'));
      return null;
    }
    OeeHttpService.getInstance.setUrl(value[0], value[1]);

    return OeeHttpService.getInstance.fetchEntities();
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
                    AppLocalizations.of(context).translate('home.about.text')),
          ],
        ),
      ),
    ];

    showAboutDialog(
      context: context,
      applicationIcon: Image(image: AssetImage('assets/images/Point85_48.png')),
      applicationName: AppLocalizations.of(context).translate('app.name'),
      applicationVersion: AppLocalizations.of(context).translate('app.version'),
      children: aboutBoxChildren,
    );
  }

  @override
  Widget build(BuildContext context) {
    final _showSettings = () {
      _homeScaffoldKey.currentState.showBottomSheet((context) {
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
          // refresh page
          setState(() {});
          break;
        case 2:
          // about dialog
          _showAboutDialog();
          break;
      }
    }

    return Scaffold(
      key: _homeScaffoldKey,
      // top app bar
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('home.page.title')),
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
          return Center(child: CircularProgressIndicator());
        },
      ),

      // bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title:
                Text(AppLocalizations.of(context).translate('home.settings')),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.refresh),
            title: Text(AppLocalizations.of(context).translate('home.refresh')),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            title: Text(AppLocalizations.of(context).translate('home.about')),
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
          ProgressDialog dialog = ProgressDialog(context);
          dialog.style(
              message:
                  AppLocalizations.of(context).translate('home.equip.status'));
          Future<bool> isShowing = dialog.show();

          // get current status
          Future<OeeEquipmentStatus> future =
              OeeHttpService.getInstance.fetchEquipmentStatus(entity);

          future.then((status) {
            // hide progress dialog
            isShowing.whenComplete(() => dialog.hide().whenComplete(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (ctx) => EquipmentEventPage(
                                equipment: entity,
                                equipmentStatus: status,
                              )));
                }));
          }, onError: (error) {
            isShowing.whenComplete(() => dialog.hide().whenComplete(() {
                  UIUtils.showErrorDialog(context, '$error');
                }));
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
    if (value.isEmpty)
      return AppLocalizations.of(context).translate('no.server.name');
    return null;
  }

  String _validatePort(String value) {
    if (value.isEmpty)
      return AppLocalizations.of(context).translate('no.server.port');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final _onSave = () {
      serverName = nameController.text;
      serverPort = portController.text;

      PersistenceService.getInstance.saveServerInfo(serverName, serverPort);

      final snackBar = SnackBar(
        content:
            Text(AppLocalizations.of(context).translate('home.settings.saved')),
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
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                filled: true,
                icon: Icon(Icons.computer),
                hintText:
                    AppLocalizations.of(context).translate('home.server.hint'),
                labelText:
                    AppLocalizations.of(context).translate('home.server.label'),
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
                hintText:
                    AppLocalizations.of(context).translate('home.port.hint'),
                labelText:
                    AppLocalizations.of(context).translate('home.port.label'),
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
                  label:
                      Text(AppLocalizations.of(context).translate('home.save')),
                ),
              ],
            ),
          ],
        ));
  }
}
