import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/utilities/function_utils.dart';

class DecorationWidgets {
  static kayValueWidget(BuildContext context, String? key, String? value,
      {bool islink = false, Function()? onPressed}) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: IntrinsicHeight(
          child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.topCenter,
                  child: Text(
                    key ?? "",
                    maxLines: 10,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: islink
                      ? TextButton(
                          onPressed: onPressed,
                          child: Text(value ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue)),
                        )
                      : Text(value ?? '', maxLines: 50),
                ),
              ),
            ],
          ),
          SizedBox(height: 3),
          Divider(
            color: Colors.black,
            thickness: 1,
            height: 5,
            indent: 25,
            endIndent: 25,
          ),
        ],
      )),
    );
  }

  static buildStatusTag(BuildContext context, String status) {
    return Container(
      decoration: BoxDecoration(
          color: Utils.getStatusColor(status),
          borderRadius: BorderRadius.circular(15)),
      padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
      child: Text(
        status.toString(),
        style: TextStyle(fontSize: 12, color: Constants.whiteColor),
      ),
    );
  }

  static showProgressDialog(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            semanticsLabel: 'Please wait',
            strokeWidth: 5,
            valueColor: AlwaysStoppedAnimation<Color>(
                Get.isDarkMode ? Colors.white : Constants.primaryColor),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Please wait',
                style: TextStyle(
                    color:
                        Get.isDarkMode ? Colors.white : Constants.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ),
        ],
      ),
    );
  }

  static msgDecor(BuildContext context, String msg) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  static filterTextStyle(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Text(
          msg,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  static buildExpandableNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
    initiallyExpanded = false,
  }) {
    bool isDarkMode = Get.isDarkMode;
    Color iconColor = isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;
    Color textColor = isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(
          icon,
          size: 20,
          color: iconColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: textColor,
            fontSize: 14,
          ),
        ),
        children: children,
        childrenPadding: EdgeInsets.only(left: 16),
      ),
    );
  }
}
