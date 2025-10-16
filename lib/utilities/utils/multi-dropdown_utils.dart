import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:sterlite_csr/constants.dart';

class MultiSelectDropdownUtils {
  static Widget buildMultiSelectDropdown<T>({
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
    return MultiSelectDropdownWithElevation<T>(
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

  // Legacy method compatible with your existing code
  static Widget multiSelectDropDown({
    required List<dynamic> dropdownItems,
    String? holder,
    required String labelText,
    required List<dynamic> selectedItems,
    required ValueChanged? onChange,
    String? dropdownPopUpText,
    Color? color,
    String? searchFieldPropsLabelText = "Search",
    FormFieldValidator? validator,
    bool showSearchBox = true,
    bool showClearButton = true,
    bool autoFocus = false,
    Key? key,
  }) {
    return MultiSelectDropdownLegacy(
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

class MultiSelectDropdownWithElevation<T> extends StatefulWidget {
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

  const MultiSelectDropdownWithElevation({
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
  _MultiSelectDropdownWithElevationState<T> createState() =>
      _MultiSelectDropdownWithElevationState<T>();
}

class _MultiSelectDropdownWithElevationState<T>
    extends State<MultiSelectDropdownWithElevation<T>> {
  bool isFocused = false;
  final FocusNode _focusNode = FocusNode();

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

  Color get _selectionColor {
    return Get.isDarkMode ? Constants.whiteColor : Constants.canvasColor;
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
          onEnter: (_) => setState(() => isFocused = true),
          onExit: (_) => setState(() => isFocused = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.translationValues(0, isFocused ? -2.0 : 0, 0),
            child: Card(
              elevation: isFocused ? 15 : 0,
              shadowColor:
                  Get.isDarkMode ? Constants.blackColor : Constants.canvasColor,
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
                child: DropdownSearch<T>.multiSelection(
                  items: widget.items,
                  selectedItems: widget.selectedItems,
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(12),
                      hintStyle: TextStyle(
                        color: Get.isDarkMode ? Colors.white70 : Colors.black87,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                      filled: true,
                      fillColor: Get.isDarkMode
                          ? Constants.scaffoldBackgroundColor
                          : Constants.whiteColor,
                      hintText: widget.label,
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
                              ? Constants.blackColor.withOpacity(0.5)
                              : Constants.primaryColor.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  clearButtonProps: ClearButtonProps(
                      isVisible: widget.showClearButton,
                      icon: const Icon(Icons.clear, size: 18)),
                  popupProps: PopupPropsMultiSelection.menu(
                    title: widget.popupTitle != null
                        ? Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Get.isDarkMode
                                  ? Constants.canvasColor
                                  : Constants.primaryColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                widget.popupTitle!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        : null,
                    showSearchBox: widget.showSearchBox,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        labelText: widget.searchFieldLabel,
                        labelStyle: TextStyle(
                          color:
                              Get.isDarkMode ? Colors.white70 : Colors.black87,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    menuProps: const MenuProps(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    showSelectedItems: true,
                    selectionWidget: (context, item, isSelected) {
                      return Checkbox(
                        value: isSelected,
                        onChanged: (b) {},
                        activeColor: _selectionColor,
                        checkColor: Get.isDarkMode
                            ? Constants.canvasColor
                            : Constants.whiteColor,
                      );
                    },
                    itemBuilder: (context, item, isSelected) {
                      return ListTile(
                        title: Text(
                          widget.displayTextFn(item),
                          style: TextStyle(
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
                  itemAsString: widget.displayTextFn,
                  onChanged: widget.onChanged,
                  validator: (items) {
                    if (widget.validator != null) {
                      return widget.validator!(items ?? []);
                    }
                    return null;
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

class MultiSelectDropdownLegacy extends StatefulWidget {
  final List<dynamic> dropdownItems;
  final String? holder;
  final String labelText;
  final List<dynamic> selectedItems;
  final ValueChanged? onChange;
  final String? dropdownPopUpText;
  final Color? color;
  final String? searchFieldPropsLabelText;
  final FormFieldValidator? validator;
  final bool showSearchBox;
  final bool showClearButton;
  final bool autoFocus;

  const MultiSelectDropdownLegacy({
    Key? key,
    required this.dropdownItems,
    this.holder,
    required this.labelText,
    required this.selectedItems,
    required this.onChange,
    this.dropdownPopUpText,
    this.color,
    this.searchFieldPropsLabelText = "Search",
    this.validator,
    this.showSearchBox = true,
    this.showClearButton = true,
    this.autoFocus = false,
  }) : super(key: key);

  @override
  _MultiSelectDropdownLegacyState createState() =>
      _MultiSelectDropdownLegacyState();
}

class _MultiSelectDropdownLegacyState extends State<MultiSelectDropdownLegacy> {
  bool isFocused = false;
  final FocusNode _focusNode = FocusNode();

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
      padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.translationValues(0, isFocused ? -5.0 : 0, 0),
        child: Card(
          elevation: isFocused ? 15 : 0,
          shadowColor:
              Get.isDarkMode ? Constants.blackColor : Constants.canvasColor,
          child: DropdownSearch<dynamic>.multiSelection(
            items: widget.dropdownItems,
            selectedItems: widget.selectedItems,
            popupProps: PopupPropsMultiSelection.menu(
              title: widget.dropdownPopUpText != null
                  ? Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: widget.color ??
                            (Get.isDarkMode
                                ? Constants.blackColor
                                : Constants.primaryColor),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.dropdownPopUpText!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : null,
              showSearchBox: widget.showSearchBox,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  labelText: widget.searchFieldPropsLabelText,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              menuProps: const MenuProps(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              showSelectedItems: true,
              selectionWidget: (context, item, isSelected) {
                return Checkbox(
                  value: isSelected,
                  onChanged: (b) {},
                  activeColor: _selectionColor,
                  checkColor: Get.isDarkMode
                      ? Constants.canvasColor
                      : Constants.whiteColor,
                );
              },
              itemBuilder: (context, item, isSelected) {
                return ListTile(
                  title: Text(
                    item.toString(),
                    style: TextStyle(
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
              icon: const Icon(Icons.clear, size: 18),
            ),
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                contentPadding: const EdgeInsets.all(12),
                filled: true,
                fillColor: Get.isDarkMode
                    ? Constants.scaffoldBackgroundColor
                    : Constants.whiteColor,
                labelText: widget.labelText,
                hintText: widget.holder ?? widget.labelText,
                hintStyle: TextStyle(
                  color: Get.isDarkMode ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
                labelStyle: TextStyle(
                  color: Get.isDarkMode ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
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
                        ? Constants.blackColor.withOpacity(0.5)
                        : Constants.primaryColor.withOpacity(0.5),
                    width: 2,
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
