import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:html' as html;
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:excel/excel.dart' as exl
    show Excel, Sheet, ExcelColor, CellStyle;
import 'package:excel/excel.dart' show CellIndex, TextCellValue;
import 'package:sterlite_csr/utilities/widget_utils.dart';

class Utils {
  static String getMonthName(int month) {
    return DateFormat('MMMM').format(DateTime(2023, month));
  }

  static String formatDate(DateTime date, String format) {
    DateFormat formatter = new DateFormat(format);
    return formatter.format(date);
  }

  static List<String> generateFinancialYears({int count = 4}) {
    List<String> years = [];
    int currentYear = DateTime.now().year;
    int startYear = currentYear + 1;

    for (int i = 0; i < count; i++) {
      int year = startYear - i;
      years.add('${year}-${year + 1}');
    }

    return years;
  }

  static String getCurrentFinancialYear() {
    String currentFinancialYear = '';
    int currentYear = DateTime.now().year;
    int currentMonth = DateTime.now().month;

    if (currentMonth < 4) {
      currentFinancialYear = '${currentYear - 1}-${currentYear}';
    } else {
      currentFinancialYear = '$currentYear-${currentYear + 1}';
    }

    return currentFinancialYear;
  }

  static String TimeStampToDate(String timestamp,
      {String format = 'dd-MM-yyyy hh:mm a'}) {
    DateTime createDate =
        DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp) * 1000);
    String date = Utils.formatDate(createDate, format);
    return date;
  }

  static String dateToTime(String inputDate) {
    DateTime InDate = new DateFormat("yyyy-MM-dd HH:mm").parse(inputDate);
    String formattedTime = DateFormat.jm().format(InDate);
    return formattedTime;
  }

  static String calculateDuration(String startTime, String endTime) {
    try {
      final start =
          TimeOfDay.fromDateTime(DateTime.parse("2024-01-01 $startTime"));
      final end = TimeOfDay.fromDateTime(DateTime.parse("2024-01-01 $endTime"));

      int startMinutes = start.hour * 60 + start.minute;
      int endMinutes = end.hour * 60 + end.minute;
      int durationMinutes = endMinutes - startMinutes;

      if (durationMinutes < 60) {
        return "$durationMinutes minutes";
      } else {
        int hours = durationMinutes ~/ 60;
        int minutes = durationMinutes % 60;
        return minutes > 0 ? "$hours hours $minutes minutes" : "$hours hours";
      }
    } catch (e) {
      return "Duration not available";
    }
  }

  static List<String> getMonthsInFinancialYear(
      String startDate, String endDate) {
    List<String> monthYearList = [];

    // Parse input dates
    DateTime start = DateTime.parse(startDate);
    DateTime end = DateTime.parse(endDate);

    // Ensure start <= end
    if (start.isAfter(end)) {
      DateTime temp = start;
      start = end;
      end = temp;
    }

    // Loop through months from start to end
    DateTime current = DateTime(start.year, start.month);
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      String monthName = _getMonthName(current.month);
      String formatted = "$monthName ${current.year}";
      monthYearList.add(formatted);

      // Move to next month
      current = DateTime(current.year, current.month + 1);
    }

    return monthYearList;
  }

  static String _getMonthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month - 1];
  }

  static String replaceSpaceWithUnderscore(String input) {
    return input.replaceAll(' ', '_');
  }

  static bool validateInput(String pattern, String value) {
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return true;
    }
    return false;
  }
  // else if (Utils.validateInput(r'^[0-9]{10}$', value)) {
  //   return 'Please enter a valid phone number';
  // }

  static allowInputFormatter(String regExp) {
    final value = [FilteringTextInputFormatter.allow(RegExp(regExp))];
    return value;
  }
//  inputFormatters:Utils.allowInputFormatter('[0-9.]'),

  static generateOTP() {
    const String chars = "0123456789";
    Random random = Random();
    String password = '';
    for (int i = 0; i < 6; i++) {
      int index = random.nextInt(chars.length);
      password += chars[index];
    }
    return password;
  }

  static int compareString(bool ascending, String value1, String value2) =>
      ascending ? value1.compareTo(value2) : value2.compareTo(value1);

  static Map searchMap(Map dataList, String search) {
    Map output = {};
    dataList.forEach((key, value) {
      String valueString = value.toString().toLowerCase();
      if (valueString.contains(search.toLowerCase())) {
        output[key] = value;
      }
    });
    return output;
  }

  static searchList(List<dynamic> dataList, String searchValue, String search) {
    List listWithVideo = dataList
        .where((element) => element[searchValue]
            .toString()
            .toLowerCase()
            .contains(search.toLowerCase()))
        .toList();
    return listWithVideo;
  }

  static storeMapInPrefs(Map<String, dynamic> map, String key) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(map);
    prefs.setString(key, jsonString);
  }

  static Future<Map<String, dynamic>> getMapFromPrefs(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = prefs.getString(key) ?? '{}';
    Map<String, dynamic> map = jsonDecode(jsonString);
    return map;
  }

  static convertCsvToListMap(List<List<dynamic>> fields) {
    List<Map<String, dynamic>> dataList = [];
    List headers = fields[0];
    fields.sublist(1).forEach((row) {
      Map<String, dynamic> data = {};
      for (var i = 0; i < headers.length; i++) {
        data[headers[i]] = row[i];
      }
      dataList.add(data);
    });
    return dataList;
  }

  static getImageSize(Uint8List imageBytes) async {
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frameInfo = await codec.getNextFrame();
    return Size(
      frameInfo.image.width.toDouble(),
      frameInfo.image.height.toDouble(),
    );
  }

  static String extractFileNameFromUrl(String url) {
    return url.split('/').last;
  }

  static Future<double> getAspectRatio(Uint8List imageBytes) async {
    final size = await getImageSize(imageBytes);
    return size.width / size.height;
  }

  static String formatFileSize(int sizeInBytes) {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    } else if (sizeInBytes < 1024 * 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  static bool isImageFile(String fileName) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    return imageExtensions.contains(getFileExtension(fileName).toLowerCase());
  }

  static String getFileExtension(String fileName) {
    return fileName.split('.').last;
  }

  static IconData getFileTypeIcon(String fileName) {
    final extension = Utils.getFileExtension(fileName).toLowerCase();

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_outlined;
      case 'txt':
        return Icons.text_snippet_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  static Color getFileTypeColor(String fileName) {
    final extension = Utils.getFileExtension(fileName).toLowerCase();

    switch (extension) {
      case 'pdf':
        return Colors.red[600]!;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Colors.purple[600]!;
      case 'doc':
      case 'docx':
        return Colors.blue[600]!;
      case 'xls':
      case 'xlsx':
        return Colors.green[600]!;
      case 'txt':
        return Colors.orange[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  static Color getStatusColor(status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
      case 'true':
      case '1':
      case 'active':
      case 'present':
      case 'passed':
      case 'approved':
        return Colors.green.shade600;
      case 'false':
      case '0':
      case 'inactive':
      case 'absent':
      case 'failed':
      case 'rejected':
        return Colors.red.shade600;
      case 'pending':
        return Colors.orange.shade600;
      case 'incomplete':
        return Colors.blue.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  static IconData getStatusIcon(status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
      case 'true':
      case '1':
      case 'active':
      case 'present':
      case 'passed':
      case 'approved':
        return Icons.check_circle;
      case 'false':
      case '0':
      case 'inactive':
      case 'absent':
      case 'failed':
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.pending;
      case 'incomplete':
        return Icons.incomplete_circle;
      default:
        return Icons.help;
    }
  }

  static String getStatusText(status) {
    switch (status.toLowerCase()) {
      case 'active':
        return "ACTIVE";
      case 'false' || '0':
        return "ABSENT";
      case 'true' || '1':
        return "PRESENT";
      case 'inactive':
        return "INACTIVE";
      case 'pass':
        return "PASSED";
      case 'fail':
        return "FAILED";
      case 'completed':
        return "COMPLETED";
      case 'pending':
        return "PENDING";
      case 'incomplete':
        return "INCOMPLETE";
      default:
        return "UNKNOWN";
    }
  }

  static Color getColorForGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'female':
        return Colors.pink;
      case 'male':
        return const ui.Color.fromRGBO(33, 150, 243, 1);
      default:
        return Colors.grey;
    }
  }

  static Color hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  static String getFileId(
      String className, String sectionCode, String examName, String subject) {
    String fileName = '';
    String classes = className.replaceAll(' ', '_');
    String exams = examName.replaceAll(' ', '_');
    fileName = classes + sectionCode + exams + subject;
    return fileName;
  }

  static String getServiceName(String key) {
    switch (key) {
      case 'participant_attendance':
        return 'Participant attendance';
      case 'topic_required':
        return 'Name of the topic';
      case 'remarks_required':
        return 'Remarks';
      case 'subject_list':
        return 'Subject list';
      case 'view':
        return 'View';
      case 'add':
        return 'Add';
      case 'edit':
        return 'Edit';
      case 'report':
        return 'Report';
      case 'master':
        return 'Master';
      case 'delete':
        return 'Delete';
      default:
        return key;
    }
  }

  static IconData getServiceIcon(String key) {
    switch (key) {
      case 'participant_attendance':
        return Icons.group_add;
      case 'topic_required':
        return Icons.check_circle_outline;
      case 'view':
        return Icons.visibility;
      case 'add':
        return Icons.add_circle_outline;
      case 'edit':
        return Icons.edit;
      case 'report':
        return Icons.bar_chart;
      case 'master':
        return Icons.settings;
      case 'delete':
        return Icons.delete;
      default:
        return Icons.inbox;
    }
  }

  static assetImageToUint8List(String path) async {
    ByteData bytes = await rootBundle.load(path);
    Uint8List list = bytes.buffer.asUint8List();
    return list;
  }

  static ImageToUint8List(String path) async {
    File imageTemp = File(path);
    Uint8List bytes = await imageTemp.readAsBytes();
    return bytes;
  }

  static downloadFile(Uint8List bytes, String fileName) async {
    try {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = fileName;
      anchor.click();
      html.Url.revokeObjectUrl(url);
      // ("Excel downloaded successfully.");
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  static downloadCSV(List<List<String>> fileData, String fileName) async {
    try {
      String csvData = ListToCsvConverter().convert(fileData);
      final bytes = utf8.encode(csvData);
      Utils.downloadFile(bytes, fileName);
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  // static downloadEXL(List<List<String>> fileData, String fileName) {
  //   var excel = exl.Excel.createExcel();
  //   exl.Sheet sheet = excel['Sheet1'];
  //   var headerStyle = exl.CellStyle(
  //       bold: true,
  //       backgroundColorHex: exl.ExcelColor.yellow,
  //       fontColorHex: exl.ExcelColor.black,
  //       fontSize: 10);
  //   for (var rowIndex = 0; rowIndex < fileData.length; rowIndex++) {
  //     var row = fileData[rowIndex];
  //     for (var colIndex = 0; colIndex < row.length; colIndex++) {
  //       var cellValue = row[colIndex];
  //       if (rowIndex == 0) {
  //         sheet
  //             .cell(CellIndex.indexByColumnRow(
  //                 columnIndex: colIndex, rowIndex: rowIndex))
  //             .value = TextCellValue(cellValue);
  //         sheet
  //             .cell(CellIndex.indexByColumnRow(
  //                 columnIndex: colIndex, rowIndex: rowIndex))
  //             .cellStyle = headerStyle;
  //       } else {
  //         sheet
  //             .cell(CellIndex.indexByColumnRow(
  //                 columnIndex: colIndex, rowIndex: rowIndex))
  //             .value = TextCellValue(cellValue);
  //       }
  //     }
  //   }
  //   List<int>? excelBytes = excel.encode();
  //   Utils.downloadFile(Uint8List.fromList(excelBytes!), fileName);
  // }

  static String errorServer(int status) {
    String errorServer = 'Server Error. Please try again later.';
    if (status == 400) {
      errorServer = 'Bad Request. Please try again later.';
    } else if (status == 401) {
      errorServer = 'Unauthorized. Please try again later.';
    } else if (status == 403) {
      errorServer = 'Forbidden. Please try again later.';
    } else if (status == 404) {
      errorServer = 'Not Found. Please try again later.';
    } else if (status == 500) {
      errorServer = 'Internal Server Error. Please try again later.';
    } else if (status == 502) {
      errorServer = 'Internal Server Error. Please try again later.';
    } else if (status == 503) {
      errorServer = 'Service Unavailable. Please try again later.';
    }
    return errorServer;
  }

  static downloadEXL(
    Map<String, List<List<String>>> sheetsData,
    String fileName, {
    List readOnlyColumns = const [],
  }) {
    var excel = exl.Excel.createExcel();

    if (excel.sheets.containsKey('Sheet1') &&
        !(sheetsData.containsKey('Sheet1'))) {
      excel.delete('Sheet1');
    }

    var headerStyle = exl.CellStyle(
        bold: true,
        backgroundColorHex: exl.ExcelColor.yellow,
        fontColorHex: exl.ExcelColor.black,
        fontSize: 10);

    // Style for read-only columns (visual indication)
    var readOnlyStyle = exl.CellStyle(
        backgroundColorHex: exl.ExcelColor.grey100,
        fontColorHex: exl.ExcelColor.grey,
        fontSize: 10);

    // Style for editable columns
    var editableStyle = exl.CellStyle(
        backgroundColorHex: exl.ExcelColor.white,
        fontColorHex: exl.ExcelColor.black,
        fontSize: 10);

    sheetsData.forEach((sheetName, fileData) {
      exl.Sheet sheet = excel[sheetName];

      for (var rowIndex = 0; rowIndex < fileData.length; rowIndex++) {
        var row = fileData[rowIndex];
        for (var colIndex = 0; colIndex < row.length; colIndex++) {
          var cellValue = row[colIndex];
          var cell = sheet.cell(CellIndex.indexByColumnRow(
              columnIndex: colIndex, rowIndex: rowIndex));
          cell.value = TextCellValue(cellValue);

          if (rowIndex == 0) {
            cell.cellStyle = headerStyle;
          } else {
            cell.cellStyle = readOnlyColumns.contains(colIndex)
                ? readOnlyStyle
                : editableStyle;
          }
        }
      }

      // if (readOnlyColumns.isNotEmpty) {
      //   var noteCell = sheet.cell(CellIndex.indexByColumnRow(
      //       columnIndex: 0, rowIndex: fileData.length + 1));
      //   noteCell.value = TextCellValue("Note: Grey columns are read-only");
      // }
    });

    List<int>? excelBytes = excel.encode();
    Utils.downloadFile(Uint8List.fromList(excelBytes!), fileName);
  }

  static loadJson() async {
    var data = await rootBundle.loadString("assets/jsons/question.json");
    Map questionData = json.decode(data);
    List<Map<String, dynamic>> output =
        List<Map<String, dynamic>>.from(questionData['questions']);

    return output;
  }
}
