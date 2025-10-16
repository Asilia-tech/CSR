import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:sterlite_csr/constants.dart';

class FliterDropdownUtils {
  static Widget buildFliterDropdown<T>({
    required List<T> items,
    required List<T> selectedItems,
    required String label,
    required IconData icon,
    required void Function(List<T>) onChanged,
    required String Function(T) displayTextFn,
    String? Function(List<T>)? validator,
    bool showSearchBox = true,
    String searchFieldLabel = "Search",
    bool showClearButton = true,
    bool autoFocus = false,
    String? popupTitle,
    Key? key,
  }) {
    return FliterDropdownWithElevation<T>(
      items: items,
      selectedItems: selectedItems,
      label: label,
      icon: icon,
      onChanged: onChanged,
      displayTextFn: displayTextFn,
      validator: validator,
      showSearchBox: showSearchBox,
      searchFieldLabel: searchFieldLabel,
      showClearButton: showClearButton,
      autoFocus: autoFocus,
      popupTitle: popupTitle,
      key: key,
    );
  }

  static Widget filterMultiSelectDropDown({
    required List<dynamic> dropdownItems,
    String? holder,
    required String labelText,
    required List<dynamic> selectedItems,
    required ValueChanged<List<dynamic>>? onChange,
    String? dropdownPopUpText,
    Color? color,
    String? searchFieldPropsLabelText = "Search",
    FormFieldValidator<List<dynamic>>? validator,
    bool showSearchBox = true,
    bool showClearButton = true,
    bool autoFocus = false,
    Key? key,
  }) {
    return FliterDropdownLegacy(
      dropdownItems: dropdownItems,
      holder: holder,
      labelText: labelText,
      selectedItems: selectedItems,
      onChange: onChange,
      dropdownPopUpText: dropdownPopUpText,
      color: color,
      searchFieldPropsLabelText: searchFieldPropsLabelText,
      validator: validator,
      showSearchBox: showSearchBox,
      showClearButton: showClearButton,
      autoFocus: autoFocus,
      key: key,
    );
  }
}

class FliterDropdownWithElevation<T> extends StatefulWidget {
  final List<T> items;
  final List<T> selectedItems;
  final String label;
  final IconData icon;
  final void Function(List<T>) onChanged;
  final String Function(T) displayTextFn;
  final String? Function(List<T>)? validator;
  final bool showSearchBox;
  final String searchFieldLabel;
  final bool showClearButton;
  final bool autoFocus;
  final String? popupTitle;

  const FliterDropdownWithElevation({
    Key? key,
    required this.items,
    required this.selectedItems,
    required this.label,
    required this.icon,
    required this.onChanged,
    required this.displayTextFn,
    this.validator,
    this.showSearchBox = true,
    this.searchFieldLabel = "Search",
    this.showClearButton = true,
    this.autoFocus = false,
    this.popupTitle,
  }) : super(key: key);

  @override
  _FliterDropdownWithElevationState<T> createState() =>
      _FliterDropdownWithElevationState<T>();
}

class _FliterDropdownWithElevationState<T>
    extends State<FliterDropdownWithElevation<T>> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class FliterDropdownLegacy extends StatefulWidget {
  final List<dynamic> dropdownItems;
  final String? holder;
  final String labelText;
  final List<dynamic> selectedItems;
  final ValueChanged<List<dynamic>>? onChange;
  final String? dropdownPopUpText;
  final Color? color;
  final String? searchFieldPropsLabelText;
  final FormFieldValidator<List<dynamic>>? validator;
  final bool showSearchBox;
  final bool showClearButton;
  final bool autoFocus;

  const FliterDropdownLegacy({
    Key? key,
    required this.dropdownItems,
    this.holder,
    required this.labelText,
    required this.selectedItems,
    this.onChange,
    this.dropdownPopUpText,
    this.color,
    this.searchFieldPropsLabelText = "Search",
    this.validator,
    this.showSearchBox = true,
    this.showClearButton = true,
    this.autoFocus = false,
  }) : super(key: key);

  @override
  _FliterDropdownLegacyState createState() => _FliterDropdownLegacyState();
}

class _FliterDropdownLegacyState extends State<FliterDropdownLegacy> {
  bool isFocused = false;
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<DropdownSearchState<dynamic>> _dropdownKey = GlobalKey();

  Color get _selectionColor {
    return Get.isDarkMode
        ? Constants.secondaryColor
        : Theme.of(context).primaryColor;
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  void _onFocusChange() {
    setState(() {
      isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.translationValues(0, isFocused ? -4.0 : 0, 0),
        child: Card(
          elevation: isFocused ? 10 : 0,
          shadowColor:
              Get.isDarkMode ? Constants.blackColor : Constants.canvasColor,
          child: DropdownSearch<dynamic>.multiSelection(
            key: _dropdownKey,
            items: widget.dropdownItems,
            selectedItems: widget.selectedItems,
            compareFn: (item1, item2) => item1 == item2,
            dropdownBuilder: (context, selectedItems) {
              if (selectedItems.isEmpty) {
                return Text(
                  widget.labelText,
                  style: TextStyle(
                    color: Get.isDarkMode ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                );
              }
              return Text(
                "${selectedItems.length} selected",
                style: const TextStyle(
                  fontSize: 11,
                ),
              );
            },
            popupProps: PopupPropsMultiSelection.menu(
              title: Builder(builder: (context) {
                return Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: widget.color ??
                        (Get.isDarkMode
                            ? Constants.blackColor
                            : Constants.primaryColor),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.dropdownPopUpText != null)
                          Expanded(
                            child: Text(
                              widget.dropdownPopUpText!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                if (widget.onChange != null) {
                                  widget.onChange!(
                                      List<dynamic>.from(widget.dropdownItems));
                                }
                                Future.delayed(const Duration(milliseconds: 50),
                                    () {
                                  _dropdownKey.currentState
                                      ?.openDropDownSearch();
                                });
                              },
                              child: Text(
                                'Select All',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                if (widget.onChange != null) {
                                  widget.onChange!([]);
                                }
                                Future.delayed(const Duration(milliseconds: 50),
                                    () {
                                  _dropdownKey.currentState
                                      ?.openDropDownSearch();
                                });
                              },
                              child: Text(
                                'Clear All',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              showSearchBox: widget.showSearchBox,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  labelText: widget.searchFieldPropsLabelText,
                  labelStyle: const TextStyle(
                    fontSize: 10,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              showSelectedItems: true,
              selectionWidget: (context, item, isSelected) {
                return Transform.scale(
                  scale: 0.8,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (b) {},
                    activeColor: _selectionColor,
                    checkColor: Get.isDarkMode
                        ? Constants.canvasColor
                        : Constants.whiteColor,
                  ),
                );
              },
              itemBuilder: (context, item, isSelected) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Text(
                    item.toString(),
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? _selectionColor
                          : Get.isDarkMode
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),
                );
              },
            ),
            onChanged: widget.onChange,
            validator: widget.validator,
            clearButtonProps: ClearButtonProps(
              isVisible: widget.showClearButton,
              icon: const Icon(Icons.clear, size: 16),
            ),
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: Get.isDarkMode
                    ? Constants.scaffoldBackgroundColor
                    : Constants.whiteColor,
                labelText: widget.labelText,
                labelStyle: TextStyle(
                  color: Get.isDarkMode ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.w400,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(
                    color: Get.isDarkMode
                        ? Constants.blackColor.withOpacity(0.5)
                        : Constants.primaryColor.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
