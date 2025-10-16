import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sterlite_csr/constants.dart';

class CheckboxUtils {
  // Static method to build checkbox fields with consistent styling
  static Widget buildCheckbox({
    required bool value,
    required String label,
    required IconData icon,
    required Function(bool?) onChanged,
    String? subtitle,
  }) {
    return CheckboxWithElevation(
      value: value,
      label: label,
      icon: icon,
      onChanged: onChanged,
      subtitle: subtitle,
    );
  }

  // For multiple checkboxes as a form field (with validation)
  static Widget buildCheckboxGroup<T>({
    required List<T> items,
    required List<T> selectedItems,
    required String label,
    required IconData icon,
    required Function(List<T>) onChanged,
    required String Function(T) displayTextFn,
    String? Function(List<T>)? validator,
    int? columns,
  }) {
    return CheckboxGroupWithElevation<T>(
      items: items,
      selectedItems: selectedItems,
      label: label,
      icon: icon,
      onChanged: onChanged,
      displayTextFn: displayTextFn,
      validator: validator,
      columns: columns,
    );
  }
}

// Single checkbox with animation - Horizontal version
class CheckboxWithElevation extends StatefulWidget {
  final bool value;
  final String label;
  final IconData icon;
  final Function(bool?) onChanged;
  final String? subtitle;

  const CheckboxWithElevation({
    Key? key,
    required this.value,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.subtitle,
  }) : super(key: key);

  @override
  _CheckboxWithElevationState createState() => _CheckboxWithElevationState();
}

class _CheckboxWithElevationState extends State<CheckboxWithElevation> {
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
                  border: Border.all(
                    color: widget.value
                        ? Get.isDarkMode
                            ? Constants.blackColor.withOpacity(0.5)
                            : Constants.scaffoldBackgroundColor.withOpacity(0.5)
                        : Colors.grey.shade400,
                    width: widget.value ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: widget.value,
                      onChanged: widget.onChanged,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      fillColor: MaterialStateProperty.all(
                        Get.isDarkMode
                            ? Constants.blackColor
                            : Constants.scaffoldBackgroundColor,
                      ),
                      activeColor: Get.isDarkMode
                          ? Constants.whiteColor
                          : Constants.scaffoldBackgroundColor,
                      checkColor:
                          Get.isDarkMode ? Constants.canvasColor : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          style: TextStyle(
                            color: Get.isDarkMode
                                ? Colors.white70
                                : Colors.black87,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle!,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Multiple checkbox group with form validation - Horizontal version
class CheckboxGroupWithElevation<T> extends StatefulWidget {
  final List<T> items;
  final List<T> selectedItems;
  final String label;
  final IconData icon;
  final Function(List<T>) onChanged;
  final String Function(T) displayTextFn;
  final String? Function(List<T>)? validator;
  final int? columns;

  const CheckboxGroupWithElevation({
    Key? key,
    required this.items,
    required this.selectedItems,
    required this.label,
    required this.icon,
    required this.onChanged,
    required this.displayTextFn,
    this.validator,
    this.columns,
  }) : super(key: key);

  @override
  _CheckboxGroupWithElevationState<T> createState() =>
      _CheckboxGroupWithElevationState<T>();
}

class _CheckboxGroupWithElevationState<T>
    extends State<CheckboxGroupWithElevation<T>> {
  String? errorText;
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final columns = widget.columns ?? widget.items.length;
    final itemWidth = MediaQuery.of(context).size.width * (0.35 / columns);
    bool isMobile = MediaQuery.of(context).size.width > 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(widget.icon,
                  color: Get.isDarkMode
                      ? Colors.white
                      : Constants.scaffoldBackgroundColor,
                  size: 12),
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
                  border: Border.all(
                    color: errorText != null
                        ? Constants.redColor
                        : Colors.grey.shade400,
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: FormField<List<T>>(
                  initialValue: widget.selectedItems,
                  validator: (value) {
                    if (widget.validator != null) {
                      return widget.validator!(value ?? []);
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      widget.onChanged(value);
                    }
                  },
                  builder: (FormFieldState<List<T>> field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.items.map((item) {
                            final isSelected =
                                widget.selectedItems.contains(item);
                            return SizedBox(
                              width: isMobile ? itemWidth : itemWidth * 2.2,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (bool? checked) {
                                      final newSelectedItems =
                                          List<T>.from(widget.selectedItems);
                                      if (checked == true) {
                                        if (!newSelectedItems.contains(item)) {
                                          newSelectedItems.add(item);
                                        }
                                      } else {
                                        newSelectedItems.remove(item);
                                      }
                                      widget.onChanged(newSelectedItems);
                                      field.didChange(newSelectedItems);
                                    },
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    side: BorderSide(
                                      color: isSelected
                                          ? Get.isDarkMode
                                              ? Constants.blackColor
                                              : Constants
                                                  .scaffoldBackgroundColor
                                          : Colors.grey.shade400,
                                      width: 1,
                                    ),
                                    activeColor: Get.isDarkMode
                                        ? Constants.whiteColor
                                        : Constants.scaffoldBackgroundColor,
                                    checkColor: Get.isDarkMode
                                        ? Constants.canvasColor
                                        : Constants.whiteColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      widget.displayTextFn(item),
                                      style: TextStyle(
                                        color: Get.isDarkMode
                                            ? Colors.white70
                                            : Colors.black87,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
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
}
