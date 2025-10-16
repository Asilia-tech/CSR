import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sterlite_csr/constants.dart';

class DatePickerUtils {
  static Widget buildDatePicker({
    required String label,
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTime? initialDate,
    bool use24HourFormat = false,
  }) {
    return DatePickerWithElevation(
      controller: controller,
      label: label,
      icon: icon,
      hint: hint,
      validator: validator,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDate: initialDate,
      use24HourFormat: use24HourFormat,
    );
  }
}

class DatePickerWithElevation extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hint;
  final String? Function(String?)? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final bool use24HourFormat;

  const DatePickerWithElevation({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.hint,
    this.validator,
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.use24HourFormat = false,
  });

  @override
  State<DatePickerWithElevation> createState() =>
      _DatePickerWithElevationState();
}

class _DatePickerWithElevationState extends State<DatePickerWithElevation> {
  bool isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(widget.icon, size: 12),
            ),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        MouseRegion(
          onEnter: (_) => setState(() => isFocused = true),
          onExit: (_) => setState(() => isFocused = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.translationValues(0, isFocused ? -2.0 : 0, 0),
            child: Card(
              elevation: isFocused ? 8 : 0,
              shadowColor: Constants.canvasColor,
              child: Focus(
                onFocusChange: (hasFocus) {
                  setState(() {
                    isFocused = hasFocus;
                  });
                },
                child: Theme(
                  data: Get.isDarkMode
                      ? ThemeData.dark().copyWith(
                          primaryColor: Constants.canvasColor,
                          textTheme: TextTheme(
                            button: TextStyle(color: Constants.canvasColor),
                          ),
                        )
                      : ThemeData.light().copyWith(
                          primaryColor: Constants.primaryColor,
                          textTheme: TextTheme(
                            button: TextStyle(color: Constants.whiteColor),
                          ),
                        ),
                  child: DateTimePicker(
                    controller: widget.controller,
                    type: DateTimePickerType.date,
                    dateMask: 'dd MMM, yyyy',
                    initialValue: widget.initialDate?.toString(),
                    firstDate: widget.firstDate ?? DateTime(1900),
                    lastDate: widget.lastDate ?? DateTime(2100),
                    icon: const Icon(Icons.event),
                    style: TextStyle(
                      color: Get.isDarkMode ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(14),
                      filled: true,
                      fillColor: Colors.transparent,
                      hintText: widget.hint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Get.isDarkMode
                              ? Constants.whiteColor.withOpacity(0.5)
                              : Constants.primaryColor.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                    ),
                    validator: widget.validator,
                    onChanged: (val) => widget.controller.text = val,
                    use24HourFormat: widget.use24HourFormat,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
