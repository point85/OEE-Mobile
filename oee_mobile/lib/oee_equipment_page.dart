import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EquipmentEventWidget extends StatelessWidget {
  final Map entityData;
  EquipmentEventWidget({this.entityData});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text('${entityData['title']}"'),
            bottom: TabBar(
              tabs: [
                Tab(text: 'Availability', icon: Icon(Icons.query_builder)),
                Tab(text: 'Production', icon: Icon(Icons.data_usage)),
                Tab(text: 'Setup/Job', icon: Icon(Icons.settings_applications)),
              ],
            )
          ),
          body: TabBarView(
            children: [
              Icon(Icons.directions_car),
              Icon(Icons.directions_transit),
              Icon(Icons.directions_bike),
            ],
          ),
        ),
      ),
    );
  }
}

class OldEquipmentEventWidget extends StatelessWidget {
  final Map data;
  OldEquipmentEventWidget({this.data});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${data['title']}"),
      ),
      body: Center(
        child: Wrap(
          direction: Axis.vertical,
          children: <Widget>[
            Text(
              "ID: ${data['id']}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              "PARENT-ID ${data['parent_id']}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              "EXTRAS: ${data['extra']}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}