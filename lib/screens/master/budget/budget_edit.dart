import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/models/financial_model.dart';
import 'package:sterlite_csr/models/district_model.dart';
import 'package:sterlite_csr/models/project_model.dart';
import 'package:sterlite_csr/models/state_model.dart';
import 'package:sterlite_csr/utilities/method_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sterlite_csr/models/budget_model.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/function_utils.dart';
import 'package:sterlite_csr/utilities/utils/radiobutton_utils.dart';
import 'package:sterlite_csr/utilities/utils/search-dropdown_utils.dart';
import 'package:sterlite_csr/screens/master/budget/budget_bulk.dart';

class EditBudget extends StatefulWidget {
  final bool isEdit;
  final BudgetModel? budget;
  const EditBudget({super.key, this.isEdit = false, this.budget});

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

  List<String> months = Constants.months;

  List<String> defaultBudgets = [];

  List<FinancialModel> financialOptions = [];
  String selectedFinancial = '';

  String selectedState = "";
  List<StateModel> stateOptions = [];

  String selectedDistrict = "";
  List<DistrictModel> districtOptions = [];

  BudgetModel? data;

  String selectedProject = "";
  List<ProjectModel> projectOptions = [];

  List<String> statusList = ['Active', 'Inactive'];
  String statusName = 'Active';

  String selectedBudgetType = '';

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
            widget.isEdit ? 'Edit Budget' : 'Add Budget', Get.isDarkMode,
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
                    builder: (context) => const AddBulkBudget(),
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
                          _buildOtherLayout(isDesktop),
                          Row(
                            children: [
                              Flexible(
                                child:
                                    SearchDropdownUtils.buildSearchableDropdown(
                                  items:
                                      stateOptions.map((e) => e.name).toList(),
                                  value: selectedState.isEmpty
                                      ? null
                                      : selectedState,
                                  label: "State",
                                  icon: Icons.map,
                                  hint: "Select state",
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        selectedState = value;
                                        selectedDistrict = "";
                                      });
                                      getDistrictInfo();
                                    }
                                  },
                                  displayTextFn: (item) => item,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please select a state";
                                    }
                                  },
                                ),
                              ),
                              Flexible(
                                child:
                                    SearchDropdownUtils.buildSearchableDropdown(
                                  items: districtOptions
                                      .map((e) => e.name)
                                      .toList(),
                                  value: selectedDistrict.isEmpty
                                      ? null
                                      : selectedDistrict,
                                  label: "District",
                                  icon: Icons.location_city,
                                  hint: "Select district",
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        selectedDistrict = value;
                                      });
                                    }
                                  },
                                  displayTextFn: (item) => item,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please select a district";
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
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
                          if (_isControllersInitialized &&
                              defaultBudgets.isNotEmpty)
                            _buildDataTable(),
                          const SizedBox(height: 20),
                          Obx(() => apiController.isLoading.value
                              ? const Center(child: CircularProgressIndicator())
                              : Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0, 16.0, 0, 16.0),
                                  child: UtilsWidgets.buildPrimaryBtn(
                                    context,
                                    widget.isEdit
                                        ? 'Update Budget'
                                        : 'Add Budget',
                                    () async {
                                      if (_formKey.currentState!.validate()) {
                                        await _submitForm();
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

  Widget _buildOtherLayout(bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                if (!widget.isEdit) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 48.0),
                      child:
                          SearchDropdownUtils.buildSearchableDropdown<String>(
                        items: financialOptions.map((e) => e.name).toList(),
                        label: 'Financial Year',
                        value: selectedFinancial.isEmpty
                            ? null
                            : selectedFinancial,
                        icon: Icons.list,
                        hint: 'Choose...',
                        onChanged: (p0) async {
                          setState(() {
                            selectedFinancial = p0!;
                          });
                        },
                        displayTextFn: (item) => item,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please select an financial year";
                          }
                        },
                        showSearchBox: true,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48.0),
                    child: SearchDropdownUtils.buildSearchableDropdown<String>(
                      items: projectOptions.map((e) => e.project_name).toList(),
                      value: selectedProject,
                      label: "Project Name",
                      icon: Icons.list,
                      hint: "Select project Name",
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedProject = value;
                          });
                        }
                      },
                      displayTextFn: (item) => item,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select a project name";
                        }
                      },
                      showSearchBox: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

        months = List.generate(12, (index) {
          return Utils.formatDate(DateTime(2025, index + 1, 1), 'MMMM');
        });
      });

      // Load all data sequentially
      await Future.wait([
        getStateInfo(),
        getProjectInfo(),
      ]);

      if (widget.isEdit && widget.budget != null) {
        await _populateEditData();
      }

      _initializeControllers();
    } catch (e) {
      UtilsWidgets.showToastFunc('Error loading data: ${e.toString()}');
    } finally {
      setState(() {
        _isDataLoaded = true;
      });
    }
  }

  Future<void> _populateEditData() async {
    data = widget.budget;
    budget_map = data!.budget_map;
    statusName = data!.status ? 'Active' : 'Inactive';

    selectedBudgetType = data!.name;

    int total_milestones = int.parse(data!.milestone);

    defaultBudgets =
        List.generate(total_milestones, (index) => 'Milestone ${index + 1}');

    if (stateOptions.isNotEmpty) {
      try {
        selectedState = stateOptions
            .firstWhere((element) => element.state_code == data!.state_code)
            .name;
        await getDistrictInfo();

        if (districtOptions.isNotEmpty) {
          selectedDistrict = districtOptions
              .firstWhere(
                  (element) => element.district_code == data!.district_code)
              .name;
        }
      } catch (e) {
        UtilsWidgets.showToastFunc('Error setting state/district: $e');
      }
    }

    if (projectOptions.isNotEmpty) {
      try {
        ProjectModel? foundCenter = projectOptions.firstWhere(
            (element) => element.project_code == data!.project_code);
        selectedProject = foundCenter.project_name;
      } catch (e) {
        UtilsWidgets.showToastFunc('Error setting project: $e');
      }
    }

    if (financialOptions.isNotEmpty) {
      try {
        selectedFinancial = financialOptions
            .firstWhere((element) =>
                element.financial_year_code == data!.financial_year)
            .name;
      } catch (e) {
        UtilsWidgets.showToastFunc('Error setting financial year: $e');
      }
    }
  }

  Future<void> getStateInfo() async {
    try {
      setState(() {
        stateOptions.clear();
      });

      String uri = Constants.MASTER_URL + '/state';
      Map params = {"action": "list"};
      Map<String, dynamic> tempMap = await MethodUtils.apiCall(uri, params);

      setState(() {
        if (tempMap['isValid']) {
          List tempList = tempMap['info'] ?? [];
          for (var item in tempList) {
            stateOptions.add(StateModel.fromJson(item));
          }
        } else {
          String msg = tempMap['message'] ?? "Failed to load states";
          UtilsWidgets.showToastFunc(msg);
        }
      });
    } catch (e) {
      UtilsWidgets.showToastFunc('Error loading states: ${e.toString()}');
    }
  }

  Future<void> getDistrictInfo() async {
    try {
      setState(() {
        districtOptions.clear();
      });

      if (selectedState.isEmpty) return;

      String uri = Constants.MASTER_URL + '/district';
      Map params = {
        "action": "list",
        "state_code": stateOptions
            .firstWhere((element) => element.name == selectedState)
            .state_code,
      };

      Map<String, dynamic> tempMap = await MethodUtils.apiCall(uri, params);

      setState(() {
        if (tempMap['isValid']) {
          List tempList = tempMap['info'] ?? [];
          for (var item in tempList) {
            districtOptions.add(DistrictModel.fromJson(item));
          }
        } else {
          String msg = tempMap['message'] ?? "Failed to load cities";
          UtilsWidgets.showToastFunc(msg);
        }
      });
    } catch (e) {
      UtilsWidgets.showToastFunc('Error loading cities: ${e.toString()}');
    }
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

  Future<void> getProjectInfo() async {
    setState(() {
      projectOptions.clear();
    });
    try {
      String uri = Constants.MASTER_URL + '/associate-project';
      Map params = {"action": "list"};
      Map tempMap = await MethodUtils.apiCall(uri, params);
      if (tempMap['isValid']) {
        setState(() {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            projectOptions.add(ProjectModel.fromJson(item));
          }
        });
      } else {
        String msg = tempMap['message'] ?? "Failed to load centers";
        UtilsWidgets.showToastFunc(msg);
      }
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

        if (widget.isEdit && data != null && budget_map.isNotEmpty) {
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
        "action": widget.isEdit ? "update" : "add",
        "name": selectedBudgetType,
        "state_code": stateOptions
            .firstWhere((element) => element.name == selectedState)
            .state_code,
        "district_code": districtOptions
            .firstWhere((element) => element.name == selectedDistrict)
            .district_code,
        "budget_map": budgetData,
        "status": statusName == 'Active',
        'project_code': projectOptions
            .firstWhere((element) => element.project_name == selectedProject)
            .project_code,
      };

      if (widget.isEdit && data != null) {
        params['budget_code'] = data!.budget_code;
        params['financial_year'] = data!.financial_year;
      } else {
        params["financial_year"] = financialOptions
            .firstWhere((element) => element.name == selectedFinancial)
            .financial_year_code;
      }

      Map<String, dynamic> tempMap = await apiController.fetchData(uri, params);

      bool isFind = tempMap['isValid'] ?? false;
      if (isFind) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.isEdit
                  ? 'Budget Updated Successfully!'
                  : 'Budget Added Successfully!')),
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
