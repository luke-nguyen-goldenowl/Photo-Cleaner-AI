import 'package:flutter/material.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class XCustomDateRangeDialog extends StatefulWidget {
  final DateTimeRange? initialRange;
  final void Function(DateTimeRange range) onConfirmed;

  const XCustomDateRangeDialog({
    super.key,
    this.initialRange,
    required this.onConfirmed,
  });

  @override
  State<XCustomDateRangeDialog> createState() => _CustomDateRangeDialogState();
}

class _CustomDateRangeDialogState extends State<XCustomDateRangeDialog> {
  PickerDateRange? _tempRange;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 450,
        width: 350,
        child: Column(
          children: [
            Expanded(
              child: SfDateRangePicker(
                view: DateRangePickerView.month,
                selectionMode: DateRangePickerSelectionMode.range,
                backgroundColor: Colors.white,
                minDate: DateTime(2000),
                maxDate: DateTime.now(),
                initialSelectedRange: PickerDateRange(
                  widget.initialRange?.start ??
                      DateTime.now().subtract(const Duration(days: 7)),
                  widget.initialRange?.end ?? DateTime.now(),
                ),
                onSelectionChanged: (args) {
                  if (args.value is PickerDateRange) {
                    _tempRange = args.value;
                  }
                },
                headerStyle: const DateRangePickerHeaderStyle(
                  textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF091031)),
                  backgroundColor: Colors.white,
                ),
                monthViewSettings: const DateRangePickerMonthViewSettings(
                  dayFormat: 'EE',
                  viewHeaderStyle: DateRangePickerViewHeaderStyle(
                    textStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54),
                  ),
                ),
                startRangeSelectionColor: Color(0xFF6C63FF),
                endRangeSelectionColor: Color(0xFF6C63FF),
                rangeSelectionColor: Color(0xFF6C63FF).withOpacity(0.1),
                todayHighlightColor: Color(0xFF6C63FF),
                selectionShape: DateRangePickerSelectionShape.circle,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(S.of(context).common_cancelButton_title,
                      style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (_tempRange != null &&
                        _tempRange!.startDate != null &&
                        _tempRange!.endDate != null) {
                      widget.onConfirmed(DateTimeRange(
                        start: _tempRange!.startDate!,
                        end: _tempRange!.endDate!,
                      ));
                    }
                    Navigator.pop(context);
                  },
                  child: Text(S.of(context).common_agreeButton_title,
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
