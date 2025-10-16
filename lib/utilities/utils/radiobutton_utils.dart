import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sterlite_csr/constants.dart';

class RadioButtonUtils {
  // Static method to build radio button group with consistent styling
  static Widget buildRadioGroup<T>({
    required List<T> items,
    required T? selectedValue,
    required String label,
    required IconData icon,
    required Function(T?) onChanged,
    required String Function(T) displayTextFn,
    String? Function(T?)? validator,
    bool horizontal = false,
    int? columnsWhenHorizontal,
  }) {
    return RadioGroupWithElevation<T>(
      items: items,
      selectedValue: selectedValue,
      label: label,
      icon: icon,
      onChanged: onChanged,
      displayTextFn: displayTextFn,
      validator: validator,
      horizontal: horizontal,
      columnsWhenHorizontal: columnsWhenHorizontal,
    );
  }
}

class RadioGroupWithElevation<T> extends StatefulWidget {
  final List<T> items;
  final T? selectedValue;
  final String label;
  final IconData icon;
  final Function(T?) onChanged;
  final String Function(T) displayTextFn;
  final String? Function(T?)? validator;
  final bool horizontal;
  final int? columnsWhenHorizontal;

  const RadioGroupWithElevation({
    Key? key,
    required this.items,
    required this.selectedValue,
    required this.label,
    required this.icon,
    required this.onChanged,
    required this.displayTextFn,
    this.validator,
    this.horizontal = false,
    this.columnsWhenHorizontal,
  }) : super(key: key);

  @override
  _RadioGroupWithElevationState<T> createState() =>
      _RadioGroupWithElevationState<T>();
}

class _RadioGroupWithElevationState<T>
    extends State<RadioGroupWithElevation<T>> {
  bool isHovered = false;

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
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.translationValues(0, isHovered ? -2.0 : 0, 0),
            child: Card(
              elevation: isHovered ? 8 : 0,
              shadowColor: Constants.canvasColor,
              child: Container(
                decoration: BoxDecoration(
                  color: Get.isDarkMode
                      ? Constants.scaffoldBackgroundColor
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: FormField<T>(
                  initialValue: widget.selectedValue,
                  validator: widget.validator,
                  builder: (FormFieldState<T> field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: widget.horizontal
                              ? _buildHorizontalRadioGroup(field)
                              : _buildVerticalRadioGroup(field),
                        ),
                        if (field.hasError)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text(
                              field.errorText ?? '',
                              style: TextStyle(
                                color: Constants.redColor,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalRadioGroup(FormFieldState<T> field) {
    return Column(
      children: widget.items.map((item) {
        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
          ),
          child: RadioListTile<T>(
            title: Text(
              widget.displayTextFn(item),
              style: TextStyle(
                color: Get.isDarkMode ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w400,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            value: item,
            groupValue: widget.selectedValue,
            onChanged: (T? value) {
              widget.onChanged(value);
              field.didChange(value);
            },
            dense: true,
            fillColor: MaterialStateProperty.all(
              Get.isDarkMode
                  ? Constants.blackColor
                  : Constants.scaffoldBackgroundColor,
            ),
            activeColor: Get.isDarkMode
                ? Constants.blackColor
                : Constants.scaffoldBackgroundColor,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHorizontalRadioGroup(FormFieldState<T> field) {
    final int columns = widget.columnsWhenHorizontal ?? widget.items.length;
    bool isMobile = MediaQuery.of(context).size.width > 600;

    // Split items into rows based on columns
    final List<List<T>> rows = [];
    for (int i = 0; i < widget.items.length; i += columns) {
      final end = (i + columns < widget.items.length)
          ? i + columns
          : widget.items.length;
      rows.add(widget.items.sublist(i, end));
    }

    return Column(
      children: rows.map((rowItems) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowItems.map((item) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: isMobile
                      ? MediaQuery.of(context).size.width * (0.3 / columns)
                      : MediaQuery.of(context).size.width * (0.8 / columns)),
              child: RadioListTile<T>(
                title: Text(
                  widget.displayTextFn(item),
                  style: TextStyle(
                    color: Get.isDarkMode ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                value: item,
                groupValue: widget.selectedValue,
                onChanged: (T? value) {
                  widget.onChanged(value);
                  field.didChange(value);
                },
                fillColor: MaterialStateProperty.all(
                  Get.isDarkMode
                      ? Constants.whiteColor
                      : Constants.scaffoldBackgroundColor,
                ),
                activeColor: Get.isDarkMode
                    ? Constants.whiteColor
                    : Constants.scaffoldBackgroundColor,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

// Enhanced version specifically for status selection like your example
class StatusRadioGroup extends StatefulWidget {
  final List<String> statusList;
  final String selectedStatus;
  final Function(String) onChanged;
  final String label;
  final IconData icon;

  const StatusRadioGroup({
    Key? key,
    required this.statusList,
    required this.selectedStatus,
    required this.onChanged,
    this.label = "Status",
    this.icon = Icons.toggle_on,
  }) : super(key: key);

  @override
  _StatusRadioGroupState createState() => _StatusRadioGroupState();
}

class _StatusRadioGroupState extends State<StatusRadioGroup> {
  bool isHovered = false;

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
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.translationValues(0, isHovered ? -2.0 : 0, 0),
            child: Card(
              elevation: isHovered ? 8 : 0,
              shadowColor: Constants.canvasColor,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade400,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.statusList.map((status) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width *
                            (1 / widget.statusList.length),
                        child: RadioListTile<String>(
                          title: Text(
                            status,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                          value: status,
                          groupValue: widget.selectedStatus,
                          onChanged: (String? value) {
                            if (value != null) {
                              widget.onChanged(value);
                            }
                          },
                          dense: true,
                          activeColor: Get.isDarkMode
                              ? Constants.blackColor
                              : Constants.primaryColor,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      );
                    }).toList(),
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
