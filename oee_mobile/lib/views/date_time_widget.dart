import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';

class DateTimeWidget extends StatefulWidget {
  final DateTime? initialValue;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime?>? onChanged;
  final String? Function(DateTime?)? validator;

  const DateTimeWidget({
    super.key,
    this.initialValue,
    this.firstDate,
    this.lastDate,
    this.onChanged,
    this.validator,
  });

  @override
  DateTimeWidgetState createState() => DateTimeWidgetState();
}

class DateTimeWidgetState extends State<DateTimeWidget> {
  final _format = DateFormat('yyyy-MM-dd HH:mm');
  DateTime? _value;

  DateTime? get value => _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return DateTimeField(
      format: _format,
      onShowPicker: (context, currentValue) async {
        final date = await showDatePicker(
          context: context,
          firstDate: DateTime(2020),
          initialDate: currentValue ?? DateTime.now(),
          lastDate: DateTime(2100),
        );

        if (date != null) {
          // Check if the context is still valid before using it
          if (!context.mounted) return currentValue;

          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
          );
          return DateTimeField.combine(date, time);
        }
        return currentValue;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator:
          widget.validator ?? (date) => date == null ? 'Invalid date' : null,
      initialValue: _value,
      onChanged: (date) {
        setState(() => _value = date);
        widget.onChanged?.call(date);
      },
      resetIcon: null,
      readOnly: true,
    );
  }
}
