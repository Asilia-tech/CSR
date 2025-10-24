import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sterlite_csr/constants.dart';

class TextFiledUtils {
  // In utils_widgets.dart
  static Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    List<TextInputFormatter>? inputFormatter,
  }) {
    // Use a separate stateful widget instead of trying to handle state in a static method
    return TextFieldWithElevation(
      controller: controller,
      label: label,
      icon: icon,
      hint: hint,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      inputFormatter: inputFormatter,
    );
  }
}

// Add this class to your utils_widgets.dart file
class TextFieldWithElevation extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatter;

  const TextFieldWithElevation({
    required this.controller,
    required this.label,
    required this.icon,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.inputFormatter,
    this.onChanged,
  });

  @override
  _TextFieldWithElevationState createState() => _TextFieldWithElevationState();
}

class _TextFieldWithElevationState extends State<TextFieldWithElevation> {
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
            Flexible(
              child: Text(
                widget.label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
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
                child: TextFormField(
                  inputFormatters: widget.inputFormatter,
                  controller: widget.controller,
                  style: TextStyle(
                    color: Get.isDarkMode ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(14),
                    filled: true,
                    // fillColor: Colors.transparent,
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
                            : Constants.canvasColor.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                  ),
                  keyboardType: widget.keyboardType,
                  validator: widget.validator,
                  onChanged: widget.onChanged,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
