import 'package:flutter/material.dart';
import 'package:oee_mobile/oee_services.dart';
import 'oee_reason_page.dart';
import 'oee_model.dart';
import 'oee_ui_shared.dart';
import 'oee_material_page.dart';

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
  // availability event reason
  OeeReason _availabilityReason;

  // production reason
  OeeReason _productionReason;

  // setup material
  OeeMaterial _selectedMaterial;

  // availability event duration
  String availabilityEventHours;
  String availabilityEventMinutes;

  // availability event duration
  String productionEventHours;
  String productionEventMinutes;

  // keys to get the availability DateTime
  final availabilityStartTimeKey = new GlobalKey<DateTimeWidgetState>();
  final availabilityEndTimeKey = new GlobalKey<DateTimeWidgetState>();

  // keys to get the production DateTime
  final productionStartTimeKey = new GlobalKey<DateTimeWidgetState>();
  final productionEndTimeKey = new GlobalKey<DateTimeWidgetState>();

  // key to get the set up DateTime
  final setupTimeKey = new GlobalKey<DateTimeWidgetState>();

  // form keys
  final GlobalKey<FormState> _availabilityFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _productionFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _setupFormKey = GlobalKey<FormState>();

  // time period settings
  bool showEndTime = true;

  static const int BY_PERIOD = 0;
  static const int BY_EVENT = 1;

  // default availability event time period
  int _availabilityEventTimeValue = BY_PERIOD;

  // default availability event time period
  int _productionEventTimeValue = BY_PERIOD;

  // production count settings
  static const int GOOD = 0;
  static const int REJECT = 1;
  static const int STARTUP = 2;

  // default production type
  int _productionValue = GOOD;
  String _productionUnit = '';
  OeeEventType _productionEventType = OeeEventType.PROD_GOOD;

  final quantityController = TextEditingController();
  double _productionAmount;

  // job
  final jobController = TextEditingController();
  String _job = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onSubmitAvailabilityEvent() {
    final FormState form = _availabilityFormKey.currentState;
    form.save(); //This invokes each onSaved event

    DateTime startTime = availabilityStartTimeKey.currentState?.dateTime;

    // no seconds
    DateTime start = startTime != null
        ? DateTime(startTime.year, startTime.month, startTime.day,
            startTime.hour, startTime.minute)
        : null;

    DateTime end;
    Duration eventDuration;

    if (_availabilityEventTimeValue == BY_PERIOD) {
      DateTime endTime = availabilityEndTimeKey.currentState?.dateTime;

      // no seconds
      end = endTime != null
          ? DateTime(endTime.year, endTime.month, endTime.day, endTime.hour,
              endTime.minute)
          : null;

      int intHours =
          (availabilityEventHours != null && availabilityEventHours.length > 0)
              ? int.parse(availabilityEventHours)
              : 0;
      int intMinutes = (availabilityEventMinutes != null &&
              availabilityEventMinutes.length > 0)
          ? int.parse(availabilityEventMinutes)
          : 0;
      eventDuration = Duration(hours: intHours, minutes: intMinutes);
    }

    OeeEvent availabilityEvent = OeeEvent(widget.equipment, start);
    availabilityEvent.duration = eventDuration;
    availabilityEvent.endTime = end;
    availabilityEvent.reason = _availabilityReason;
    availabilityEvent.eventType = OeeEventType.AVAILABILITY;

    Future<String> future =
        OeeHttpService.getInstance.postEquipmentEvent(availabilityEvent);

    future.then((value) {
      if (value.isEmpty) {
        _showSnackBar("Availability event recorded.");
      } else {
        UIUtils.showAlert(context, "Error", value);
      }
    });
  }

  void _handleEventTimeChange(int value) {
    setState(() {
      _availabilityEventTimeValue = value;

      switch (_availabilityEventTimeValue) {
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

    if (reason == null) {
      return Icon(Icons.error);
    }

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

  _showAvailabilityReasons(BuildContext context) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (ctx) => ReasonPage(true)));
    _availabilityReason = OeeExecutionService.getInstance.availabilityReason;

    // update state
    setState(() {});
  }

  _showProductionReasons(BuildContext context) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (ctx) => ReasonPage(false)));
    _productionReason = OeeExecutionService.getInstance.productionReason;

    // update state
    setState(() {});
  }

  _showMaterials(BuildContext context) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (ctx) => MaterialPage()));
    _selectedMaterial = OeeExecutionService.getInstance.setupMaterial;

    // update state
    setState(() {});
  }

  String _getAvailabilityReason() {
    return _availabilityReason?.toString() ?? 'no reason selected';
  }

  String _getProductionReason() {
    return _productionReason?.toString() ?? 'no reason selected';
  }

  String _getSelectedMaterial() {
    return _selectedMaterial?.toString() ?? 'no material selected';
  }

  Widget _buildAvailabilityView(BuildContext context) {
    return Form(
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
                  _showAvailabilityReasons(context);
                },
                icon: const Icon(Icons.category),
              ),
              SizedBox(width: 20),
              Text(_getAvailabilityReason()),
            ]),

            // by event or by time period
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Radio(
                value: BY_PERIOD,
                groupValue: _availabilityEventTimeValue,
                onChanged: _handleEventTimeChange,
              ),
              Text('By Time Period'),
              Radio(
                value: BY_EVENT,
                groupValue: _availabilityEventTimeValue,
                onChanged: _handleEventTimeChange,
              ),
              Text('By Event'),
            ]),

            // event start date and time
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              SizedBox(child: Text('Start Time'), width: 100),
              Expanded(child: DateTimeWidget(key: availabilityStartTimeKey)),
              SizedBox(width: 195),
            ]),

            // event end date and time
            Visibility(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(child: Text('End Time'), width: 100),
                      Expanded(
                          child: DateTimeWidget(key: availabilityEndTimeKey)),
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
                              availabilityEventHours = value;
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
                              availabilityEventMinutes = value;
                            },
                          ),
                          width: 50),
                    ]),
                visible: showEndTime),
            Container(
                padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                child: RaisedButton.icon(
                  label: const Text('Submit'),
                  onPressed: _onSubmitAvailabilityEvent,
                  icon: const Icon(Icons.check_circle_outline),
                )),
          ],
        ));
  }

  Widget _buildProductionView(BuildContext context) {
    return Form(
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
                  _showProductionReasons(context);
                },
                icon: const Icon(Icons.category),
              ),
              SizedBox(width: 20),
              Text(_getProductionReason()),
            ]),

            // by event or by time period radio buttons
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Radio(
                value: BY_PERIOD,
                groupValue: _productionEventTimeValue,
                onChanged: _handleEventTimeChange,
              ),
              Text('By Time Period'),
              Radio(
                value: BY_EVENT,
                groupValue: _productionEventTimeValue,
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

            // amount of production
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              SizedBox(
                  child: TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      filled: true,
                      icon: Icon(Icons.confirmation_number),
                      hintText: 'Enter amount',
                      labelText: 'Amount *',
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (String value) {
                      this._productionAmount = double.parse(value);
                    },
                    validator: _validateAmount,
                  ),
                  width: 150),
              SizedBox(width: 20),
              Text(_productionUnit),
              //
            ]),

            // event start date and time
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              SizedBox(child: Text('Start Time'), width: 100),
              Expanded(child: DateTimeWidget(key: productionStartTimeKey)),
              SizedBox(width: 195),
            ]),

            // event end date and time
            Visibility(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(child: Text('End Time'), width: 100),
                      Expanded(
                          child: DateTimeWidget(key: productionEndTimeKey)),
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
                              productionEventHours = value;
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
                              productionEventMinutes = value;
                            },
                          ),
                          width: 50),
                    ]),
                visible: showEndTime),
            Container(
                padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                child: RaisedButton.icon(
                  label: const Text('Submit'),
                  onPressed: _onSubmitProductionEvent,
                  icon: const Icon(Icons.check_circle_outline),
                )),
          ],
        ));
  }

  void _onSubmitProductionEvent() {
    final FormState form = _productionFormKey.currentState;
    form.save(); //This invokes each onSaved event

    DateTime startTime = productionStartTimeKey.currentState?.dateTime;

    // no seconds
    DateTime start = startTime != null
        ? DateTime(startTime.year, startTime.month, startTime.day,
            startTime.hour, startTime.minute)
        : null;

    DateTime end;
    Duration eventDuration;

    if (_productionEventTimeValue == BY_PERIOD) {
      DateTime endTime = productionEndTimeKey.currentState?.dateTime;

      // no seconds
      end = endTime != null
          ? DateTime(endTime.year, endTime.month, endTime.day, endTime.hour,
              endTime.minute)
          : null;

      int intHours =
          (productionEventHours != null && productionEventHours.length > 0)
              ? int.parse(productionEventHours)
              : 0;
      int intMinutes =
          (productionEventMinutes != null && productionEventMinutes.length > 0)
              ? int.parse(productionEventMinutes)
              : 0;
      eventDuration = Duration(hours: intHours, minutes: intMinutes);
    }

    OeeEvent productionEvent = OeeEvent(widget.equipment, start);
    productionEvent.duration = eventDuration;
    productionEvent.endTime = end;
    productionEvent.reason = _productionReason;
    productionEvent.eventType = _productionEventType;
    productionEvent.amount = _productionAmount;

    OeeHttpService.getInstance.postEquipmentEvent(productionEvent);

    _showSnackBar("Production event recorded.");
  }

  String _validateAmount(String value) {
    if (value.isEmpty) return 'Production amount is required.';
    return null;
  }

  void _handleProductionChange(int value) {
    setState(() {
      _productionValue = value;

      switch (_productionValue) {
        case GOOD:
          // good
          _productionUnit = widget.equipmentStatus.runRateUOM ?? '';
          _productionEventType = OeeEventType.PROD_GOOD;
          break;
        case REJECT:
          // reject and rework
          _productionUnit = widget.equipmentStatus.rejectUOM ?? '';
          _productionEventType = OeeEventType.PROD_REJECT;
          break;
        case STARTUP:
          // startup and yield
          _productionUnit = widget.equipmentStatus.rejectUOM ?? '';
          _productionEventType = OeeEventType.PROD_STARTUP;
          break;
      }
    });
  }

  // material setup view
  Widget _buildSetupView(BuildContext context) {
    return Form(
        key: _setupFormKey,
        autovalidate: true,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          children: <Widget>[
            // material selection button
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              RaisedButton.icon(
                label: Text('Material'),
                onPressed: () {
                  // TODO
                  _showMaterials(context);
                },
                icon: const Icon(Icons.group_work),
              ),
              SizedBox(width: 20),
              Text(_getSelectedMaterial()),
            ]),

            // job
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              SizedBox(
                  child: TextFormField(
                    controller: jobController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      filled: true,
                      icon: Icon(Icons.build),
                      hintText: 'Job Id',
                      labelText: 'Job',
                    ),
                    keyboardType: TextInputType.text,
                    onSaved: (String value) {
                      this._job = value;
                    },
                  ),
                  width: 250),
              //
            ]),

            // record event
            Container(
                padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                child: RaisedButton.icon(
                  label: const Text('Submit'),
                  onPressed: _onSubmitSetupEvent,
                  icon: const Icon(Icons.check_circle_outline),
                )),
          ],
        ));
  }

  void _onSubmitSetupEvent() {
    final FormState form = _setupFormKey.currentState;
    form.save(); //This invokes each onSaved event

    DateTime startTime = setupTimeKey.currentState?.dateTime;

    // no seconds
    DateTime start = startTime != null
        ? DateTime(startTime.year, startTime.month, startTime.day,
            startTime.hour, startTime.minute)
        : null;
    OeeEvent setupEvent = OeeEvent(widget.equipment, start);

    setupEvent.eventType = OeeEventType.MATL_CHANGE;
    if (_selectedMaterial == null) {
      setupEvent.eventType = OeeEventType.JOB_CHANGE;
    }

    // material
    setupEvent.material = _selectedMaterial ?? widget.equipmentStatus.material;

    // job
    setupEvent.job = _job;

    OeeHttpService.getInstance.postEquipmentEvent(setupEvent);

    _showSnackBar("Setup event recorded.");
  }
}
