import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/models/associate_model.dart';
import 'package:sterlite_csr/models/indicator_model.dart';
import 'package:sterlite_csr/models/project_model.dart';
import 'package:sterlite_csr/utilities/method_utils.dart';
import 'package:sterlite_csr/utilities/widget_decoration.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sterlite_csr/models/budget_model.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/utils/search-dropdown_utils.dart';
import 'package:sterlite_csr/screens/master/associate_project/associate_project_list.dart';

class AssociateProjectSummary extends StatefulWidget {
  const AssociateProjectSummary({super.key});

  @override
  _AssociateProjectSummaryState createState() =>
      _AssociateProjectSummaryState();
}

class _AssociateProjectSummaryState extends State<AssociateProjectSummary> {
  final _formKey = GlobalKey<FormState>();
  APIController apiController = Get.put(APIController());

  bool isFind = false;
  String msg = 'Please wait...';

  String userRole = "";
  String userId = "";

  Map<String, dynamic> budget_map = {};

  Map<String, Map<String, TextEditingController>> controllers = {};
  Map<String, double> totals = {};

  List<String> genderList = [];
  List<String> defaultHeaders = [
    "Gender",
    "Age Group",
    'Calculated',
    'Rectified'
  ];

  BudgetModel? budget_data;
  AssociateModel? project_data;

  bool _isEdit = false;

  bool _isControllersInitialized = false;
  bool _isDataLoaded = false;

  String selectedProject = "";
  List<ProjectModel> projectOptions = [];

  String selectedAssociate = "";
  List<AssociateModel> associateOptions = [];

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isDesktop = constraints.maxWidth > 600;
      return Scaffold(
        appBar: UtilsWidgets.buildAppBar(
            _isEdit ? 'Associate Project Summary' : 'Associate Project Summary',
            Get.isDarkMode,
            leading: isDesktop
                ? null
                : Container(
                    margin: const EdgeInsets.only(left: 15, bottom: 25),
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                  ),
            Widgets: [
              TextButton.icon(
                icon: Icon(Icons.upload,
                    size: 16,
                    color:
                        Get.isDarkMode ? Colors.white : Constants.primaryColor),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AssociateProjectList(),
                  ),
                ),
                label: Text('Add Bulk Budget',
                    style: TextStyle(
                      color: Get.isDarkMode
                          ? Colors.white
                          : Constants.primaryColor,
                      fontWeight: FontWeight.bold,
                    )),
              )
            ]),
        body: !_isDataLoaded
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child:
                                  SearchDropdownUtils.buildSearchableDropdown(
                                items: projectOptions
                                    .map((project) => project.project_name)
                                    .toList(),
                                value: selectedProject,
                                label: "Project",
                                icon: Icons.map,
                                hint: "Select project",
                                onChanged: (value) async {
                                  if (value != null) {
                                    setState(() {
                                      selectedProject = value;
                                      selectedAssociate = '';
                                      associateOptions.clear();
                                    });
                                  }
                                  await getAssociateInfo();
                                },
                                displayTextFn: (item) => item,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please select a project";
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            Flexible(
                              child: SearchDropdownUtils
                                  .buildSearchableDropdown<String>(
                                items: associateOptions
                                    .map((city) => city.associate_project_name)
                                    .toList(),
                                value: selectedAssociate,
                                label: "Associate Project",
                                icon: Icons.location_city,
                                hint: "Select associate project",
                                onChanged: (value) async {
                                  if (value != null) {
                                    setState(() {
                                      selectedAssociate = value;
                                      project_data = associateOptions
                                          .firstWhere((element) =>
                                              element.associate_project_name ==
                                              value);
                                      getIndicatorInfo();
                                    });
                                  }
                                },
                                displayTextFn: (item) => item,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please select a associate project";
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        !isFind
                            ? Center(
                                child: DecorationWidgets.filterTextStyle(msg))
                            : Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 20),
                                    if (_isControllersInitialized &&
                                        defaultHeaders.isNotEmpty)
                                      _buildDataTable(),
                                    const SizedBox(height: 20),
                                    Obx(() => apiController.isLoading.value
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 16.0, 0, 16.0),
                                            child: UtilsWidgets.buildPrimaryBtn(
                                              context,
                                              _isEdit
                                                  ? 'Update Associate Project Summary'
                                                  : 'Add Associate Project Summary',
                                              () async {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  if (totals.values.fold<
                                                              double>(
                                                          0.0,
                                                          (previousValue,
                                                                  element) =>
                                                              previousValue +
                                                              element) ==
                                                      0) {
                                                    UtilsWidgets.showToastFunc(
                                                        'Total budget cannot be zero.');
                                                  } else if (totals.values.fold<
                                                              double>(
                                                          0.0,
                                                          (previousValue,
                                                                  element) =>
                                                              previousValue +
                                                              element) >
                                                      int.parse(project_data!
                                                          .total_budget)) {
                                                    UtilsWidgets.showToastFunc(
                                                        'Entered budget cannot be more than total project budget.');
                                                  } else {
                                                    await _submitForm();
                                                  }
                                                }
                                              },
                                            ),
                                          )),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
      );
    });
  }

  Widget _buildDataTable() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          border: TableBorder.all(color: Colors.grey.shade300, width: 1),
          headingRowColor: MaterialStateProperty.all(Colors.blue.shade50),
          columnSpacing: 20,
          columns: const [
            DataColumn(
              label: Text(
                'Gender',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                'Calculated',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                'Rectified',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
          rows: genderList.map((genders) {
            // Parse the genders string to extract age and gender
            // Format is "age - gender" (e.g., "0-18 - Male")
            List<String> parts = genders.split(' - ');
            String ageBucket = parts.length > 0 ? parts[0] : '';
            String gender = parts.length > 1 ? parts[1] : '';

            return DataRow(
              cells: [
                DataCell(
                  Text(
                    gender, // Now shows the actual gender (Male/Female)
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    ageBucket, // Shows the age bucket (0-18, 19-35, etc.)
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    width: 150,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.cyan.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextField(
                      controller: controllers[genders]?['calculated'],
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                      ],
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        hintText: '0',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      style: const TextStyle(fontSize: 14),
                      onChanged: (value) => _calculateTotal(genders),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    width: 150,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.cyan.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextField(
                      controller: controllers[genders]?['rectified'],
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                      ],
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        hintText: '0',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      style: const TextStyle(fontSize: 14),
                      onChanged: (value) => _calculateTotal(genders),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> getUserInfo() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        userId = prefs.getString('user_id') ?? '';
        userRole = prefs.getString('role') ?? '';
      });
      await getProjectInfo();
    } catch (e) {
      UtilsWidgets.showToastFunc('Error loading data: ${e.toString()}');
    } finally {
      setState(() {
        _isDataLoaded = true;
      });
    }
  }

  Future getProjectInfo() async {
    setState(() {
      projectOptions.clear();
    });
    try {
      String uri = Constants.MASTER_URL + '/main-project';
      Map params = {"action": "list"};
      Map tempMap = await MethodUtils.apiCall(uri, params);
      setState(() {
        isFind = tempMap['isValid'];
        if (isFind) {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            projectOptions.add(ProjectModel.fromJson(item));
          }
          msg = 'Select a project and associate project to view indicators';
        } else {
          msg = tempMap['message'];
        }
      });
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  Future getAssociateInfo() async {
    setState(() {
      associateOptions.clear();
    });
    try {
      String uri = Constants.OPERATION_URL + '/associate-project';
      Map params = {
        "action": "list",
        "project_code": projectOptions
            .firstWhere((element) => element.project_name == selectedProject)
            .project_code,
      };
      Map tempMap = await MethodUtils.apiCall(uri, params);
      setState(() {
        isFind = tempMap['isValid'];
        if (isFind) {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            associateOptions.add(AssociateModel.fromJson(item));
          }
          msg = 'Select a city to view indicators';
        } else {
          msg = tempMap['message'];
        }
      });
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  Future getIndicatorInfo() async {
    try {
      String uri = Constants.OPERATION_URL + '/beneficiary-indicator';
      Map params = {
        "action": "get",
        "project_code": projectOptions
            .firstWhere((element) => element.project_name == selectedProject)
            .project_code,
        "associate_project_code": associateOptions
            .firstWhere((element) =>
                element.associate_project_name == selectedAssociate)
            .associate_project_code,
      };
      Map<String, dynamic> tempMap = await apiController.fetchData(uri, params);

      setState(() {
        isFind = tempMap['isValid'];
        if (isFind) {
          print(tempMap);
          Map<String, dynamic> tempList = tempMap['info'][0];
          IndicatorModel data = IndicatorModel.fromJson(tempList);

          Map<String, dynamic> indicator_map = data.indicator_map;
          List<String> ageList = List<String>.from(indicator_map['age']);
          List<String> genList = List<String>.from(indicator_map['gender']);
          print(indicator_map);
          for (var age in ageList) {
            for (var gender in genList) {
              genderList.add('$age - $gender');
            }
          }
          _initializeControllers();
        } else {
          msg = tempMap['message'];
        }
      });
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  void _initializeControllers() {
    controllers = {};
    totals = {};

    for (String genders in genderList) {
      controllers[genders] = {};
      totals[genders] = 0.0;

      // Add controllers for Calculated and Rectified fields
      controllers[genders]!['calculated'] = TextEditingController();
      controllers[genders]!['rectified'] = TextEditingController();

      // Load existing values if editing
      if (budget_map.isNotEmpty) {
        String calculatedValue = _getExistingValue(genders, 'calculated');
        String rectifiedValue = _getExistingValue(genders, 'rectified');
        controllers[genders]!['calculated']!.text = calculatedValue;
        controllers[genders]!['rectified']!.text = rectifiedValue;
      }

      // Add listeners
      controllers[genders]!['calculated']!
          .addListener(() => _calculateTotal(genders));
      controllers[genders]!['rectified']!
          .addListener(() => _calculateTotal(genders));
    }

    for (String genders in genderList) {
      _calculateTotal(genders);
    }

    setState(() {
      _isControllersInitialized = true;
    });
  }

  String _getExistingValue(String genders, String budgetKey) {
    try {
      if (budget_map.containsKey(genders) &&
          budget_map[genders] != null &&
          budget_map[genders][budgetKey] != null) {
        var value = budget_map[genders][budgetKey];
        if (value != null) {
          double doubleValue = double.tryParse(value.toString()) ?? 0.0;
          return doubleValue == 0.0 ? "" : doubleValue.toString();
        }
      }
    } catch (e) {
      UtilsWidgets.showToastFunc(
          'Error getting existing value for $genders - $budgetKey: $e');
    }
    return "";
  }

  void _calculateTotal(String genders) {
    double total = 0.0;
    if (controllers[genders] != null) {
      // Calculate from both calculated and rectified fields
      TextEditingController? calculatedController =
          controllers[genders]!['calculated'];
      TextEditingController? rectifiedController =
          controllers[genders]!['rectified'];

      if (calculatedController != null &&
          calculatedController.text.isNotEmpty) {
        total += double.tryParse(calculatedController.text) ?? 0.0;
      }
      if (rectifiedController != null && rectifiedController.text.isNotEmpty) {
        total += double.tryParse(rectifiedController.text) ?? 0.0;
      }
    }
    setState(() {
      totals[genders] = total;
    });
  }

  Future<void> _submitForm() async {
    try {
      Map<String, Map<String, String>> budgetData = {};
      for (String genders in genderList) {
        budgetData[genders] = {};
        for (var budgetKey in defaultHeaders) {
          TextEditingController? controller = controllers[genders]?[budgetKey];
          if (controller != null) {
            double value = double.tryParse(controller.text) ?? 0.0;
            budgetData[genders]![budgetKey] = value.toString();
          }
        }
      }

      String uri = Constants.MASTER_URL + '/associate-project-summary';
      Map params = {
        "user_id": userId,
        "action": _isEdit ? "update" : "add",
        "budget_map": budgetData,
        'associate_project_code': project_data!.associate_project_code,
        'project_code': project_data!.project_code,
      };

      Map<String, dynamic> tempMap = await apiController.fetchData(uri, params);

      bool isFind = tempMap['isValid'] ?? false;
      if (isFind) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Budget ${_isEdit ? "Updated" : "Added"} Successfully!')),
        );
        Get.back(result: true);
      } else {
        String msg = tempMap['message'] ?? 'Operation failed';
        UtilsWidgets.showToastFunc(msg);
      }
    } catch (e) {
      UtilsWidgets.showToastFunc('Error: ${e.toString()}');
    }
  }
}
