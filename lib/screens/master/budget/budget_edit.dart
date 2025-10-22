import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/models/associate_model.dart';
import 'package:sterlite_csr/utilities/function_utils.dart';
import 'package:sterlite_csr/utilities/method_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sterlite_csr/models/budget_model.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/utils/radiobutton_utils.dart';
import 'package:sterlite_csr/screens/master/associate_project/associate_project_list.dart';

class EditBudget extends StatefulWidget {
  final AssociateModel? associate_project;
  const EditBudget({super.key, required this.associate_project});

  @override
  _EditBudgetState createState() => _EditBudgetState();
}

class _EditBudgetState extends State<EditBudget> {
  final _formKey = GlobalKey<FormState>();
  APIController apiController = Get.put(APIController());

  String userRole = "";
  String userId = "";

  Map<String, dynamic> budget_map = {};

  Map<String, Map<String, TextEditingController>> controllers = {};
  Map<String, double> totals = {};

  List<String> months = [];

  List<String> defaultBudgets = [];

  BudgetModel? budget_data;
  AssociateModel? project_data;

  bool _isEdit = false;

  List<String> statusList = ['Active', 'Inactive'];
  String statusName = 'Active';

  bool _isControllersInitialized = false;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    for (String month in months) {
      if (controllers[month] != null) {
        for (String budgetOption in controllers[month]!.keys) {
          controllers[month]![budgetOption]?.dispose();
        }
      }
    }
    controllers.clear();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isDesktop = constraints.maxWidth > 600;
      return Scaffold(
        appBar: UtilsWidgets.buildAppBar(
            _isEdit ? 'Edit Budget' : 'Add Budget', Get.isDarkMode,
            leading: Container(
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          if (_isControllersInitialized &&
                              defaultBudgets.isNotEmpty)
                            _buildDataTable(),
                          const SizedBox(height: 20),
                          RadioButtonUtils.buildRadioGroup<String>(
                            items: statusList,
                            selectedValue: statusName,
                            label: "Status",
                            icon: Icons.toggle_on,
                            onChanged: (value) {
                              setState(() {
                                statusName = value ?? '';
                              });
                            },
                            displayTextFn: (item) => item,
                            horizontal: true,
                          ),
                          const SizedBox(height: 20),
                          Obx(() => apiController.isLoading.value
                              ? const Center(child: CircularProgressIndicator())
                              : Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0, 16.0, 0, 16.0),
                                  child: UtilsWidgets.buildPrimaryBtn(
                                    context,
                                    _isEdit ? 'Update Budget' : 'Add Budget',
                                    () async {
                                      // print(totals.values.fold<double>(
                                      //     0.0,
                                      //     (previousValue, element) =>
                                      //         previousValue + element));
                                      if (_formKey.currentState!.validate()) {
                                        if (totals.values.fold<double>(
                                                0.0,
                                                (previousValue, element) =>
                                                    previousValue + element) ==
                                            0) {
                                          UtilsWidgets.showToastFunc(
                                              'Total budget cannot be zero.');
                                        } else if (totals.values.fold<double>(
                                                0.0,
                                                (previousValue, element) =>
                                                    previousValue + element) >
                                            int.parse(
                                                project_data!.total_budget)) {
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
          columns: [
            const DataColumn(
              label: Text(
                'Month',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ...defaultBudgets.map(
              (budgetOption) => DataColumn(
                label: Text(
                  budgetOption.toString().replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Constants.redColor,
                ),
              ),
            ),
          ],
          rows: months.map((month) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    month,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                ...defaultBudgets.map((budgetOption) {
                  final controller =
                      controllers[month]?[budgetOption.toString()];
                  if (controller == null) {
                    return const DataCell(SizedBox.shrink());
                  }
                  return DataCell(
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*'))
                        ],
                        decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          hintText: '0',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                }),
                DataCell(
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      (totals[month] ?? 0.0).toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Constants.redColor,
                        fontSize: 14,
                      ),
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
        project_data = widget.associate_project;
      });
      int total_milestones = int.parse(project_data!.milestone);

      String start_date = project_data!.start_date;
      String end_date = project_data!.end_date;

      months = Utils.getMonthsInFinancialYear(start_date, end_date);

      defaultBudgets =
          List.generate(total_milestones, (index) => 'Milestone ${index + 1}');

      await fetchBudgetInfo(
          project_data!.associate_project_code, project_data!.financial_year);

      _initializeControllers();
    } catch (e) {
      UtilsWidgets.showToastFunc('Error loading data: ${e.toString()}');
    } finally {
      setState(() {
        _isDataLoaded = true;
      });
    }
  }

  Future fetchBudgetInfo(
      String associate_project_code, String financial_year) async {
    try {
      String uri = Constants.MASTER_URL + '/budget';
      Map params = {
        "action": "get",
        'associate_project_code': associate_project_code,
        'financial_year': financial_year
      };

      Map<String, dynamic> tempMap = await MethodUtils.apiCall(uri, params);

      setState(() {
        _isEdit = tempMap['isValid'];
        if (_isEdit) {
          budget_data = BudgetModel.fromJson(tempMap['info']);
          budget_map = budget_data!.budget_map;
          statusName = budget_data!.status ? 'Active' : 'Inactive';
        } else {
          String msg = tempMap['message'] ?? "Failed to load budget data";
          UtilsWidgets.showToastFunc(msg);
        }
      });
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  void _initializeControllers() {
    _disposeControllers();

    controllers = {};
    totals = {};

    for (String month in months) {
      controllers[month] = {};
      totals[month] = 0.0;

      for (var budgetKey in defaultBudgets) {
        controllers[month]![budgetKey] = TextEditingController();

        if (budget_map.isNotEmpty) {
          String value = _getExistingValue(month, budgetKey);
          controllers[month]![budgetKey]!.text = value;
        }

        controllers[month]![budgetKey]!
            .addListener(() => _calculateTotal(month));
      }
    }

    for (String month in months) {
      _calculateTotal(month);
    }

    setState(() {
      _isControllersInitialized = true;
    });
  }

  String _getExistingValue(String month, String budgetKey) {
    try {
      if (budget_map.containsKey(month) &&
          budget_map[month] != null &&
          budget_map[month][budgetKey] != null) {
        var value = budget_map[month][budgetKey];
        if (value != null) {
          double doubleValue = double.tryParse(value.toString()) ?? 0.0;
          return doubleValue == 0.0 ? "" : doubleValue.toString();
        }
      }
    } catch (e) {
      UtilsWidgets.showToastFunc(
          'Error getting existing value for $month - $budgetKey: $e');
    }
    return "";
  }

  void _calculateTotal(String month) {
    double total = 0.0;
    if (controllers[month] != null) {
      for (var budgetKey in defaultBudgets) {
        TextEditingController? controller = controllers[month]![budgetKey];
        if (controller != null && controller.text.isNotEmpty) {
          total += double.tryParse(controller.text) ?? 0.0;
        }
      }
    }
    setState(() {
      totals[month] = total;
    });
  }

  Future<void> _submitForm() async {
    try {
      Map<String, Map<String, String>> budgetData = {};
      for (String month in months) {
        budgetData[month] = {};
        for (var budgetKey in defaultBudgets) {
          TextEditingController? controller = controllers[month]?[budgetKey];
          if (controller != null) {
            double value = double.tryParse(controller.text) ?? 0.0;
            budgetData[month]![budgetKey] = value.toString();
          }
        }
      }

      String uri = Constants.MASTER_URL + '/budget';
      Map params = {
        "user_id": userId,
        "action": _isEdit ? "update" : "add",
        "budget_map": budgetData,
        "status": statusName == 'Active',
        'associate_project_code': project_data!.associate_project_code,
        'project_code': project_data!.project_code,
        // 'consume_budget': totals.values
        //     .fold<double>(
        //         0.0, (previousValue, element) => previousValue + element)
        //     .toString(),
        'total_budget': project_data!.total_budget,
        'financial_year': project_data!.financial_year,
        'milestone': defaultBudgets.length.toString(),
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
