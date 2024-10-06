import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';

class DateTimeWidget extends StatefulWidget {
  const DateTimeWidget({super.key});

  @override
  DateTimeWidgetState createState() => DateTimeWidgetState();
}

class DateTimeWidgetState extends State<DateTimeWidget> {
  final _format = DateFormat('yyyy-MM-dd HH:mm');
  DateTime? value = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      DateTimeField(
        format: _format,
        onShowPicker: (context, currentValue) async {
          return await showDatePicker(
            context: context,
            firstDate: DateTime(2020),
            initialDate: currentValue ?? DateTime.now(),
            lastDate: DateTime(2100),
          ).then((DateTime? date) async {
            if (date != null) {
              final time = await showTimePicker(
                // ignore: use_build_context_synchronously
                context: context,
                initialTime:
                    TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
              );
              return DateTimeField.combine(date, time);
            } else {
              return currentValue;
            }
          });
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (date) => date == null ? 'Invalid date' : null,
        initialValue: DateTime.now(),
        onChanged: (date) => setState(() {
          value = date;
        }),
        resetIcon: null,
        readOnly: true,
      ),
    ]);
  }
}
