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

  // event reason
  OeeReason selectedReason;

  // event duration
  String eventHours;
  String eventMinutes;

  // keys to get the DateTime
  final startTimeKey = new GlobalKey<DateTimeWidgetState>();
  final endTimeKey = new GlobalKey<DateTimeWidgetState>();

  final GlobalKey<FormState> _availabilityFormKey = GlobalKey<FormState>();

  bool showEndTime = true;

  static const int BY_PERIOD = 0;
  static const int BY_EVENT = 1;
  int _availabilityValue = BY_PERIOD;

  // event duration hours and minutes
  //final hoursController = TextEditingController();
  //final minutesController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    //hoursController.dispose();
    //minutesController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final FormState form = _availabilityFormKey.currentState;
    form.save(); //This invokes each onSaved event

    DateTime startTime = startTimeKey.currentState.dateTime;
    DateTime endTime = endTimeKey.currentState.dateTime;

    int intHours = int.parse(this.eventHours);
    int intMinutes = int.parse(this.eventMinutes);
    Duration eventDuration = Duration(hours: intHours, minutes: intMinutes);

    OeeEvent availabilityEvent = OeeEvent(widget.equipment, startTime);
    availabilityEvent.duration = eventDuration;
    availabilityEvent.endTime = endTime;
    availabilityEvent.reason = selectedReason;

    OeeHttpService.getInstance.postEquipmentEvent(availabilityEvent);
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          children: <Widget>[
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

            // by event or by time period
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

            // event start date and time
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              SizedBox(child: Text('Start Time'), width: 100),
              Expanded(child: DateTimeWidget(key: startTimeKey)),
              SizedBox(width: 195),
            ]),

            // event end date and time
            Visibility(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(child: Text('End Time'), width: 100),
                      Expanded(child: DateTimeWidget(key: endTimeKey)),
                      SizedBox(child: Text('Duration'), width: 75),
                      SizedBox(
                          child: TextFormField(
                            //controller: hoursController,
                            decoration: InputDecoration(
                                //border: InputBorder.none,
                                //hintText: 'Duration',
                                labelText: 'Hrs'),
                            keyboardType: TextInputType.number,
                            onSaved: (String value) {
                              eventHours = value;
                            },
                          ),
                          width: 50),
                      SizedBox(width: 20),
                      SizedBox(
                          child: TextFormField(
                            //controller: minutesController,
                            decoration: InputDecoration(
                              //border: InputBorder.none,
                              //hintText: 'Duration',
                                labelText: 'Mins'),
                            keyboardType: TextInputType.number,
                            onSaved: (String value) {
                              eventMinutes = value;
                            },
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
                  onPressed: _onSubmit,
                  icon: const Icon(Icons.check_circle_outline),
                )),
          ],
        ));

    return form;
  }
}
