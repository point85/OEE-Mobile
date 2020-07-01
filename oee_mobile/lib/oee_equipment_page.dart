import 'package:flutter/material.dart';
import 'package:oee_mobile/oee_http_service.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'oee_reason_page.dart';
import 'oee_model.dart';
import 'oee_ui_shared.dart';
import 'oee_material_page.dart';
import 'oee_localization.dart';

// manages the availability, performance and setup of equipment
class EquipmentEventPage extends StatefulWidget {
  // equipment
  final OeeEntity equipment;

  // equipment status
  final OeeEquipmentStatus initialEquipmentStatus;

  EquipmentEventPage({this.equipment, this.initialEquipmentStatus});

  @override
  _EquipmentEventPageState createState() =>
      _EquipmentEventPageState(initialEquipmentStatus);
}

class _EquipmentEventPageState extends State<EquipmentEventPage> {
  // equipment status
  OeeEquipmentStatus equipmentStatus;

  // access to reason state
  final reasonStateKey = GlobalKey<ReasonPageState>();

  // access to material state
  final materialStateKey = GlobalKey<MaterialPageState>();

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
  bool showAvailabilityEndTime = true;
  bool showProductionEndTime = true;

  static const int BY_PERIOD = 0;
  static const int BY_EVENT = 1;

  // default availability event time period
  int _availabilityEventTimeValue = BY_PERIOD;

  // default availability event time period
  int _productionEventTimeValue = BY_PERIOD;

  // production count settings
  static const int GOOD_AMOUNT = 0;
  static const int REJECT_AMOUNT = 1;
  static const int STARTUP_AMOUNT = 2;

  // default production type
  int _productionValue;
  String _productionUnit = '';
  OeeEventType _productionEventType = OeeEventType.PROD_GOOD;

  final quantityController = TextEditingController();
  double _productionAmount;

  // job
  final jobController = TextEditingController();
  String _job = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _EquipmentEventPageState(this.equipmentStatus);

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
    form.save();

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

    // show a progress dialog
    ProgressDialog dialog = ProgressDialog(context);
    dialog.style(
        message: AppLocalizations.of(context).translate('equip.avail.start'));
    Future<bool> isShowing = dialog.show();

    // send the equipment event
    Future<bool> future =
        OeeHttpService.getInstance.postEquipmentEvent(availabilityEvent);

    future.then((ok) {
      // hide progress dialog and show completion
      isShowing.whenComplete(() => dialog.hide());

      _refreshEquipmentStatus();

      _showSnackBar(AppLocalizations.of(context).translate('equip.avail.done'));
    }, onError: (error) {
      isShowing.whenComplete(() => dialog.hide().whenComplete(() {
            EquipmentEventResponseDto dto =
                EquipmentEventResponseDto.fromResponseBody('$error');
            UIUtils.showErrorDialog(context, dto.errorText);
            isShowing.whenComplete(() => dialog.hide());
          }));
    });
  }

  void _handleAvailabilityTimeChange(int value) {
    setState(() {
      _availabilityEventTimeValue = value;

      switch (_availabilityEventTimeValue) {
        case BY_PERIOD:
          showAvailabilityEndTime = true;
          break;
        case BY_EVENT:
          showAvailabilityEndTime = false;
          break;
      }
    });
  }

  void _handleProductionTimeChange(int value) {
    setState(() {
      _productionEventTimeValue = value;

      switch (_productionEventTimeValue) {
        case BY_PERIOD:
          showProductionEndTime = true;
          break;
        case BY_EVENT:
          showProductionEndTime = false;
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
              Text(equipmentStatus.toString()),
            ],
          ),
        ),
        leading: _getAvailabilityIcon(equipmentStatus.reason),
        bottom: TabBar(
          tabs: [
            Tab(
                text: AppLocalizations.of(context).translate('equip.tab.avail'),
                icon: Icon(Icons.query_builder)),
            Tab(
                text: AppLocalizations.of(context).translate('equip.tab.prod'),
                icon: Icon(Icons.data_usage)),
            Tab(
                text: AppLocalizations.of(context).translate('equip.tab.setup'),
                icon: Icon(Icons.settings_applications)),
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
          label: AppLocalizations.of(context).translate('button.close'),
          onPressed: _scaffoldKey.currentState.hideCurrentSnackBar),
    );
    _scaffoldKey.currentState.showSnackBar(snackBarContent);
  }

  _showAvailabilityReasons(BuildContext context) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (ctx) => ReasonPage(key: reasonStateKey)));

    _availabilityReason = reasonStateKey.currentState.reason;

    // update state
    setState(() {});
  }

  _showProductionReasons(BuildContext context) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (ctx) => ReasonPage(key: reasonStateKey)));
    _productionReason = reasonStateKey.currentState.reason;

    // update state
    setState(() {});
  }

  _showMaterials(BuildContext context) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (ctx) => MaterialPage(key: materialStateKey)));
    _selectedMaterial = materialStateKey.currentState.material;

    // update state
    setState(() {});
  }

  String _getAvailabilityReason() {
    return _availabilityReason?.toString() ??
        AppLocalizations.of(context).translate('equip.no.reason');
  }

  String _getProductionReason() {
    return _productionReason?.toString() ??
        AppLocalizations.of(context).translate('equip.no.reason');
  }

  String _getSelectedMaterial() {
    return _selectedMaterial?.toString() ??
        AppLocalizations.of(context).translate('equip.no.material');
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
                label: Text(
                    AppLocalizations.of(context).translate('equip.reason')),
                onPressed: () {
                  _showAvailabilityReasons(context);
                },
                icon: const Icon(Icons.category),
              ),
              SizedBox(width: 20),
              Expanded(child: Text(_getAvailabilityReason())),
            ]),

            // by event or by time period
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Radio(
                value: BY_PERIOD,
                groupValue: _availabilityEventTimeValue,
                onChanged: _handleAvailabilityTimeChange,
              ),
              Text(AppLocalizations.of(context).translate('equip.time.period')),
              Radio(
                value: BY_EVENT,
                groupValue: _availabilityEventTimeValue,
                onChanged: _handleAvailabilityTimeChange,
              ),
              Text(AppLocalizations.of(context).translate('equip.event')),
            ]),

            // event start date and time
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              SizedBox(
                  child: Text(
                      AppLocalizations.of(context).translate('equip.start')),
                  width: 100),
              Expanded(child: DateTimeWidget(key: availabilityStartTimeKey)),
            ]),

            // event end date and time
            Visibility(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                          child: Text(AppLocalizations.of(context)
                              .translate('equip.end')),
                          width: 100),
                      Expanded(
                          child: DateTimeWidget(key: availabilityEndTimeKey)),
                    ]),
                visible: showAvailabilityEndTime),
            Visibility(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                          child: Text(AppLocalizations.of(context)
                              .translate('equip.duration')),
                          width: 75),
                      SizedBox(
                          child: TextFormField(
                            decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)
                                    .translate('equip.hrs')),
                            keyboardType: TextInputType.number,
                            onSaved: (String value) {
                              availabilityEventHours = value;
                            },
                          ),
                          width: 75),
                      SizedBox(width: 20),
                      SizedBox(
                          child: TextFormField(
                            decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)
                                    .translate('equip.mins')),
                            keyboardType: TextInputType.number,
                            onSaved: (String value) {
                              availabilityEventMinutes = value;
                            },
                          ),
                          width: 75),
                      //SizedBox(width: 20),
                    ]),
                visible: showAvailabilityEndTime),

            Container(
                padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                child: RaisedButton.icon(
                  label: Text(
                      AppLocalizations.of(context).translate('equip.submit')),
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
                label: Text(
                    AppLocalizations.of(context).translate('equip.reason')),
                onPressed: () {
                  _showProductionReasons(context);
                },
                icon: const Icon(Icons.category),
              ),
              SizedBox(width: 20),
              Expanded(child: Text(_getProductionReason())),
            ]),

            // by event or by time period radio buttons
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Radio(
                value: BY_PERIOD,
                groupValue: _productionEventTimeValue,
                onChanged: _handleProductionTimeChange,
              ),
              Text(AppLocalizations.of(context).translate('equip.time.period')),
              Radio(
                value: BY_EVENT,
                groupValue: _productionEventTimeValue,
                onChanged: _handleProductionTimeChange,
              ),
              Text(AppLocalizations.of(context).translate('equip.event')),
            ]),

            // production type radio buttons
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Radio(
                value: GOOD_AMOUNT,
                groupValue: _productionValue,
                onChanged: _handleProductionChange,
              ),
              Text(AppLocalizations.of(context).translate('equip.good')),
              Radio(
                value: REJECT_AMOUNT,
                groupValue: _productionValue,
                onChanged: _handleProductionChange,
              ),
              Text(AppLocalizations.of(context).translate('equip.reject')),
              Radio(
                value: STARTUP_AMOUNT,
                groupValue: _productionValue,
                onChanged: _handleProductionChange,
              ),
              Text(AppLocalizations.of(context).translate('equip.startup')),
            ]),

            // amount of production
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              SizedBox(
                  child: TextFormField(
                    controller: quantityController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      filled: true,
                      icon: Icon(Icons.confirmation_number),
                      hintText: AppLocalizations.of(context)
                          .translate('equip.amount.hint'),
                      labelText: AppLocalizations.of(context)
                          .translate('equip.amount.label'),
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (String value) {
                      _productionAmount = double.tryParse(value) ?? 0;
                    },
                  ),
                  width: 200),
              SizedBox(width: 20),
              Text(_productionUnit),
            ]),

            // event start date and time
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              SizedBox(
                  child: Text(
                      AppLocalizations.of(context).translate('equip.start')),
                  width: 100),
              Expanded(child: DateTimeWidget(key: productionStartTimeKey)),
            ]),

            // event end date and time
            Visibility(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                          child: Text(AppLocalizations.of(context)
                              .translate('equip.end')),
                          width: 100),
                      Expanded(
                          child: DateTimeWidget(key: productionEndTimeKey)),
                    ]),
                visible: showProductionEndTime),
            Container(
                padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                child: RaisedButton.icon(
                  label: Text(
                      AppLocalizations.of(context).translate('equip.submit')),
                  onPressed: _onSubmitProductionEvent,
                  icon: const Icon(Icons.check_circle_outline),
                )),
          ],
        ));
  }

  void _onSubmitProductionEvent() {
    final FormState form = _productionFormKey.currentState;
    form.save();

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

    // show progress dialog
    ProgressDialog dialog = ProgressDialog(context);
    dialog.style(
        message: AppLocalizations.of(context).translate('equip.prod.start'));
    Future<bool> isShowing = dialog.show();

    // invoke API
    Future<bool> future =
        OeeHttpService.getInstance.postEquipmentEvent(productionEvent);

    future.then((ok) {
      // hide progress dialog and show completion
      isShowing.whenComplete(() => dialog.hide());

      _showSnackBar(AppLocalizations.of(context).translate('equip.prod.done'));
    }, onError: (error) {
      isShowing.whenComplete(() => dialog.hide().whenComplete(() {
            EquipmentEventResponseDto dto =
                EquipmentEventResponseDto.fromResponseBody('$error');
            UIUtils.showErrorDialog(context, dto.errorText);
          }));
    });
  }

  void _handleProductionChange(int value) {
    setState(() {
      _productionValue = value;

      switch (_productionValue) {
        case GOOD_AMOUNT:
          // good
          _productionUnit = equipmentStatus.runRateUOM ?? '';
          _productionEventType = OeeEventType.PROD_GOOD;
          break;
        case REJECT_AMOUNT:
          // reject and rework
          _productionUnit = equipmentStatus.rejectUOM ?? '';
          _productionEventType = OeeEventType.PROD_REJECT;
          break;
        case STARTUP_AMOUNT:
          // startup and yield
          _productionUnit = equipmentStatus.rejectUOM ?? '';
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
                label: Text(
                    AppLocalizations.of(context).translate('equip.material')),
                onPressed: () {
                  _showMaterials(context);
                },
                icon: const Icon(Icons.group_work),
              ),
              SizedBox(width: 20),
              Expanded(child: Text(_getSelectedMaterial())),
            ]),

            // job
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              SizedBox(
                  child: TextFormField(
                    controller: jobController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      filled: true,
                      icon: Icon(Icons.build),
                      hintText: AppLocalizations.of(context)
                          .translate('equip.job.hint'),
                      labelText: AppLocalizations.of(context)
                          .translate('equip.job.label'),
                    ),
                    keyboardType: TextInputType.text,
                    onSaved: (String value) {
                      this._job = value;
                    },
                  ),
                  width: 250),
            ]),

            // event start date and time
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              SizedBox(
                  child: Text(
                      AppLocalizations.of(context).translate('equip.start')),
                  width: 100),
              Expanded(child: DateTimeWidget(key: setupTimeKey)),
            ]),

            // record event
            Container(
                padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                child: RaisedButton.icon(
                  label: Text(
                      AppLocalizations.of(context).translate('equip.submit')),
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
    setupEvent.material = _selectedMaterial ?? equipmentStatus.material;

    // job
    setupEvent.job = _job;

    // show progress dialog
    ProgressDialog dialog = ProgressDialog(context);
    dialog.style(
        message: AppLocalizations.of(context).translate('equip.setup.start'));
    Future<bool> isShowing = dialog.show();

    // invoke API
    Future<bool> future =
        OeeHttpService.getInstance.postEquipmentEvent(setupEvent);

    future.then((ok) {
      // hide progress dialog
      isShowing.whenComplete(() => dialog.hide());

      _refreshEquipmentStatus();

      _showSnackBar(AppLocalizations.of(context).translate('equip.setup.done'));
    }, onError: (error) {
      isShowing.whenComplete(() => dialog.hide().whenComplete(() {
            EquipmentEventResponseDto dto =
                EquipmentEventResponseDto.fromResponseBody('$error');
            UIUtils.showErrorDialog(context, dto.errorText);
          }));
    });
  }

  void _refreshEquipmentStatus() async {
    // fetch status from the database
    OeeEquipmentStatus status =
        await OeeHttpService.getInstance.fetchEquipmentStatus(widget.equipment);

    setState(() {
      equipmentStatus = status;
    });
  }
}
