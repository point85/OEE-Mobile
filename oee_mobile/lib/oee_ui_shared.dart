import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'datetime_picker_formfield.dart';
//import 'package:flutter/services.dart';

class UIUtils {
  static void showAlert(
      BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(title),
          content: new Text(content),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class DateTimeWidget extends StatefulWidget {
  // construct with key to access the DateTime value
  DateTimeWidget({ Key key }) : super(key: key);

  @override
  DateTimeWidgetState createState() => DateTimeWidgetState();
}

class DateTimeWidgetState extends State<DateTimeWidget> {
  final format = DateFormat("yyyy-MM-dd HH:mm");

  // value selected by user
  DateTime _dateTimeValue;

  DateTime get dateTime => _dateTimeValue;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      //Text('Complex date & time field (${format.pattern})'),
      DateTimeField(
        format: format,
        onShowPicker: (context, currentValue) async {
          final date = await showDatePicker(
              context: context,
              firstDate: DateTime(2000),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(2100));
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime:
              TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
            );
            return DateTimeField.combine(date, time);
          } else {
            return currentValue;
          }
        },
        autovalidate: false,
        validator: (date) => date == null ? 'Invalid date' : null,
        initialValue: DateTime.now(),
        onChanged: (date) => setState(() {
          _dateTimeValue = date;
        }),
        onSaved: (date) => setState(() {
          _dateTimeValue = date;
        }),
        resetIcon:Icon(Icons.delete),
        readOnly: true,
        decoration: InputDecoration(
           helperText: 'Enter date and time of day'),
        //inputFormatters: [LengthLimitingTextInputFormatter(30)],
      ),
    ]);
  }
}

