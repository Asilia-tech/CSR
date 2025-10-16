import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:photo_view/photo_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';

class UtilsWidgets {
  static AppBar buildAppBar(String title, bool isDarkMode,
      {String? subtitle,
      List<Widget>? Widgets,
      bool backBtn = false,
      Widget? leading,
      PreferredSizeWidget? bottom}) {
    return AppBar(
        bottom: bottom,
        backgroundColor: isDarkMode
            ? Constants.scaffoldBackgroundColor
            : Constants.whiteColor,
        iconTheme:
            IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        leading: leading,
        automaticallyImplyLeading: backBtn,
        toolbarHeight: 100,
        actions: Widgets,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.blue[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    margin: const EdgeInsets.only(right: 12)),
                Flexible(
                  fit: FlexFit.tight,
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle ?? "",
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ));
  }

  static DefaultTabController buildTabBar(
    String title,
    List<Tab> tabs,
    List<Widget> children,
  ) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(),
          ),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            indicatorWeight: 5,
            tabs: tabs,
          ),
          elevation: 20,
          titleSpacing: 10,
        ),
        body: TabBarView(children: children),
      ),
    );
  }

  static ToggleButtons toggleWidget(
      List<bool> isSelected, Function(int)? onPressed) {
    return ToggleButtons(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        selectedColor:
            isSelected[0] ? Constants.whiteColor : Constants.primaryColor,
        fillColor: isSelected[0] ? Constants.primaryColor : Colors.grey,
        constraints: const BoxConstraints(minHeight: 40.0, minWidth: 80.0),
        children: [Text('Yes'), Text('No')],
        isSelected: isSelected,
        onPressed: onPressed);
  }

  static Widget textFormField(
      String? labelText,
      String hintText,
      String? Function(String?)? validator,
      TextEditingController? controller,
      bool isDarkMode,
      {bool isReadOnly = false,
      TextInputType textInputType = TextInputType.text,
      bool obscure = false,
      int maxLine = 1,
      Widget? icon,
      Widget? suffixIcon,
      Widget? prefixIcon,
      Key? key,
      String? Function(String)? onChanged,
      List<TextInputFormatter>? inputFormatter,
      TextInputAction textInputAction = TextInputAction.next}) {
    return TextFormField(
      onChanged: onChanged,
      style: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black87,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          letterSpacing: 1),
      key: key,
      textInputAction: textInputAction,
      autofocus: false,
      keyboardType: textInputType,
      inputFormatters: inputFormatter,
      controller: controller,
      validator: validator,
      obscureText: obscure,
      maxLines: maxLine,
      readOnly: isReadOnly,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
        filled: true,
        fillColor: isDarkMode ? Constants.canvasColor : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
              color: isDarkMode ? Colors.white : Constants.blackColor,
              width: 2.0),
        ),
        icon: icon,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        hintText: hintText,
        hintStyle: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black87,
            fontWeight: FontWeight.w400,
            fontSize: 14,
            letterSpacing: 1),
        labelText: labelText,
      ),
    );
  }

  static Widget searchAbleDropDown(
      BuildContext context,
      List<dynamic> dropdownItems,
      String? holder,
      String labelText,
      IconData icon,
      String? selectedItem,
      ValueChanged? onChange,
      FormFieldValidator? validator,
      {bool showSearchBox = true,
      FocusNode? focusNode,
      bool showClearButton = true,
      bool autoFocus = false,
      Key? key}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(icon, size: 12),
              ),
              Flexible(
                child: Text(
                  labelText,
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
          DropdownSearch(
            key: key,
            popupProps: PopupProps.menu(showSearchBox: showSearchBox),
            dropdownDecoratorProps: DropDownDecoratorProps(
              baseStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 12,
                letterSpacing: 1,
              ),
              dropdownSearchDecoration: InputDecoration(
                filled: true,
                labelStyle: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide:
                      BorderSide(color: Colors.grey.shade400, width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide:
                      BorderSide(color: Colors.grey.shade400, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide:
                      BorderSide(color: Constants.primaryColor, width: 1.5),
                ),
              ),
            ),
            items: dropdownItems,
            validator: validator,
            onChanged: onChange,
            selectedItem: selectedItem,
            dropdownButtonProps: DropdownButtonProps(
              icon: Icon(Icons.arrow_drop_down, color: Constants.blackColor),
            ),
          ),
        ],
      ),
    );
  }

  static Widget dropDownButton(String? hint, String? label, String? value,
      List<dynamic> dropDownItem, Function(dynamic)? onChange,
      {String? Function(String?)? validator, double width = 150}) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        dropdownColor: Get.isDarkMode ? Colors.black : Colors.white,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 10),
          // labelText: label,
          // labelStyle: const TextStyle(fontSize: 12),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Constants.primaryColor, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        ),
        value: value,
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down, color: Constants.blackColor),
        items: dropDownItem.map((item) {
          return DropdownMenuItem<String>(
            value: item.toString(),
            child: Text(
              item.toString(),
              style: TextStyle(
                  color: Constants.blackColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        validator: validator,
        onChanged: onChange,
      ),
    );
  }

  static Widget multiSelectDropDown(
      bool isDesktop,
      List<dynamic> _dropdownItems,
      String labelText,
      List<dynamic> selectedItems,
      Widget? icon,
      ValueChanged? onChange,
      String? dropdownPopUpText,
      Color? color,
      String? searchFieldPropsLabelText,
      FormFieldValidator? validator,
      Function()? onClear,
      Function()? onSelectAll,
      {bool showSearchBox = true,
      FocusNode? focusNode,
      bool showClearButton = true,
      bool autoFocus = false,
      double width = 250,
      Key? key}) {
    return Container(
      width: width,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
      child: DropdownSearch<dynamic>.multiSelection(
        key: key,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            labelText: labelText,
            labelStyle: const TextStyle(fontSize: 12),
            hintText: labelText,
            hintStyle: const TextStyle(fontSize: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        items: _dropdownItems,
        validator: validator,
        onChanged: onChange,
        selectedItems: selectedItems,
        dropdownBuilder: (context, selectedItems) {
          if (selectedItems.isEmpty) {
            return Text(
              labelText.isEmpty ? "Select items" : labelText,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            );
          }
          return Text(
            "${selectedItems.length} item${selectedItems.length > 1 ? 's' : ''} selected",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          );
        },
        popupProps: isDesktop
            ? desktopViewMenu(
                showSearchBox, searchFieldPropsLabelText, onSelectAll, onClear)
            : mobileViewMenu(
                showSearchBox, searchFieldPropsLabelText, onSelectAll, onClear),
      ),
    );
  }

  static PopupPropsMultiSelection<dynamic> desktopViewMenu(
    bool showSearchBox,
    String? searchFieldPropsLabelText,
    Function()? onClear,
    Function()? onSelectAll,
  ) {
    return PopupPropsMultiSelection.menu(
      showSearchBox: showSearchBox,
      searchFieldProps: TextFieldProps(
        decoration: InputDecoration(
          labelText: searchFieldPropsLabelText ?? "Search...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
      ),
      containerBuilder: (context, popupWidget) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onClear != null
                          ? () {
                              onClear();
                              Navigator.of(context).pop();
                            }
                          : null,
                      icon: const Icon(Icons.select_all, size: 12),
                      label: const Text(
                        "Select All",
                        style: TextStyle(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                  ),
                  Container(height: 20, width: 1, color: Colors.grey[400]),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onSelectAll != null
                          ? () {
                              onSelectAll();
                              Navigator.of(context).pop();
                            }
                          : null,
                      icon: const Icon(Icons.clear_all, size: 12),
                      label: const Text(
                        "Clear All",
                        style: TextStyle(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Constants.redColor,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(child: popupWidget),
          ],
        );
      },

      // Additional popup customization
      itemBuilder: (context, item, isSelected) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              title: Text(
                item.toString(),
                style: const TextStyle(fontSize: 12),
              )),
        );
      },
    );
  }

  static PopupPropsMultiSelection<dynamic> mobileViewMenu(
    bool showSearchBox,
    String? searchFieldPropsLabelText,
    Function()? onClear,
    Function()? onSelectAll,
  ) {
    return PopupPropsMultiSelection.bottomSheet(
      showSearchBox: showSearchBox,
      searchFieldProps: TextFieldProps(
        decoration: InputDecoration(
          labelText: searchFieldPropsLabelText ?? "Search...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
      ),
      containerBuilder: (context, popupWidget) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Select All button
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onSelectAll != null
                          ? () {
                              onSelectAll();
                              Navigator.of(context).pop(); // Close popup
                            }
                          : null,
                      icon: const Icon(Icons.select_all, size: 12),
                      label: const Text(
                        "Select All",
                        style: TextStyle(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                  ),
                  Container(height: 20, width: 1, color: Colors.grey[400]),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onClear != null
                          ? () {
                              onClear();
                              Navigator.of(context).pop();
                            }
                          : null,
                      icon: const Icon(Icons.clear_all, size: 12),
                      label: const Text(
                        "Clear All",
                        style: TextStyle(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Constants.redColor,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(child: popupWidget),
          ],
        );
      },
      itemBuilder: (context, item, isSelected) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              title: Text(
                item.toString(),
                style: const TextStyle(fontSize: 12),
              )),
        );
      },
    );
  }

  static Widget buildPrimaryBtn(
      BuildContext context, String? btnsend, Function()? onPressed) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool isCompact = screenWidth < 600;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Constants.primaryColor,
            foregroundColor: Constants.whiteColor,
            padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 12 : 16, vertical: isCompact ? 10 : 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 10,
            textStyle: TextStyle(fontSize: isCompact ? 14 : 16),
          ),
          onPressed: onPressed,
          child: Text(
            btnsend ?? '',
            overflow: TextOverflow.ellipsis,
          )),
    );
  }

  static Widget buildSecondaryBtn(
      BuildContext context, String? btnsend, Function()? onPressed) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool isCompact = screenWidth < 600; // Mobile breakpoint
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: Constants.primaryColor,
        backgroundColor: Constants.whiteColor,
        padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 12 : 16, vertical: isCompact ? 10 : 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: TextStyle(fontSize: isCompact ? 14 : 16),
      ),
      onPressed: onPressed,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Adjust text scaling based on available width
          final textScaleFactor = constraints.maxWidth < 100
              ? 0.8
              : (constraints.maxWidth > 300 ? 1.0 : 0.9);
          return Text(
            btnsend ?? '',
            textScaleFactor: textScaleFactor,
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
    );
  }

  static Widget buildIconBtn(
      String? btnName, Color? color, Widget icon, Function()? onpress) {
    return Center(
      child: TextButton.icon(
        onPressed: onpress,
        icon: icon,
        label: Text(
          "$btnName",
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        style: ButtonStyle(),
      ),
    );
  }

  static drawTable(List<DataColumn> columns, List<DataRow> rows,
      {bool isAscending = true,
      int sortColumnIndex = 0,
      bool isDesktop = false}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        child: DataTable(
            showBottomBorder: true,
            dataTextStyle: const TextStyle(
              color: Colors.black,
            ),
            horizontalMargin: 10,
            headingTextStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
            columnSpacing: isDesktop ? 14 : 100,
            headingRowColor: MaterialStateColor.resolveWith((states) {
              return Constants.primaryColor;
            }),
            sortColumnIndex: sortColumnIndex,
            sortAscending: isAscending,
            columns: columns,
            rows: rows),
      ),
    );
  }

  static showWidgetDialog(BuildContext context, String okbtnName,
      Function()? okPressed, String? title, List<Widget> WidgetList) {
    AlertDialog alert = AlertDialog(
      title: Text(
        "$title",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: WidgetList,
        ),
      ),
      actions: [
        TextButton(
          child: Text('$okbtnName'),
          onPressed: okPressed,
        )
      ],
    );
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return alert;
          });
        });
  }

  static showToastFunc(message) {
    return Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.teal,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static showDeleteDialog(BuildContext context, Function()? onDelete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isDesktop = MediaQuery.of(context).size.width < 600;
        return Dialog(
          elevation: 10,
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 400 : double.infinity,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete, color: Constants.redColor, size: 35),
                  const SizedBox(height: 16),
                  const Text(
                    'Delete Data',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This will delete all data since\nyou last saved',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.grey.shade200,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            if (onDelete != null) onDelete();
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Constants.redColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static showLocalImageDialog(BuildContext context, image) => showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: PhotoView(
              tightMode: true,
              imageProvider: MemoryImage(image),
              heroAttributes: const PhotoViewHeroAttributes(tag: "someTag"),
            ),
          );
        },
      );

  static zoomDialog(BuildContext context, image) => showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: PhotoView(
              tightMode: true,
              imageProvider: NetworkImage(image),
              heroAttributes: const PhotoViewHeroAttributes(tag: "someTag"),
            ),
          );
        },
      );

  static bottomDialogs(
      String msg,
      String title,
      String btn1name,
      String btn2name,
      BuildContext context,
      Function() on1Pressed,
      Function() on2Pressed) {
    return Dialogs.bottomMaterialDialog(
        msg: msg,
        title: title,
        context: context,
        titleStyle: TextStyle(
            color: Constants.blackColor,
            fontWeight: FontWeight.bold,
            fontSize: 16),
        msgStyle: TextStyle(color: Constants.blackColor, fontSize: 12),
        actions: [
          IconsOutlineButton(
            onPressed: on2Pressed,
            text: btn2name,
            iconData: Icons.thumb_up,
            color: Constants.primaryColor,
            textStyle: TextStyle(color: Colors.white),
            iconColor: Colors.white,
          ),
          IconsOutlineButton(
            onPressed: on1Pressed,
            text: btn1name,
            iconData: Icons.thumb_down,
            color: Constants.secondaryColor,
            textStyle: TextStyle(color: Colors.black),
            iconColor: Colors.black,
          ),
        ]);
  }

  static showGetDialog(BuildContext context, message, Color? color,
      {String title = "Alert"}) {
    return Get.defaultDialog(
        title: title,
        middleText: message,
        contentPadding: EdgeInsets.all(15),
        backgroundColor: Constants.whiteColor,
        titleStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
        middleTextStyle: TextStyle(color: Colors.black),
        confirm: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Constants.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Ok",
                style: TextStyle(
                    color: Constants.whiteColor, fontWeight: FontWeight.bold))),
        radius: 20);
  }

  static showDialogBox(
      BuildContext context,
      String btn1Name,
      String btn2Name,
      Function()? btn1Pressed,
      Function()? btn2Pressed,
      String? title,
      List<Widget> WidgetList) {
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Center(
        child: Text(
          "$title",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: WidgetList,
        ),
      ),
      actions: [
        TextButton(
          child: Text('$btn1Name'),
          onPressed: btn1Pressed,
        ),
        TextButton(
          child: Text('$btn2Name'),
          onPressed: btn2Pressed,
        )
      ],
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
