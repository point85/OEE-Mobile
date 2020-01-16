import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:oee_mobile/oee_services.dart';
import 'oee_reason_page.dart';
import 'oee_model.dart';
import 'oee_ui_shared.dart';

class EquipmentEventPage extends StatefulWidget {
  //final Map entityData;
  final OeeEntity equipment;

  //EquipmentEventPage({this.entityData});
  EquipmentEventPage({this.equipment});

  @override
  _EquipmentEventPageState createState() => _EquipmentEventPageState();
}

class _EquipmentEventPageState extends State<EquipmentEventPage> {
  //_EquipmentEventPageState();

  OeeReason selectedReason;

  // keys to get the DateTime
  final startTimeKey = new GlobalKey<DateTimeWidgetState>();
  final endTimeKey = new GlobalKey<DateTimeWidgetState>();

  final GlobalKey<FormState> _availabilityFormKey = GlobalKey<FormState>();

  bool showEndTime = true;

  static const int BY_PERIOD = 0;
  static const int BY_EVENT = 1;
  int _availabilityValue = BY_PERIOD;

  @override
  void initState() {
    super.initState();
  }

  void _submitForm() {
    final FormState form = _availabilityFormKey.currentState;
    form.save(); //This invokes each onSaved event

    DateTime dt = startTimeKey.currentState.dateTime;
    print(dt.toIso8601String());
  }

  void _handleAvailabilityChange(int value) {
    setState(() {
      _availabilityValue = value;

      switch (_availabilityValue) {
        case BY_PERIOD:
          showEndTime = true;
          break;
        case BY_EVENT:
          showEndTime = false;
          break;
      }
    });
  }

  /*
  TextFormField myName = new TextFormField(
    decoration: const InputDecoration(
      icon: const Icon(Icons.person),
      hintText: 'Enter your first and last name',
      labelText: 'My Name',
    ),
    inputFormatters: [LengthLimitingTextInputFormatter(30)],
    validator: (val) => val.isEmpty ? 'Name is required' : null,
  );

   */

  @override
  Widget build(BuildContext context) {
    MaterialApp app = MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
              title: Text(widget.equipment.toString()),
              bottom: TabBar(
                tabs: [
                  Tab(text: 'Availability', icon: Icon(Icons.query_builder)),
                  Tab(text: 'Production', icon: Icon(Icons.data_usage)),
                  Tab(
                      text: 'Setup/Job',
                      icon: Icon(Icons.settings_applications)),
                ],
              )),
          body: TabBarView(
            children: [
              _buildAvailabilityView(context),
              Icon(Icons.directions_transit),
              Icon(Icons.directions_bike),
            ],
          ),
        ),
      ),
    );

    return app;
  }

  _showReasons(BuildContext context) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (ctx) => ReasonPage()));
    selectedReason = OeeExecutionService.getInstance.reason;
  }

  Widget _buildAvailabilityView(BuildContext context) {
    Form form = Form(
        key: _availabilityFormKey,
        autovalidate: true,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: <Widget>[
            // radio buttons
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Radio(
                value: BY_PERIOD,
                groupValue: _availabilityValue,
                onChanged: _handleAvailabilityChange,
              ),
              Text('By Time Period'),
              Radio(
                value: BY_EVENT,
                groupValue: _availabilityValue,
                onChanged: _handleAvailabilityChange,
              ),
              Text('By Event'),
            ]),
            // reason selection
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              RaisedButton.icon(
                label: Text('Reason'),
                onPressed: () {
                  _showReasons(context);
                },
                icon: const Icon(Icons.category),
              ),
              SizedBox(width: 20),
              Text(selectedReason?.toString() ?? ''),
            ]),

            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              SizedBox(child: Text('Start Time'), width: 100),
              Expanded(child: DateTimeWidget(key: startTimeKey)),
            ]),

            // event end
            Visibility(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(child: Text('End Time'), width: 100),
                      Expanded(child: DateTimeWidget(key: endTimeKey)),
                      SizedBox(child: Text('Duration'), width: 75),

                      SizedBox(
                          child: TextFormField(
                            decoration: InputDecoration(
                                //border: InputBorder.none,
                                //hintText: 'Duration',
                                labelText: 'HH'),
                          ),
                          width: 50),
                      SizedBox(
                          child: TextFormField(
                            decoration: InputDecoration(
                              //border: InputBorder.none,
                              //hintText: 'Duration',
                                labelText: 'MM'),
                          ),
                          width: 50),
                    ]),
                visible: showEndTime),
/*
            Visibility(child: myName, visible: showName),
            TextFormField(
              decoration: const InputDecoration(
                icon: const Icon(Icons.person),
                hintText: 'Enter your first and last name',
                labelText: 'Name',
              ),
              inputFormatters: [LengthLimitingTextInputFormatter(30)],
              validator: (val) => val.isEmpty ? 'Name is required' : null,
              onSaved: (val) => testData = val,
            ),

 */
            Container(
                padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                child: RaisedButton.icon(
                  label: const Text('Submit'),
                  onPressed: _submitForm,
                  icon: const Icon(Icons.check_circle_outline),
                )),
          ],
        ));

    return form;
  }
}
