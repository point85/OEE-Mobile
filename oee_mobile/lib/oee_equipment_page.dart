import 'package:flutter/material.dart';
import 'package:oee_mobile/oee_services.dart';
import 'oee_reason_page.dart';
import 'oee_model.dart';
import 'oee_ui_shared.dart';

class EquipmentEventPage extends StatefulWidget {
  // equipment
  final OeeEntity equipment;

  // equipment status
  final OeeEquipmentStatus equipmentStatus;

  EquipmentEventPage({this.equipment, this.equipmentStatus});

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

  // form keys
  final GlobalKey<FormState> _availabilityFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _productionFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _setupFormKey = GlobalKey<FormState>();

  // time period setttings
  bool showEndTime = true;

  static const int BY_PERIOD = 0;
  static const int BY_EVENT = 1;

  // default event time period
  int _eventTimeValue = BY_PERIOD;

  // production count settings
  static const int GOOD = 0;
  static const int REJECT = 1;
  static const int STARTUP = 2;

  // default production type
  int _productionValue = GOOD;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onSubmit() {
    final FormState form = _availabilityFormKey.currentState;
    form.save(); //This invokes each onSaved event

    DateTime startTime = startTimeKey.currentState != null
        ? startTimeKey.currentState.dateTime
        : null;
    // no seconds
    DateTime start = startTime != null
        ? DateTime(startTime.year, startTime.month, startTime.day,
            startTime.hour, startTime.minute)
        : null;

    DateTime end;
    Duration eventDuration;

    if (_eventTimeValue == BY_PERIOD) {
      DateTime endTime = endTimeKey.currentState != null
          ? endTimeKey.currentState.dateTime
          : null;
      // no seconds
      end = endTime != null
          ? DateTime(endTime.year, endTime.month, endTime.day, endTime.hour,
              endTime.minute)
          : null;

      int intHours = (eventHours != null && eventHours.length > 0)
          ? int.parse(eventHours)
          : 0;
      int intMinutes = (eventMinutes != null && eventMinutes.length > 0)
          ? int.parse(eventMinutes)
          : 0;
      eventDuration = Duration(hours: intHours, minutes: intMinutes);
    }

    OeeEvent availabilityEvent = OeeEvent(widget.equipment, start);
    availabilityEvent.duration = eventDuration;
    availabilityEvent.endTime = end;
    availabilityEvent.reason = selectedReason;
    availabilityEvent.eventType = OeeEventType.AVAILABILITY;

    OeeHttpService.getInstance.postEquipmentEvent(availabilityEvent);

    _showSnackBar("Availability event recorded.");
  }

  void _handleEventTimeChange(int value) {
    setState(() {
      _eventTimeValue = value;

      switch (_eventTimeValue) {
        case BY_PERIOD:
          showEndTime = true;
          break;
        case BY_EVENT:
          showEndTime = false;
          break;
      }
    });
  }

  Icon _getAvailabilityIcon(OeeReason reason) {
    Icon icon;

    switch (reason.lossCategory) {
      case LossCategory.MINOR_STOPPAGES:
        icon = Icon(Icons.block);
        break;
      case LossCategory.NO_LOSS:
        icon = Icon(Icons.check_circle_outline);
        break;
      case LossCategory.NOT_SCHEDULED:
        icon = Icon(Icons.clear_all);
        break;
      case LossCategory.PLANNED_DOWNTIME:
        icon = Icon(Icons.all_out);
        break;
      case LossCategory.REDUCED_SPEED:
        icon = Icon(Icons.change_history);
        break;
      case LossCategory.REJECT_REWORK:
        icon = Icon(Icons.highlight_off);
        break;
      case LossCategory.SETUP:
        icon = Icon(Icons.mode_edit);
        break;
      case LossCategory.STARTUP_YIELD:
        icon = Icon(Icons.arrow_drop_down_circle);
        break;
      case LossCategory.UNPLANNED_DOWNTIME:
        icon = Icon(Icons.flash_on);
        break;
      case LossCategory.UNSCHEDULED:
        icon = Icon(Icons.do_not_disturb_on);
        break;
    }
    return icon;
  }

  @override
  Widget build(BuildContext context) {
    MaterialApp app = MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: _buildAppBar(),
          body: _buildBody(),
        ),
      ),
    );
    return app;
  }

  Widget _buildAppBar() {
    return AppBar(
        title: Center(
          child: Column(
            children: [
              Text(widget.equipment.toString()),
              Text(widget.equipmentStatus.toString()),
            ],
          ),
        ),
        leading: _getAvailabilityIcon(widget.equipmentStatus.reason),
        bottom: TabBar(
          tabs: [
            Tab(text: 'Availability', icon: Icon(Icons.query_builder)),
            Tab(text: 'Production', icon: Icon(Icons.data_usage)),
            Tab(text: 'Setup/Job', icon: Icon(Icons.settings_applications)),
          ],
        ));
  }

  Widget _buildBody() {
    return TabBarView(children: [
      _buildAvailabilityView(context),
      _buildProductionView(context),
      _buildSetupView(context),
    ]);
  }

  void _showSnackBar(String text) {
    final snackBarContent = SnackBar(
      content: Text(text),
      action: SnackBarAction(
          label: 'Close',
          onPressed: _scaffoldKey.currentState.hideCurrentSnackBar),
    );
    _scaffoldKey.currentState.showSnackBar(snackBarContent);
  }

  _showReasons(BuildContext context) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (ctx) => ReasonPage()));
    selectedReason = OeeExecutionService.getInstance.reason;
  }

  String _getSelectedReason() {
    return selectedReason?.toString() ?? 'no reason selected';
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
              Text(_getSelectedReason()),
            ]),

            // by event or by time period
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Radio(
                value: BY_PERIOD,
                groupValue: _eventTimeValue,
                onChanged: _handleEventTimeChange,
              ),
              Text('By Time Period'),
              Radio(
                value: BY_EVENT,
                groupValue: _eventTimeValue,
                onChanged: _handleEventTimeChange,
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

  Widget _buildProductionView(BuildContext context) {
    Form form = Form(
        key: _productionFormKey,
        autovalidate: true,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          children: <Widget>[
            // reason selection button
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              RaisedButton.icon(
                label: Text('Reason'),
                onPressed: () {
                  _showReasons(context);
                },
                icon: const Icon(Icons.category),
              ),
              SizedBox(width: 20),
              Text(_getSelectedReason()),
            ]),

            // by event or by time period radio buttons
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Radio(
                value: BY_PERIOD,
                groupValue: _eventTimeValue,
                onChanged: _handleEventTimeChange,
              ),
              Text('By Time Period'),
              Radio(
                value: BY_EVENT,
                groupValue: _eventTimeValue,
                onChanged: _handleEventTimeChange,
              ),
              Text('By Event'),
            ]),

            // production type radio buttons
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Radio(
                value: GOOD,
                groupValue: _productionValue,
                onChanged: _handleProductionChange,
              ),
              Text('Good'),
              Radio(
                value: REJECT,
                groupValue: _productionValue,
                onChanged: _handleProductionChange,
              ),
              Text('Reject/Rework'),
              Radio(
                value: STARTUP,
                groupValue: _productionValue,
                onChanged: _handleProductionChange,
              ),
              Text('Reject/Rework'),
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

  void _handleProductionChange(int value) {
    setState(() {
      _productionValue = value;

      switch (_productionValue) {
        case GOOD:
          // good
          break;
        case REJECT:
          // reject and rework
          break;
        case STARTUP:
          // startup and yield
          break;
      }
    });
  }

  // material setup view
  Widget _buildSetupView(BuildContext context) {
    return Icon(Icons.do_not_disturb);
  }
}
