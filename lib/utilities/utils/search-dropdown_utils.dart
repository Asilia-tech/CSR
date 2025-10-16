import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/utilities/utils/dropdown_utils.dart';

class SearchDropdownUtils {
  // Existing dropdown method
  static Widget buildSearchDropdown<T>({
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

  // New searchable dropdown method
  static Widget buildSearchableDropdown<T>({
    required List<T> items,
    required T? value,
    required String label,
    required IconData icon,
    required String hint,
    required void Function(T?) onChanged,
    required String Function(T) displayTextFn,
    String? Function(T?)? validator,
    bool showSearchBox = true,
    bool showClearButton = true,
    bool autoFocus = false,
    FocusNode? focusNode,
    Key? key,
  }) {
    return SearchableDropdownWithElevation<T>(
      key: key,
      items: items,
      value: value,
      label: label,
      icon: icon,
      hint: hint,
      onChanged: onChanged,
      displayTextFn: displayTextFn,
      validator: validator,
      showSearchBox: showSearchBox,
      showClearButton: showClearButton,
      autoFocus: autoFocus,
      focusNode: focusNode,
    );
  }
}

class SearchableDropdownWithElevation<T> extends StatefulWidget {
  final List<T> items;
  final T? value;
  final String label;
  final IconData icon;
  final String hint;
  final void Function(T?) onChanged;
  final String Function(T) displayTextFn;
  final String? Function(T?)? validator;
  final bool showSearchBox;
  final bool showClearButton;
  final bool autoFocus;
  final FocusNode? focusNode;
  final Key? key;

  const SearchableDropdownWithElevation({
    this.key,
    required this.items,
    required this.value,
    required this.label,
    required this.icon,
    required this.hint,
    required this.onChanged,
    required this.displayTextFn,
    this.validator,
    this.showSearchBox = true,
    this.showClearButton = true,
    this.autoFocus = false,
    this.focusNode,
  }) : super(key: key);

  @override
  _SearchableDropdownWithElevationState<T> createState() =>
      _SearchableDropdownWithElevationState<T>();
}

class _SearchableDropdownWithElevationState<T>
    extends State<SearchableDropdownWithElevation<T>> {
  bool isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
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
          onEnter: (_) => setState(() => isFocused = true),
          onExit: (_) => setState(() => isFocused = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.translationValues(0, isFocused ? -2.0 : 0, 0),
            child: Card(
              elevation: isFocused ? 8 : 0,
              shadowColor: Constants.canvasColor,
              child: Focus(
                focusNode: _focusNode,
                child: DropdownSearch<T>(
                  key: widget.key,
                  popupProps: PopupProps.bottomSheet(
                    showSearchBox: widget.showSearchBox,
                    searchFieldProps: TextFieldProps(
                      autofocus: widget.autoFocus,
                      decoration: InputDecoration(
                        hintText: 'Search ${widget.label}...',
                        hintStyle: TextStyle(
                          color:
                              Get.isDarkMode ? Colors.white70 : Colors.black87,
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
                      ),
                    ),
                    title: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      color: Get.isDarkMode
                          ? Constants.canvasColor
                          : Constants.primaryColor,
                      child: Center(
                        child: Text(
                          widget.label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    bottomSheetProps: BottomSheetProps(
                      backgroundColor: Get.isDarkMode
                          ? Constants.blackColor
                          : Constants.whiteColor,
                    ),
                    itemBuilder: (context, item, isSelected) {
                      return ListTile(
                        title: Text(
                          widget.displayTextFn(item),
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(14),
                      filled: true,
                      // fillColor: Colors.transparent,
                      hintText: widget.hint,
                      hintStyle: TextStyle(
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
                  items: widget.items,
                  selectedItem: widget.value,
                  onChanged: (T? newValue) {
                    widget.onChanged(newValue);
                    _focusNode.unfocus();
                  },
                  validator: widget.validator,
                  dropdownBuilder: (context, selectedItem) {
                    return Text(
                      selectedItem != null
                          ? widget.displayTextFn(selectedItem)
                          : widget.hint,
                      style: TextStyle(
                        color: Get.isDarkMode ? Colors.white70 : Colors.black87,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    );
                  },
                  dropdownButtonProps: const DropdownButtonProps(
                    icon: Icon(Icons.arrow_drop_down, size: 20),
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
