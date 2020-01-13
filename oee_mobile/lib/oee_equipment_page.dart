import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:oee_mobile/oee_services.dart';
import 'oee_reason_page.dart';
import 'oee_model.dart';
import 'oee_ui_shared.dart';

import 'contact.dart';

class EquipmentEventPage extends StatefulWidget {
  //final Map entityData;
  final OeeEntity equipment;

  //EquipmentEventPage({this.entityData});
  EquipmentEventPage({this.equipment});

  @override
  _EquipmentEventPageState createState() => _EquipmentEventPageState();
}

class _EquipmentEventPageState extends State<EquipmentEventPage> {
  //Map entityData;
  _EquipmentEventPageState();

  DateAndTimePickerDemo dtpd = DateAndTimePickerDemo();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _availabilityFormKey = GlobalKey<FormState>();
  List<String> _colors = <String>['', 'red', 'green', 'blue', 'orange'];
  String _color = '';
  Contact newContact = Contact();
  final TextEditingController _controller = TextEditingController();

  OeeReason selectedReason;

  Future<Null> _chooseDate(
      BuildContext context, String initialDateString) async {
    var now = DateTime.now();
    var initialDate = convertToDate(initialDateString) ?? now;
    initialDate = (initialDate.year >= 1900 && initialDate.isBefore(now)
        ? initialDate
        : now);

    var result = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1900),
        lastDate: DateTime.now());

    if (result == null) return;

    setState(() {
      _controller.text = DateFormat.yMd().format(result);
    });
  }

  bool isValidDob(String dob) {
    if (dob.isEmpty) return true;
    var d = convertToDate(dob);
    return d != null && d.isBefore(DateTime.now());
  }

  DateTime convertToDate(String input) {
    try {
      var d = DateFormat.yMd().parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  bool isValidPhoneNumber(String input) {
    final RegExp regex = RegExp(r'^\(\d\d\d\)\d\d\d\-\d\d\d\d$');
    return regex.hasMatch(input);
  }

  bool isValidEmail(String input) {
    final RegExp regex = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    return regex.hasMatch(input);
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(backgroundColor: color, content: Text(message)));
  }

  void _submitForm() {
    final FormState form = _availabilityFormKey.currentState;
    form.save(); //This invokes each onSaved event

    /*
    if (!form.validate()) {
      showMessage('Form is not valid!  Please review and correct.');
    } else {
      form.save(); //This invokes each onSaved event
    }
    */

    DateTime dt = dtKey.currentState.dateTimeValue;
    print(dt.toIso8601String());
    //DateTime dt = this.dtKey.currentState.dateTime;
    //this.startTimeWidget.getDateTime();
      //DateTime startTime = this.widget.startTimeWidget.value;

      //    showMessage('Start time is ${startTime}!', Colors.blue);
  }

  bool showName = true;

  int _radioValue = -1;

  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue = value;

      switch (_radioValue) {
        case 0:
          showName = false;
          break;
        case 1:
          showName = true;
          break;
      }
    });
  }

  TextFormField myName = new TextFormField(
    decoration: const InputDecoration(
      icon: const Icon(Icons.person),
      hintText: 'Enter your first and last name',
      labelText: 'My Name',
    ),
    inputFormatters: [LengthLimitingTextInputFormatter(30)],
    validator: (val) => val.isEmpty ? 'Name is required' : null,
  );

  DateTimeWidget startTimeWidget;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
              title: Text(widget.equipment
                  .toString()), //Text('${entityData['title']}"'),
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
  }

  _showReasons(BuildContext context) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (ctx) => ReasonPage()));
    selectedReason = OeeExecutionService.getInstance.reason;
  }

  final dtKey = new GlobalKey<DateTimeWidgetState>();

  Widget _buildAvailabilityView(BuildContext context) {
    return Form(
        key: _availabilityFormKey,
        autovalidate: true,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: <Widget>[
            // radio buttons
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Radio(
                value: 0,
                groupValue: _radioValue,
                onChanged: _handleRadioValueChange,
              ),
              Text('By Time Period'),
              Radio(
                value: 1,
                groupValue: _radioValue,
                onChanged: _handleRadioValueChange,
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

            // event start
            DateTimeWidget(key: dtKey),

            Visibility(child: myName, visible: showName),
            TextFormField(
              decoration: const InputDecoration(
                icon: const Icon(Icons.person),
                hintText: 'Enter your first and last name',
                labelText: 'Name',
              ),
              inputFormatters: [LengthLimitingTextInputFormatter(30)],
              validator: (val) => val.isEmpty ? 'Name is required' : null,
              onSaved: (val) => newContact.name = val,
            ),
            Row(children: <Widget>[
              Expanded(
                  child: TextFormField(
                decoration: InputDecoration(
                  icon: const Icon(Icons.calendar_today),
                  hintText: 'Enter your date of birth',
                  labelText: 'Dob',
                ),
                controller: _controller,
                keyboardType: TextInputType.datetime,
                validator: (val) => isValidDob(val) ? null : 'Not a valid date',
                onSaved: (val) => newContact.dob = convertToDate(val),
              )),
              IconButton(
                icon: Icon(Icons.more_horiz),
                tooltip: 'Choose date',
                onPressed: (() {
                  _chooseDate(context, _controller.text);
                }),
              )
            ]),
            TextFormField(
              decoration: const InputDecoration(
                icon: const Icon(Icons.phone),
                hintText: 'Enter a phone number',
                labelText: 'Phone',
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                WhitelistingTextInputFormatter(RegExp(r'^[()\d -]{1,15}$')),
              ],
              validator: (value) => isValidPhoneNumber(value)
                  ? null
                  : 'Phone number must be entered as (###)###-####',
              onSaved: (val) => newContact.phone = val,
            ),
            TextFormField(
              decoration: const InputDecoration(
                icon: const Icon(Icons.email),
                hintText: 'Enter a email address',
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) => isValidEmail(value)
                  ? null
                  : 'Please enter a valid email address',
              onSaved: (val) => newContact.email = val,
            ),
            FormField<String>(
              builder: (FormFieldState<String> state) {
                return InputDecorator(
                  decoration: InputDecoration(
                    icon: const Icon(Icons.color_lens),
                    labelText: 'Color',
                    errorText: state.hasError ? state.errorText : null,
                  ),
                  isEmpty: _color == '',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _color,
                      isDense: true,
                      onChanged: (String newValue) {
                        setState(() {
                          newContact.favoriteColor = newValue;
                          _color = newValue;
                          state.didChange(newValue);
                        });
                      },
                      items: _colors.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
              validator: (val) {
                return val != '' ? null : 'Please select a color';
              },
            ),
            Container(
                padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                child: RaisedButton.icon(
                  label: const Text('Submit'),
                  onPressed: _submitForm,
                  icon: const Icon(Icons.check_circle_outline),
                )),
          ],
        ));
  }
}
