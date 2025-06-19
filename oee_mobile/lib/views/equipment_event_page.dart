import 'package:flutter/material.dart';
import 'package:oee_mobile/l10n/app_localizations.dart';
import 'package:oee_mobile/views/tree_nodes.dart';
import '../services/http_service.dart';
import '../models/oee_entity.dart';
import '../models/oee_equipment_status.dart';
import '../models/oee_reason.dart';
import '../models/oee_event.dart';
import 'date_time_widget.dart';
import 'common.dart';
import 'material_page.dart';
import 'reason_page.dart';

// manages the availability, performance and setup of equipment
class EquipmentEventPage extends StatefulWidget {
  // equipment name
  final OeeEntityNode _equipmentNode;

  // equipment status
  final OeeEquipmentStatus status;

  const EquipmentEventPage(
      {super.key, required OeeEntityNode equipment, required this.status})
      : _equipmentNode = equipment;

  @override
  // ignore: no_logic_in_create_state
  EquipmentEventPageState createState() => EquipmentEventPageState(status);
}

class EquipmentEventPageState extends State<EquipmentEventPage> {
  // equipment status
  OeeEquipmentStatus _equipmentStatus;

  // access to reason state
  final _reasonStateKey = GlobalKey<OeeReasonPageState>();

  // access to material state
  final _materialStateKey = GlobalKey<OeeMaterialPageState>();

  // availability event reason
  OeeReasonNode? _availabilityReasonNode;

  // production reason
  OeeReasonNode? _productionReasonNode;

  // setup material
  OeeMaterialNode? _materialNode;

  // availability event duration
  String? _availabilityEventHours;
  String? _availabilityEventMinutes;

  // availability event duration
  String? _productionEventHours;
  String? _productionEventMinutes;

  // keys to get the availability DateTime
  final _availabilityStartTimeKey = GlobalKey<DateTimeWidgetState>();
  final _availabilityEndTimeKey = GlobalKey<DateTimeWidgetState>();

  // keys to get the production DateTime
  final _productionStartTimeKey = GlobalKey<DateTimeWidgetState>();
  final _productionEndTimeKey = GlobalKey<DateTimeWidgetState>();

  // key to get the set up DateTime
  final _setupTimeKey = GlobalKey<DateTimeWidgetState>();

  // form keys
  final GlobalKey<FormState> _availabilityFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _productionFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _setupFormKey = GlobalKey<FormState>();

  // time period settings
  bool _showAvailabilityEndTime = true;
  bool _showProductionEndTime = true;

  static const int _byPeriod = 0;
  static const int _byEvent = 1;

  // default availability event time period
  int _availabilityEventTimeValue = _byPeriod;

  // default availability event time period
  int _productionEventTimeValue = _byPeriod;

  // production count settings
  static const int _goodAmount = 0;
  static const int _rejectAmount = 1;
  static const int _startupAmount = 2;

  // default production type
  int? _productionValue;
  String _productionUnit = '';
  OeeEventType? _productionEventType;
  //= OeeEventType.prodGood;

  final _quantityController = TextEditingController();
  double _productionAmount = 0.0;

  // job
  final _jobController = TextEditingController();
  String _job = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  EquipmentEventPageState(this._equipmentStatus);

  void _onSubmitAvailabilityEvent() {
    final FormState? form = _availabilityFormKey.currentState;
    form!.save();

    DateTime? startTime = _availabilityStartTimeKey.currentState?.value;

    // no seconds
    DateTime start = startTime != null
        ? DateTime(startTime.year, startTime.month, startTime.day,
            startTime.hour, startTime.minute)
        : DateTime.now();

    DateTime? end;
    Duration? eventDuration;

    if (_availabilityEventTimeValue == _byPeriod) {
      try {
        DateTime? endTime = _availabilityEndTimeKey.currentState?.value;

        // no seconds
        end = (endTime != null
            ? DateTime(endTime.year, endTime.month, endTime.day, endTime.hour,
                endTime.minute)
            : null)!;

        int intHours = (_availabilityEventHours != null &&
                _availabilityEventHours!.isNotEmpty)
            ? int.parse(_availabilityEventHours!)
            : 0;
        int intMinutes = (_availabilityEventMinutes != null &&
                _availabilityEventMinutes!.isNotEmpty)
            ? int.parse(_availabilityEventMinutes!)
            : 0;
        eventDuration = Duration(hours: intHours, minutes: intMinutes);

        if (eventDuration.isNegative) {
          UIUtils.showErrorDialog(
              context,
              AppLocalizations.of(context)!
                  .errInvalidDuration(eventDuration.toString()));
          return;
        }
      } catch (e) {
        UIUtils.showErrorDialog(context, e.toString());
        return;
      }
    }

    OeeEvent availabilityEvent = OeeEvent(
        equipment: widget._equipmentNode.name,
        startTime: start,
        eventType: OeeEventType.availability);
    availabilityEvent.duration = eventDuration;
    availabilityEvent.endTime = end;
    availabilityEvent.reason = _availabilityReasonNode?.name;

    // post the equipment event
    Future<bool> future = HttpService().postEquipmentEvent(availabilityEvent);

    future.then((ok) {
      _refreshEquipmentStatus();

      if (!mounted) return;

      UIUtils.showInfoDialog(
          context, AppLocalizations.of(context)!.equipAvailDone);
    }, onError: (error) {
      EquipmentEventResponse response =
          EquipmentEventResponse.fromResponseBody('$error');

      if (!mounted) return;

      UIUtils.showErrorDialog(context, response.errorText);
    });
  }

  void _handleAvailabilityTimeChange(int? value) {
    setState(() {
      _availabilityEventTimeValue = value!;

      switch (_availabilityEventTimeValue) {
        case _byPeriod:
          _showAvailabilityEndTime = true;
          break;
        case _byEvent:
          _showAvailabilityEndTime = false;
          break;
      }
    });
  }

  void _handleProductionTimeChange(int? value) {
    setState(() {
      _productionEventTimeValue = value!;

      switch (_productionEventTimeValue) {
        case _byPeriod:
          _showProductionEndTime = true;
          break;
        case _byEvent:
          _showProductionEndTime = false;
          break;
      }
    });
  }

  Icon _getAvailabilityIcon(OeeReason? reason) {
    Icon icon = const Icon(Icons.error, size: 32, color: Colors.red);

    if (reason == null) {
      return icon;
    }

    double size = 32;
    Color color = Colors.white;

    switch (reason.lossCategory) {
      case LossCategory.minorStoppages:
        icon = Icon(Icons.block, size: size, color: color);
        break;
      case LossCategory.noLoss:
        icon = Icon(Icons.check_circle_outline, size: size, color: color);
        break;
      case LossCategory.notScheduled:
        icon = Icon(Icons.clear_all, size: size, color: color);
        break;
      case LossCategory.plannedDowntime:
        icon = Icon(Icons.all_out, size: size, color: color);
        break;
      case LossCategory.reducedSpeed:
        icon = Icon(Icons.change_history, size: size, color: color);
        break;
      case LossCategory.rejectRework:
        icon = Icon(Icons.highlight_off, size: size, color: color);
        break;
      case LossCategory.setup:
        icon = Icon(Icons.mode_edit, size: size, color: color);
        break;
      case LossCategory.startupYield:
        icon = Icon(Icons.arrow_drop_down_circle, size: size, color: color);
        break;
      case LossCategory.unplannedDowntime:
        icon = Icon(Icons.flash_on, size: size, color: color);
        break;
      case LossCategory.unscheduled:
        icon = Icon(Icons.do_not_disturb_on, size: size, color: color);
        break;
    }
    return icon;
  }

  @override
  Widget build(BuildContext context) {
    MaterialApp app = MaterialApp(
      debugShowCheckedModeBanner: false,
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
        title: Center(
          child: Column(
            children: [
              Text(widget._equipmentNode.toString(),
                  style: const TextStyle(color: Colors.white)),
              Text(_equipmentStatus.toString(),
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 48, color: Colors.white),
          onPressed: () => Navigator.pop(context, false),
        ),
        actions: [
          _getAvailabilityIcon(_equipmentStatus.reason),
        ],
        bottom: TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
          tabs: [
            Tab(
                text: AppLocalizations.of(context)!.equipTabAvail,
                icon: const Icon(Icons.query_builder)),
            Tab(
                text: AppLocalizations.of(context)!.equipTabProd,
                icon: const Icon(Icons.data_usage)),
            Tab(
                text: AppLocalizations.of(context)!.equipTabSetup,
                icon: const Icon(Icons.settings_applications)),
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

  void _showAvailabilityReasons(BuildContext context) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (ctx) => OeeReasonPage(key: _reasonStateKey)));

    final selectedNode = _reasonStateKey.currentState!.selectedNode;

    if (selectedNode != null) {
      _availabilityReasonNode = selectedNode.data;
    }

    // update state
    setState(() {});
  }

  void _showProductionReasons(BuildContext context) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (ctx) => OeeReasonPage(key: _reasonStateKey)));

    final selectedNode = _reasonStateKey.currentState!.selectedNode;
    if (selectedNode != null) {
      _productionReasonNode = selectedNode.data;
    }

    // update state
    setState(() {});
  }

  void _showMaterials(BuildContext context) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (ctx) => OeeMaterialPage(
                key: _materialStateKey,
                equipment: widget._equipmentNode.name)));

    final selectedNode = _materialStateKey.currentState!.selectedNode;

    if (selectedNode != null) {
      _materialNode = selectedNode.data;
    }

    // update state
    setState(() {});
  }

  String _getAvailabilityReason() {
    return _availabilityReasonNode?.toString() ??
        AppLocalizations.of(context)!.equipNoReason;
  }

  String _getProductionReason() {
    return _productionReasonNode?.toString() ??
        AppLocalizations.of(context)!.equipNoReason;
  }

  String _getSelectedMaterial() {
    return _materialNode?.toString() ??
        AppLocalizations.of(context)!.equipNoMaterial;
  }

  Widget _buildAvailabilityView(BuildContext context) {
    return Form(
        key: _availabilityFormKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          children: <Widget>[
            // reason selection
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              ElevatedButton.icon(
                label: Text(AppLocalizations.of(context)!.equipReason),
                onPressed: () {
                  _showAvailabilityReasons(context);
                },
                icon: const Icon(Icons.category),
              ),
              const SizedBox(width: 20),
              Expanded(
                  child: Text(_getAvailabilityReason(),
                      overflow: TextOverflow.ellipsis)),
            ]),

            // by event or by time period
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Radio(
                value: _byPeriod,
                groupValue: _availabilityEventTimeValue,
                onChanged: _handleAvailabilityTimeChange,
              ),
              Text(AppLocalizations.of(context)!.equipTimePeriod),
              Radio(
                value: _byEvent,
                groupValue: _availabilityEventTimeValue,
                onChanged: _handleAvailabilityTimeChange,
              ),
              Text(AppLocalizations.of(context)!.equipEvent),
            ]),

            // event start date and time
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              SizedBox(
                  width: 100,
                  child: Text(AppLocalizations.of(context)!.equipStart)),
              Expanded(child: DateTimeWidget(key: _availabilityStartTimeKey)),
            ]),

            // event end date and time
            Visibility(
                visible: _showAvailabilityEndTime,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                          width: 100,
                          child: Text(AppLocalizations.of(context)!.equipEnd)),
                      Expanded(
                          child: DateTimeWidget(key: _availabilityEndTimeKey)),
                    ])),
            Visibility(
                visible: _showAvailabilityEndTime,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                          width: 75,
                          child: Text(
                              AppLocalizations.of(context)!.equipDuration)),
                      SizedBox(
                          width: 75,
                          child: TextFormField(
                            decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.equipHrs),
                            keyboardType: TextInputType.number,
                            onSaved: (String? value) {
                              _availabilityEventHours = value;
                            },
                          )),
                      const SizedBox(width: 20),
                      SizedBox(
                          width: 75,
                          child: TextFormField(
                            decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.equipMins),
                            keyboardType: TextInputType.number,
                            onSaved: (String? value) {
                              _availabilityEventMinutes = value;
                            },
                          )),
                      //SizedBox(width: 20),
                    ])),

            Container(
                padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                child: ElevatedButton.icon(
                  label: Text(AppLocalizations.of(context)!.equipSubmit),
                  onPressed: _onSubmitAvailabilityEvent,
                  icon: const Icon(Icons.check_circle_outline),
                  style: UIUtils.getSubmitStyle(context),
                )),
          ],
        ));
  }

  Widget _buildProductionView(BuildContext context) {
    return Form(
        key: _productionFormKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          children: <Widget>[
            // reason selection button
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              ElevatedButton.icon(
                label: Text(AppLocalizations.of(context)!.equipReason),
                onPressed: () {
                  _showProductionReasons(context);
                },
                icon: const Icon(Icons.edit),
              ),
              const SizedBox(width: 20),
              Expanded(
                  child: Text(
                _getProductionReason(),
                overflow: TextOverflow.ellipsis,
              )),
            ]),

            // by event or by time period radio buttons
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Radio(
                value: _byPeriod,
                groupValue: _productionEventTimeValue,
                onChanged: _handleProductionTimeChange,
              ),
              Text(AppLocalizations.of(context)!.equipTimePeriod),
              Radio(
                value: _byEvent,
                groupValue: _productionEventTimeValue,
                onChanged: _handleProductionTimeChange,
              ),
              Text(AppLocalizations.of(context)!.equipEvent),
            ]),

            // production type radio buttons
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Radio(
                value: _goodAmount,
                groupValue: _productionValue,
                onChanged: _handleProductionChange,
              ),
              Text(AppLocalizations.of(context)!.equipGood),
              Radio(
                value: _rejectAmount,
                groupValue: _productionValue,
                onChanged: _handleProductionChange,
              ),
              Text(AppLocalizations.of(context)!.equipReject),
              Radio(
                value: _startupAmount,
                groupValue: _productionValue,
                onChanged: _handleProductionChange,
              ),
              Text(AppLocalizations.of(context)!.equipStartup),
            ]),

            // amount of production
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              SizedBox(
                  width: 150,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      filled: true,
                      icon: const Icon(Icons.confirmation_number),
                      hintText: AppLocalizations.of(context)!.equipAmountHint,
                      labelText: AppLocalizations.of(context)!.equipAmountLabel,
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (String? value) {
                      _productionAmount = double.tryParse(value!) ?? 0;
                    },
                  )),
              const SizedBox(width: 20),
              Text(_productionUnit, overflow: TextOverflow.ellipsis),
            ]),

            // event start date and time
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              SizedBox(
                  width: 100,
                  child: Text(AppLocalizations.of(context)!.equipStart)),
              Expanded(child: DateTimeWidget(key: _productionStartTimeKey)),
            ]),

            // event end date and time
            Visibility(
                visible: _showProductionEndTime,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                          width: 100,
                          child: Text(AppLocalizations.of(context)!.equipEnd)),
                      Expanded(
                          child: DateTimeWidget(key: _productionEndTimeKey)),
                    ])),
            Container(
                padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                child: ElevatedButton.icon(
                  label: Text(AppLocalizations.of(context)!.equipSubmit),
                  onPressed: _onSubmitProductionEvent,
                  icon: const Icon(Icons.check_circle_outline),
                  style: UIUtils.getSubmitStyle(context),
                )),
          ],
        ));
  }

  void _onSubmitProductionEvent() {
    final FormState? form = _productionFormKey.currentState;
    form!.save();

    DateTime? startTime = _productionStartTimeKey.currentState?.value;

    // no seconds
    DateTime? start = startTime != null
        ? DateTime(startTime.year, startTime.month, startTime.day,
            startTime.hour, startTime.minute)
        : null;

    DateTime? end;
    Duration eventDuration = Duration.zero;

    if (_productionEventTimeValue == _byPeriod) {
      DateTime? endTime = _productionEndTimeKey.currentState?.value;

      // no seconds
      end = endTime != null
          ? DateTime(endTime.year, endTime.month, endTime.day, endTime.hour,
              endTime.minute)
          : null;

      int intHours =
          (_productionEventHours != null && _productionEventHours!.isNotEmpty)
              ? int.parse(_productionEventHours!)
              : 0;
      int intMinutes = (_productionEventMinutes != null &&
              _productionEventMinutes!.isNotEmpty)
          ? int.parse(_productionEventMinutes!)
          : 0;
      eventDuration = Duration(hours: intHours, minutes: intMinutes);
    }

    if (_productionEventType == null) {
      UIUtils.showErrorDialog(
          context, AppLocalizations.of(context)!.errMustSelectEvent);
      return;
    }

    if (_equipmentStatus.material == null) {
      UIUtils.showErrorDialog(context,
          AppLocalizations.of(context)!.errNoSetup(widget._equipmentNode.name));
      return;
    }

    if (_productionAmount <= 0) {
      UIUtils.showErrorDialog(context,
          AppLocalizations.of(context)!.errInvalidAmount(_productionAmount));
      return;
    }

    OeeEvent productionEvent = OeeEvent(
        equipment: widget._equipmentNode.name,
        startTime: start!,
        eventType: _productionEventType!);
    productionEvent.duration = eventDuration;
    productionEvent.endTime = end;
    productionEvent.reason = _productionReasonNode?.name;
    productionEvent.amount = _productionAmount;

    // invoke API
    Future<bool> future = HttpService().postEquipmentEvent(productionEvent);

    future.then((ok) {
      setState(() {
        _productionReasonNode = null;
      });

      if (!mounted) return;

      UIUtils.showInfoDialog(
          context, AppLocalizations.of(context)!.equipProdDone);
    }, onError: (error) {
      EquipmentEventResponse response =
          EquipmentEventResponse.fromResponseBody('$error');

      if (!mounted) return;

      UIUtils.showErrorDialog(context, response.errorText);
    });
  }

  void _handleProductionChange(int? value) {
    setState(() {
      _productionValue = value!;

      switch (_productionValue) {
        case _goodAmount:
          // good
          _productionUnit = _equipmentStatus.runRateUOM ?? '';
          _productionEventType = OeeEventType.prodGood;
          break;
        case _rejectAmount:
          // reject and rework
          _productionUnit = _equipmentStatus.rejectUOM ?? '';
          _productionEventType = OeeEventType.prodReject;
          break;
        case _startupAmount:
          // startup and yield
          _productionUnit = _equipmentStatus.rejectUOM ?? '';
          _productionEventType = OeeEventType.prodStartup;
          break;
      }
    });
  }

  // material setup view
  Widget _buildSetupView(BuildContext context) {
    return Form(
        key: _setupFormKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          children: <Widget>[
            // material selection button
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              ElevatedButton.icon(
                label: Text(AppLocalizations.of(context)!.equipMaterial),
                onPressed: () {
                  _showMaterials(context);
                },
                icon: const Icon(Icons.group_work),
              ),
              const SizedBox(width: 20),
              Expanded(
                  child: Text(_getSelectedMaterial(),
                      overflow: TextOverflow.ellipsis)),
            ]),

            // job
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              SizedBox(
                  width: 250,
                  child: TextFormField(
                    controller: _jobController,
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      filled: true,
                      icon: const Icon(Icons.build),
                      hintText: AppLocalizations.of(context)!.equipJobHint,
                      labelText: AppLocalizations.of(context)!.equipJobLabel,
                    ),
                    keyboardType: TextInputType.text,
                    onSaved: (String? value) {
                      _job = value!;
                    },
                  )),
            ]),

            // event start date and time
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              SizedBox(
                  width: 100,
                  child: Text(AppLocalizations.of(context)!.equipStart)),
              Expanded(child: DateTimeWidget(key: _setupTimeKey)),
            ]),

            // record event
            Container(
                padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                child: ElevatedButton.icon(
                  label: Text(AppLocalizations.of(context)!.equipSubmit),
                  onPressed: _onSubmitSetupEvent,
                  icon: const Icon(Icons.check_circle_outline),
                  style: UIUtils.getSubmitStyle(context),
                )),
          ],
        ));
  }

  void _onSubmitSetupEvent() {
    final FormState? form = _setupFormKey.currentState;
    form!.save();

    DateTime? startTime = _setupTimeKey.currentState?.value;

    // no seconds
    DateTime? start = startTime != null
        ? DateTime(startTime.year, startTime.month, startTime.day,
            startTime.hour, startTime.minute)
        : null;

    OeeEventType eventType = OeeEventType.matlSetup;
    if (_materialNode == null) {
      eventType = OeeEventType.jobChange;
    }
    OeeEvent setupEvent = OeeEvent(
        equipment: widget._equipmentNode.name,
        startTime: start!,
        eventType: eventType);

    // material
    setupEvent.material =
        _materialNode?.name ?? _equipmentStatus.material!.name;

    // job
    setupEvent.job = _job;

    // invoke API
    Future<bool> future = HttpService().postEquipmentEvent(setupEvent);

    future.then((ok) {
      _refreshEquipmentStatus();

      if (!mounted) return;

      UIUtils.showInfoDialog(
          context, AppLocalizations.of(context)!.equipSetupDone);
    }, onError: (error) {
      EquipmentEventResponse response =
          EquipmentEventResponse.fromResponseBody('$error');

      if (!mounted) return;

      UIUtils.showErrorDialog(context, response.errorText);
    });
  }

  void _refreshEquipmentStatus() async {
    // fetch status from the database
    OeeEquipmentStatus status =
        await HttpService().getEquipmentStatus(widget._equipmentNode.name);

    setState(() {
      _productionReasonNode = null;
      _equipmentStatus = status;
    });
  }
}
