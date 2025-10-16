import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as htmls;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/utilities/function_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';

class MethodUtils {
  static uploadResource(String uri, Uint8List? file) async {
    String message = '';
    var response = await http.post(Uri.parse(uri), body: jsonEncode(file));

    if (response.statusCode == 200) {
      message = 'File Uploaded Successfully';
    } else {
      message = 'error occor';
    }
    return message;
  }

  static getResource(BuildContext context, String uri) async {
    Map<String, dynamic> output = {};
    var imageURL;
    var response = await http.get(Uri.parse(uri));
    if (response.statusCode == 200) {
      try {
        imageURL = jsonDecode(response.body);
        output = {"isValid": true, "info": imageURL};
      } catch (e) {
        imageURL = "No attachement found";
        output = {"isValid": false, "info": imageURL};
      }
    } else {
      imageURL = "Server error : ${response.statusCode}";
      output = {"isValid": false, "info": imageURL};
    }
    return output;
  }

  static accessResource(BuildContext context, String fileName,
      {bool isLocal = false, Uint8List? bytes, String? URL}) async {
    if (isLocal) {
      if (fileName.contains('png') ||
          fileName.contains('jpg') ||
          fileName.contains('jpeg')) {
        UtilsWidgets.showLocalImageDialog(context, bytes!);
      }
    } else {
      if (fileName.contains('.pdf')) {
        final anchor = htmls.AnchorElement(href: URL)
          ..target = 'blank'
          ..download = fileName;
        anchor.click();
      } else {
        UtilsWidgets.zoomDialog(context, URL);
      }
    }
  }

  static downloadDemoFile(Map params, String list_type) async {
    SnackbarController? snackbarController;

    try {
      Uri url = Uri.parse(Constants.BULK_URL + list_type);
      snackbarController = Get.rawSnackbar(
          messageText: Text('Please wait for download file',
              style: TextStyle(color: Colors.white)),
          isDismissible: false,
          duration: null,
          backgroundColor: Constants.primaryColor,
          icon: const Icon(Icons.cloud_download, color: Colors.white, size: 35),
          margin: EdgeInsets.zero,
          snackStyle: SnackStyle.GROUNDED);

      http.Response response = await http.post(url, body: jsonEncode(params));

      if (response.statusCode == 200) {
        Map tempMap = jsonDecode(response.body);
        List<int> fileData = List<int>.from(tempMap['file_data']);
        Uint8List bytes = Uint8List.fromList(fileData);

        await Utils.downloadFile(bytes, tempMap['filename']);

        snackbarController.close();

        UtilsWidgets.showToastFunc("File downloaded successfully");
      } else {
        snackbarController.close();
        UtilsWidgets.showToastFunc("Download failed: ${response.statusCode}");
      }
    } catch (e) {
      snackbarController?.close();
      UtilsWidgets.showToastFunc("Error: $e");
    }
  }

  static apiCall(String uri, Map params) async {
    try {
      http.Response response =
          await http.post(Uri.parse(uri), body: jsonEncode(params));
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        return {
          "message": Utils.errorServer(response.statusCode),
          "isValid": false
        };
      }
    } catch (e) {
      return {"message": 'Something went wrong: $e', "isValid": false};
    }
  }
}
