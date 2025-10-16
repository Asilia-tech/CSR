import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sterlite_csr/constants.dart';

class DropdownUtils {
  static Widget buildDropdown<T>({
    required List<T> items,
    required T? value,
    required String label,
    required IconData icon,
    required String hint,
    required void Function(T?) onChanged,
    required String Function(T) displayTextFn,
    String? Function(T?)? validator,
  }) {
    return DropdownWithElevation<T>(
      items: items,
      value: value,
      label: label,
      icon: icon,
      hint: hint,
      onChanged: onChanged,
      displayTextFn: displayTextFn,
      validator: validator,
    );
  }
}

class DropdownWithElevation<T> extends StatefulWidget {
  final List<T> items;
  final T? value;
  final String label;
  final IconData icon;
  final String hint;
  final void Function(T?) onChanged;
  final String Function(T) displayTextFn;
  final String? Function(T?)? validator;

  const DropdownWithElevation({
    Key? key,
    required this.items,
    required this.value,
    required this.label,
    required this.icon,
    required this.hint,
    required this.onChanged,
    required this.displayTextFn,
    this.validator,
  }) : super(key: key);

  @override
  _DropdownWithElevationState<T> createState() =>
      _DropdownWithElevationState<T>();
}

class _DropdownWithElevationState<T> extends State<DropdownWithElevation<T>> {
  bool isHovered = false;
  bool isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

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
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.translationValues(
                0, (isHovered || isFocused) ? -2.0 : 0, 0),
            child: Card(
              elevation: (isHovered || isFocused) ? 8 : 0,
              shadowColor: Constants.canvasColor,
              child: Container(
                decoration: BoxDecoration(
                  color: Get.isDarkMode
                      ? Constants.scaffoldBackgroundColor
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Focus(
                  focusNode: _focusNode,
                  child: DropdownButtonFormField<T>(
                    value: widget.value,
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
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    items: widget.items.map<DropdownMenuItem<T>>((T item) {
                      return DropdownMenuItem<T>(
                        value: item,
                        child: Text(
                          widget.displayTextFn(item),
                          style: TextStyle(
                            fontSize: 12,
                            color: Get.isDarkMode
                                ? Colors.white70
                                : Colors.black87,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (T? newValue) {
                      widget.onChanged(newValue);
                      _focusNode.unfocus();
                    },
                    validator: widget.validator,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, size: 20),
                    dropdownColor:
                        Get.isDarkMode ? Constants.canvasColor : Colors.white,
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
