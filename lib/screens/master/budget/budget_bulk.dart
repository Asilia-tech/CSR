import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as exl;
import 'package:file_picker/file_picker.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/models/financial_model.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/function_utils.dart';
import 'package:sterlite_csr/utilities/method_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sterlite_csr/utilities/utils/search-dropdown_utils.dart';

class AddBulkBudget extends StatefulWidget {
  const AddBulkBudget({super.key});

  @override
  State<AddBulkBudget> createState() => _AddBulkBudgetState();
}

class _AddBulkBudgetState extends State<AddBulkBudget>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  List finalMap = [];
  bool _isLoading = false;
  bool _isUploaded = false;
  Map records = {};
  List results = [];

  APIController apiController = Get.put(APIController());
  String userId = "";
  String userRole = "";
  String verticalCode = "";

  late AnimationController loadingController;
  PlatformFile? _platformFile;

  List<FinancialModel> financialOptions = [];
  String selectedFinancial = '';

  @override
  void initState() {
    super.initState();
    getOfflineData();
    loadingController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UtilsWidgets.buildAppBar("Budget Bulk Upload", Get.isDarkMode,
          leading: Container(
            margin: const EdgeInsets.only(left: 15, bottom: 25),
            child: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),
          )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SearchDropdownUtils.buildSearchableDropdown<String>(
                      items: financialOptions.map((e) => e.name).toList(),
                      label: 'Financial',
                      value:
                          selectedFinancial.isEmpty ? null : selectedFinancial,
                      icon: Icons.list,
                      hint: 'Choose...',
                      onChanged: (p0) async {
                        setState(() {
                          selectedFinancial = p0 ?? '';
                        });
                      },
                      displayTextFn: (item) => item,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Required field'
                          : null,
                      showSearchBox: true,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text:
                                    'The uploaded file must be formatted similar to this ',
                                style: TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: 'CSV Template',
                                    style: TextStyle(
                                      color: Constants.primaryColor,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        if (_formKey.currentState!.validate()) {
                                          String financial_code =
                                              financialOptions
                                                  .firstWhere((element) =>
                                                      element.name ==
                                                      selectedFinancial)
                                                  .financial_year_code;
                                          await MethodUtils.downloadDemoFile({
                                            "financial_code": financial_code
                                          }, "/elc_target");
                                        }
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              uploadCSV();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.blue.shade50.withOpacity(.3),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_upload,
                                    color: Constants.primaryColor,
                                    size: 50,
                                  ),
                                  SizedBox(height: 5),
                                  const Text(
                                    'Excel Format | Maximum file size :10MB',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _isUploaded
                              ? Container(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Select the file',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey,
                                                  offset: Offset(0, 1),
                                                  blurRadius: 3,
                                                  spreadRadius: 2,
                                                )
                                              ]),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Icon(
                                                      Icons.file_present,
                                                      size: 50)),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _platformFile!.name,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      '${(_platformFile!.size / 1024).ceil()} KB',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors
                                                              .grey.shade500),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Container(
                                                        height: 5,
                                                        clipBehavior:
                                                            Clip.hardEdge,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          color: Colors
                                                              .blue.shade50,
                                                        ),
                                                        child:
                                                            LinearProgressIndicator(
                                                          value:
                                                              loadingController
                                                                  .value,
                                                        )),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _platformFile = null;
                                                        _isUploaded = false;
                                                        loadingController
                                                            .reset();
                                                        loadingController
                                                            .stop();
                                                        results.clear();
                                                        records.clear();
                                                      });
                                                    },
                                                    icon: Icon(
                                                      Icons.delete_forever,
                                                      color: Constants.redColor,
                                                      size: 25,
                                                    ),
                                                  )),
                                            ],
                                          )),
                                    ],
                                  ))
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  results.isNotEmpty
                      ? Center(
                          child: Container(
                            child: DataTable(
                              showBottomBorder: true,
                              border: TableBorder.all(),
                              dataTextStyle:
                                  const TextStyle(color: Colors.black),
                              headingTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              headingRowColor:
                                  MaterialStateColor.resolveWith((states) {
                                return Constants.primaryColor;
                              }),
                              columns: [
                                DataColumn(label: Text('Record')),
                                DataColumn(label: Text('Field')),
                                DataColumn(label: Text('message')),
                              ],
                              rows: results
                                  .map((e) => DataRow(cells: [
                                        DataCell(Text(e['record'] ?? "")),
                                        DataCell(Text(e['field'] ?? "")),
                                        DataCell(Text(e['message'] ?? "")),
                                      ]))
                                  .toList(),
                            ),
                          ),
                        )
                      : Container(),
                  records.isNotEmpty
                      ? Center(
                          child: Container(
                            child: DataTable(
                              showBottomBorder: true,
                              border: TableBorder.all(),
                              dataTextStyle: const TextStyle(
                                color: Colors.black,
                              ),
                              headingTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              headingRowColor:
                                  MaterialStateColor.resolveWith((states) {
                                return Constants.primaryColor;
                              }),
                              columns: [
                                DataColumn(label: Text('Bulk Code')),
                                DataColumn(label: Text('issue')),
                              ],
                              rows: records.entries
                                  .map((e) => DataRow(cells: [
                                        DataCell(Text(e.key.toString())),
                                        DataCell(Text(e.value)),
                                      ]))
                                  .toList(),
                            ),
                          ),
                        )
                      : Container(),
                  SizedBox(height: 10),
                  _isUploaded
                      ? Container(
                          padding: EdgeInsets.all(10),
                          child: _isLoading
                              ? Center(child: CircularProgressIndicator())
                              : MaterialButton(
                                  minWidth: double.infinity,
                                  height: 45,
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      readCSV();
                                    }
                                  },
                                  color: Constants.primaryColor,
                                  child: Text(
                                    'Bulk Upload Data',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ))
                      : Container(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  getOfflineData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id') ?? '';
      userRole = prefs.getString('role') ?? '';
      verticalCode = prefs.getString('code') ?? '';
    });
    await getFinancialInfo();
  }

  Future<void> getFinancialInfo() async {
    try {
      setState(() {
        financialOptions.clear();
      });

      String uri = Constants.MASTER_URL + '/financial-year';
      Map params = {"action": "list"};

      Map<String, dynamic> tempMap = await MethodUtils.apiCall(uri, params);

      bool isFind = tempMap['isValid'] ?? false;

      if (isFind) {
        setState(() {
          List tempList = tempMap['info'] ?? [];
          for (var item in tempList) {
            financialOptions.add(FinancialModel.fromJson(item));
          }
          if (financialOptions.isNotEmpty) {
            selectedFinancial = financialOptions.first.name;
          }
        });
      } else {
        String msg = tempMap['message'] ?? 'Failed to load financial years';
        UtilsWidgets.showToastFunc(msg);
      }
    } catch (e) {
      UtilsWidgets.showToastFunc(
          'Error loading financial years: ${e.toString()}');
    }
  }

  Future uploadCSV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowMultiple: false,
          allowedExtensions: ['csv', 'xlsx']);
      if (result != null) {
        setState(() {
          _platformFile = result.files.first;
          _isUploaded = true;
        });
        loadingController.forward();
      }
    } catch (e) {
      UtilsWidgets.showToastFunc(e);
    }
  }

  readCSV() async {
    try {
      setState(() {
        records.clear();
      });
      List<List<dynamic>> csvData = [];
      if (_platformFile!.extension == 'xlsx') {
        var bytes = _platformFile?.bytes;
        var excel = exl.Excel.decodeBytes(bytes!.toList());
        final sheet = excel[excel.tables.keys.first];
        csvData = sheet.rows
            .map((row) =>
                row.map((cell) => cell?.value?.toString() ?? "").toList())
            .toList();
      } else {
        var bytes = _platformFile?.bytes;
        String csvString = utf8.decode(bytes!);
        csvData = const CsvToListConverter().convert(csvString);
      }
      List<Map<String, dynamic>> dataList = Utils.convertCsvToListMap(csvData);
      List<Map<String, dynamic>> finalList = [];

      List<Map<String, dynamic>> filteredDataList = dataList.where((data) {
        String schoolCode = data['school_code']?.toString() ?? "";
        return schoolCode.isNotEmpty && schoolCode != null && schoolCode != '';
      }).toList();

      setState(() {
        for (Map<String, dynamic> data in filteredDataList) {
          String elcName = data['school_name']?.toString() ?? "";
          String schoolCode = data['school_code']?.toString() ?? "";
          String target = data['target']?.toString() ?? "";

          List<String> validationErrors = [];

          if (elcName.isEmpty) {
            validationErrors.add("ELC name is required");
          }

          if (schoolCode.isEmpty) {
            validationErrors.add("Bulk code is required");
          }
          if (target.isEmpty) {
            validationErrors.add("Budget is required");
          }

          if (validationErrors.isNotEmpty) {
            records[schoolCode.isEmpty
                ? "Row ${dataList.indexOf(data) + 1}"
                : schoolCode] = validationErrors.join(", ");
          } else {
            Map<String, dynamic> temp = {};
            Map<String, dynamic> params = {
              "user_id": userId,
              "school_name": elcName,
              "school_code": schoolCode,
              "target": target,
              "financial_year": selectedFinancial,
            };
            temp.addAll(params);
            finalList.add(temp);
          }
        }
      });

      if (records.isEmpty) {
        await addBudgetData(finalList);
        UtilsWidgets.showToastFunc(
            "${finalList.length} targets processed successfully");
      } else {
        UtilsWidgets.showToastFunc(
            "${records.length} validation errors found. Please check the error report.");
      }
    } catch (e) {
      UtilsWidgets.showToastFunc("Error processing file: ${e.toString()}");
    }
  }

  Future<void> addBudgetData(List dataList) async {
    if (dataList.isEmpty) {
      UtilsWidgets.showToastFunc("Cannot upload an empty list.");
      return;
    }

    try {
      setState(() {
        results.clear();
        _isLoading = true;
      });

      String uri = Constants.BULK_URL + '/bulkaddelctarget';
      Map<String, dynamic> params = {'schools': dataList};

      Map<String, dynamic> tempMap = await MethodUtils.apiCall(uri, params);

      if (tempMap['isValid']) {
        selectedFinancial = '';
        _platformFile = null;
        _isUploaded = false;
        results.clear();
        loadingController.reset();
        loadingController.stop();
        UtilsWidgets.showGetDialog(
            context, tempMap['message'] ?? 'Success!', Constants.greenColor,
            title: 'Success');
      } else {
        results = tempMap["errors"] ?? [];
        UtilsWidgets.showGetDialog(context,
            tempMap['message'] ?? 'An error occurred.', Constants.redColor);
      }
    } catch (e) {
      UtilsWidgets.showToastFunc("Error processing file: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
