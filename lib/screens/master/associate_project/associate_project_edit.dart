import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/models/associate_model.dart';
import 'package:sterlite_csr/models/district_model.dart';
import 'package:sterlite_csr/models/financial_model.dart';
import 'package:sterlite_csr/models/project_model.dart';
import 'package:sterlite_csr/models/state_model.dart';
import 'package:sterlite_csr/models/user_model.dart';
import 'package:sterlite_csr/models/village_model.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/function_utils.dart';
import 'package:sterlite_csr/utilities/method_utils.dart';
import 'package:sterlite_csr/utilities/utils/datepicker_utils.dart';
import 'package:sterlite_csr/utilities/utils/dropdown_utils.dart';
import 'package:sterlite_csr/utilities/utils/multi-dropdown_utils.dart';
import 'package:sterlite_csr/utilities/utils/radiobutton_utils.dart';
import 'package:sterlite_csr/utilities/utils/search-dropdown_utils.dart';
import 'package:sterlite_csr/utilities/utils/textfield_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditAssociate extends StatefulWidget {
  final bool isEdit;
  final AssociateModel? associate_project;

  const EditAssociate({super.key, this.isEdit = false, this.associate_project});

  @override
  _EditAssociateState createState() => _EditAssociateState();
}

class _EditAssociateState extends State<EditAssociate> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _startdateController =
      TextEditingController(text: DateTime.now().toString());
  final TextEditingController _enddateController =
      TextEditingController(text: DateTime.now().toString());
  final TextEditingController _ENFAIDController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _milestoneController = TextEditingController();

  AssociateModel? data;

  APIController apiController = Get.put(APIController());
  String userId = "";
  String userRole = "";

  List<String> statusList = ['Active', 'Inactive'];
  String statusName = 'Active';

  List<String> entityList = ['Serentica', 'Resonia', 'Sterlite Electric'];
  String entityName = 'Serentica';

  List<String> focusAreaList = [
    'Education',
    'Health',
    'Environment',
    'Livelihood'
  ];
  String focusAreaName = 'Education';

  List<String> sourceList = ['CSR', 'Community Welfare', 'AdHoc'];
  String sourceName = 'CSR';

  String selectedProject = "";
  List<ProjectModel> projectOptions = [];

  String selectedUser = "";
  List<UserModel> userOptions = [];

  List<Map<String, dynamic>> locationList = [];
  Map<String, List<String>> tempLocation = {};

  List<String> selectedState = [];
  List<StateModel> stateOptions = [];

  List<String> selectedDistrict = [];
  List<DistrictModel> districtOptions = [];

  List<String> selectedVillage = [];
  List<VillageModel> villageOptions = [];

  String selectedYear = "";
  List<FinancialModel> yearOptions = [];

  @override
  void initState() {
    super.initState();
    getUserInfo();
    if (widget.isEdit && widget.associate_project != null) {
      data = widget.associate_project;
      _nameController.text = data!.associate_project_name;
      _emailController.text = data!.email_id;
      _mobileController.text = data!.mobile;
      selectedProject = data!.project_name;
      _startdateController.text = data!.start_date;
      _enddateController.text = data!.end_date;
      _ENFAIDController.text = data!.ENFAID;
      _budgetController.text = data!.total_budget;
      _milestoneController.text = data!.milestone;
      entityName = data!.entity;
      focusAreaName = data!.focus_area;
      sourceName = data!.budget_source;
      locationList = data!.location;
      tempLocation = extractSelectedLocations(locationList);
      statusName = data!.status ? 'Active' : 'Inactive';
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isDesktop = constraints.maxWidth < 600;
      return Scaffold(
          appBar: UtilsWidgets.buildAppBar(
            widget.isEdit ? 'Edit Associate Project' : 'Add Associate Project',
            Get.isDarkMode,
            leading: Container(
              margin: const EdgeInsets.only(left: 15, bottom: 25),
              child: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(Icons.arrow_back_ios)),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: DropdownUtils.buildDropdown(
                                      items: entityList,
                                      value: entityName,
                                      label: 'Entity',
                                      icon: Icons.factory,
                                      hint: 'Select Entity',
                                      onChanged: (value) {
                                        setState(() {
                                          entityName = value ?? '';
                                        });
                                      },
                                      displayTextFn: (item) => item),
                                ),
                                Flexible(
                                  child: DropdownUtils.buildDropdown(
                                      items: focusAreaList,
                                      value: focusAreaName,
                                      label: 'Focus Area',
                                      icon: Icons.area_chart,
                                      hint: 'Select Focus Area',
                                      onChanged: (value) {
                                        setState(() {
                                          focusAreaName = value ?? '';
                                        });
                                      },
                                      displayTextFn: (item) => item),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: TextFiledUtils.buildTextField(
                                    controller: _ENFAIDController,
                                    label: 'ENFA ID',
                                    hint: 'Enter ENFA ID',
                                    icon: Icons.card_membership,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter ENFA ID';
                                      }
                                    },
                                  ),
                                ),
                                Flexible(
                                  child: SearchDropdownUtils
                                      .buildSearchableDropdown<String>(
                                    items:
                                        yearOptions.map((e) => e.name).toList(),
                                    value: selectedYear,
                                    label: "Financial Year",
                                    icon: Icons.list,
                                    hint: "Select financial Year",
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          selectedYear = value;
                                        });
                                      }
                                    },
                                    displayTextFn: (item) => item,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please select a year name";
                                      }
                                    },
                                    showSearchBox: true,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: DatePickerUtils.buildDatePicker(
                                    controller: _startdateController,
                                    label: "Start Time",
                                    icon: Icons.cake,
                                    hint: "Pick up date",
                                    validator: (val) =>
                                        val == null || val.isEmpty
                                            ? "Date required"
                                            : null,
                                  ),
                                ),
                                Flexible(
                                  child: DatePickerUtils.buildDatePicker(
                                    controller: _enddateController,
                                    label: "End Time",
                                    icon: Icons.cake,
                                    hint: "Pick up date",
                                    validator: (val) =>
                                        val == null || val.isEmpty
                                            ? "Date required"
                                            : null,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: TextFiledUtils.buildTextField(
                                    controller: _budgetController,
                                    label: 'Budget',
                                    hint: 'Enter Budget',
                                    icon: Icons.money,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter Budget';
                                      }
                                    },
                                    keyboardType: TextInputType.number,
                                    inputFormatter:
                                        Utils.allowInputFormatter('[0-9.]'),
                                  ),
                                ),
                                Flexible(
                                  child: DropdownUtils.buildDropdown(
                                      items: sourceList,
                                      value: sourceName,
                                      label: 'Budget Source',
                                      icon: Icons.area_chart,
                                      hint: 'Select Budget Source',
                                      onChanged: (value) {
                                        setState(() {
                                          sourceName = value ?? '';
                                        });
                                      },
                                      displayTextFn: (item) => item),
                                ),
                              ],
                            ),
                            TextFiledUtils.buildTextField(
                              controller: _milestoneController,
                              label: 'Milestone',
                              hint: 'Enter milestone',
                              icon: Icons.money,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter milestone';
                                }
                              },
                              keyboardType: TextInputType.number,
                              inputFormatter:
                                  Utils.allowInputFormatter('[0-9.]'),
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: TextFiledUtils.buildTextField(
                                    controller: _nameController,
                                    label: 'Associate Project Name',
                                    hint: 'Enter your associate project name',
                                    icon: Icons.business_center,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your associate project name';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Flexible(
                                  child: SearchDropdownUtils
                                      .buildSearchableDropdown(
                                    items: userOptions
                                        .map((e) => e.user_name)
                                        .toList(),
                                    value: selectedUser,
                                    label: "User",
                                    icon: Icons.map,
                                    hint: "Select user",
                                    onChanged: (value) async {
                                      if (value != null) {
                                        setState(() {
                                          selectedUser = value;
                                        });
                                      }
                                    },
                                    displayTextFn: (item) => item,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please select a user";
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: SearchDropdownUtils
                                      .buildSearchableDropdown(
                                    items: projectOptions
                                        .map((e) => e.project_name)
                                        .toList(),
                                    value: selectedProject,
                                    label: "Project",
                                    icon: Icons.map,
                                    hint: "Select project",
                                    onChanged: (value) async {
                                      if (value != null) {
                                        setState(() {
                                          selectedProject = value;
                                          selectedState = [];
                                          selectedDistrict = [];
                                          selectedVillage = [];
                                        });
                                      }
                                    },
                                    displayTextFn: (item) => item,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please select a project";
                                      }
                                    },
                                  ),
                                ),
                                Flexible(
                                  child: MultiSelectDropdownUtils
                                      .buildMultiSelectDropdown<String>(
                                    items: stateOptions
                                        .map((e) => e.name)
                                        .toList(),
                                    selectedItems: selectedState,
                                    label: "Choose state",
                                    icon: Icons.list,
                                    onChanged: (selected) async {
                                      setState(() {
                                        List<String> removedStates =
                                            selectedState
                                                .where((state) =>
                                                    !selected.contains(state))
                                                .toList();

                                        // Get state codes of removed states
                                        List<String> removedStateCodes =
                                            stateOptions
                                                .where((state) => removedStates
                                                    .contains(state.name))
                                                .map(
                                                    (state) => state.state_code)
                                                .toList();

                                        // Remove districts belonging to removed states
                                        selectedDistrict
                                            .removeWhere((districtName) {
                                          var district =
                                              districtOptions.firstWhere((d) =>
                                                  d.name == districtName);
                                          return removedStateCodes
                                              .contains(district.state_code);
                                        });

                                        selectedVillage
                                            .removeWhere((villageName) {
                                          var village =
                                              villageOptions.firstWhere(
                                                  (v) => v.name == villageName);
                                          return removedStateCodes
                                              .contains(village.state_code);
                                        });

                                        selectedState = selected;
                                      });
                                      await getDistrictInfo();
                                    },
                                    displayTextFn: (item) => item,
                                    popupTitle: 'Select state',
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please choose state';
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: MultiSelectDropdownUtils
                                      .buildMultiSelectDropdown<String>(
                                    items: districtOptions
                                        .map((e) => e.name)
                                        .toList(),
                                    selectedItems: selectedDistrict,
                                    label: "Choose district",
                                    icon: Icons.list,
                                    onChanged: (selected) async {
                                      setState(() {
                                        List<String> removedDistricts =
                                            selectedDistrict
                                                .where((district) => !selected
                                                    .contains(district))
                                                .toList();

                                        // Get district codes of removed districts
                                        List<String> removedDistrictCodes =
                                            districtOptions
                                                .where((district) =>
                                                    removedDistricts.contains(
                                                        district.name))
                                                .map((district) =>
                                                    district.district_code)
                                                .toList();

                                        // Remove villages belonging to removed districts
                                        selectedVillage
                                            .removeWhere((villageName) {
                                          var village =
                                              villageOptions.firstWhere(
                                                  (v) => v.name == villageName);
                                          return removedDistrictCodes
                                              .contains(village.district_code);
                                        });
                                        selectedDistrict = selected;
                                      });
                                      await getVillageInfo();
                                    },
                                    displayTextFn: (item) => item,
                                    popupTitle: 'Select district',
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please choose district';
                                      }
                                    },
                                  ),
                                ),
                                Flexible(
                                  child: MultiSelectDropdownUtils
                                      .buildMultiSelectDropdown<String>(
                                    items: villageOptions
                                        .map((e) => e.name)
                                        .toList(),
                                    selectedItems: selectedVillage,
                                    label: "Choose village",
                                    icon: Icons.list,
                                    onChanged: (selected) async {
                                      setState(() {
                                        selectedVillage = selected;
                                      });
                                    },
                                    displayTextFn: (item) => item,
                                    popupTitle: 'Select village',
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please choose village';
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: TextFiledUtils.buildTextField(
                                    controller: _mobileController,
                                    label: 'Mobile Number',
                                    hint: 'Enter mobile number',
                                    icon: Icons.phone,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter mobile number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Flexible(
                                  child: TextFiledUtils.buildTextField(
                                    controller: _emailController,
                                    label: 'Email Address',
                                    hint: 'Enter email_id address',
                                    icon: Icons.email,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter email_id address';
                                      }
                                      return null;
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
                            const SizedBox(height: 16),
                            apiController.isLoading.value
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 16, 0, 16),
                                    child: UtilsWidgets.buildPrimaryBtn(
                                        context,
                                        widget.isEdit
                                            ? 'Edit Associate Project'
                                            : 'Add Associate Project',
                                        () async {
                                      locationList =
                                          convertToNestedLocationFormat(
                                        stateOptions,
                                        districtOptions,
                                        villageOptions,
                                        selectedState,
                                        selectedDistrict,
                                        selectedVillage,
                                      );

                                      if (_formKey.currentState!.validate()) {
                                        await _submitForm();
                                      }
                                    }),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ));
    });
  }

  Future getUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id') ?? '';
      userRole = prefs.getString('role') ?? '';
    });
    await getProjectInfo();
    await getLocalCSRInfo();
    await getFinancialInfo();
    await getStateInfo();
    if (widget.isEdit && data != null) {
      await getDistrictInfo();
      await getVillageInfo();
    }
  }

  Future getLocalCSRInfo() async {
    setState(() {
      userOptions.clear();
    });
    try {
      String uri = Constants.USER_URL + '/user';
      Map params = {"action": "list", 'role': 'Local CSR SPOC'};

      Map tempMap = await MethodUtils.apiCall(uri, params);
      if (tempMap['isValid']) {
        setState(() {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            userOptions.add(UserModel.fromJson(item));
          }
          if (widget.isEdit && data!.local_csr_id != '') {
            selectedUser = userOptions
                .firstWhere((element) => element.user_id == data!.local_csr_id)
                .user_name;
          }
        });
      }
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
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
      if (tempMap['isValid']) {
        setState(() {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            projectOptions.add(ProjectModel.fromJson(item));
          }
          if (widget.isEdit && data!.project_code != '') {
            bool isProjectExist = projectOptions
                .map((e) => e.project_code)
                .toList()
                .contains(data!.project_code);
            if (isProjectExist) {
              selectedProject = projectOptions
                  .firstWhere(
                      (element) => element.project_code == data!.project_code)
                  .project_name;
            }
          }
        });
      }
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  Future getFinancialInfo() async {
    setState(() {
      yearOptions.clear();
    });
    try {
      String uri = Constants.MASTER_URL + '/financial-year';
      Map params = {"action": "list"};

      Map tempMap = await MethodUtils.apiCall(uri, params);
      if (tempMap['isValid']) {
        setState(() {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            yearOptions.add(FinancialModel.fromJson(item));
          }
          if (widget.isEdit && data!.financial_year != '') {
            selectedYear = yearOptions
                .firstWhere((element) => element.name == data!.financial_year)
                .name;
          }
        });
      } else {
        String msg = tempMap['message'] ?? "Failed to load years";
        UtilsWidgets.showToastFunc(msg);
      }
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  Future getStateInfo() async {
    setState(() {
      stateOptions.clear();
    });
    try {
      String uri = Constants.MASTER_URL + '/state';
      Map params = {"action": "list"};

      Map tempMap = await MethodUtils.apiCall(uri, params);
      if (tempMap['isValid']) {
        setState(() {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            stateOptions.add(StateModel.fromJson(item));
          }
          if (widget.isEdit && data!.location != []) {
            selectedState = tempLocation['selectedState']!;
          }
        });
      }
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  Future getDistrictInfo() async {
    setState(() {
      districtOptions.clear();
    });
    try {
      String uri = Constants.MASTER_URL + '/district';
      Map params = {
        "action": "list",
        "state_code": stateOptions
            .where((state) => selectedState.contains(state.name))
            .map((state) => state.state_code)
            .toList(),
      };

      Map tempMap = await MethodUtils.apiCall(uri, params);
      if (tempMap['isValid']) {
        setState(() {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            districtOptions.add(DistrictModel.fromJson(item));
          }
          if (widget.isEdit && data!.location != []) {
            selectedDistrict = tempLocation['selectedDistrict']!;
          }
        });
      } else {
        String msg = tempMap['message'] ?? "Failed to load cities";
        UtilsWidgets.showToastFunc(msg);
      }
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  Future getVillageInfo() async {
    setState(() {
      villageOptions.clear();
    });
    try {
      String uri = Constants.MASTER_URL + '/village';
      Map params = {
        "action": "list",
        "state_code": stateOptions
            .where((state) => selectedState.contains(state.name))
            .map((state) => state.state_code)
            .toList(),
        "district_code": districtOptions
            .where((district) => selectedDistrict.contains(district.name))
            .map((district) => district.district_code)
            .toList()
      };

      Map tempMap = await MethodUtils.apiCall(uri, params);
      if (tempMap['isValid']) {
        setState(() {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            villageOptions.add(VillageModel.fromJson(item));
          }
          if (widget.isEdit && data!.location != []) {
            selectedVillage = tempLocation['selectedVillage']!;
          }
        });
      } else {
        String msg = tempMap['message'] ?? "Failed to load clusters";
        UtilsWidgets.showToastFunc(msg);
      }
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  Map<String, List<String>> extractSelectedLocations(
      List<Map<String, dynamic>> locationList) {
    List<String> selectedState = [];
    List<String> selectedDistrict = [];
    List<String> selectedVillage = [];

    for (var state in locationList) {
      selectedState.add(state['state_name'] as String);

      for (var district in state['districts'] as List<dynamic>) {
        selectedDistrict.add(district['district_name'] as String);

        for (var village in district['villages'] as List<dynamic>) {
          selectedVillage.add(village['village_name'] as String);
        }
      }
    }

    return {
      'selectedState': selectedState,
      'selectedDistrict': selectedDistrict,
      'selectedVillage': selectedVillage,
    };
  }

  List<Map<String, dynamic>> convertToNestedLocationFormat(
    List<StateModel> stateOptions,
    List<DistrictModel> districtOptions,
    List<VillageModel> villageOptions,
    List<String> selectedState,
    List<String> selectedDistrict,
    List<String> selectedVillage,
  ) {
    final selectedStates = stateOptions
        .where((state) => selectedState.contains(state.name))
        .toList();

    List<Map<String, dynamic>> location = selectedStates.map((state) {
      final stateDistricts = districtOptions
          .where((district) =>
              selectedDistrict.contains(district.name) &&
              district.state_code == state.state_code)
          .toList();

      final districts = stateDistricts.map((district) {
        final districtVillages = villageOptions
            .where((village) =>
                selectedVillage.contains(village.name) &&
                village.district_code == district.district_code)
            .map((village) => {
                  'village_id': village.village_code,
                  'village_name': village.name,
                })
            .toList();

        return {
          'district_id': district.district_code,
          'district_name': district.name,
          'villages': districtVillages,
        };
      }).toList();

      return {
        'state_id': state.state_code,
        'state_name': state.name,
        'districts': districts,
      };
    }).toList();

    return location;
  }

  Future _submitForm() async {
    try {
      String startD = Utils.formatDate(
          DateTime.parse(_startdateController.text), 'yyyy-MM-dd');
      String endD = Utils.formatDate(
          DateTime.parse(_enddateController.text), 'yyyy-MM-dd');

      String uri = Constants.OPERATION_URL + '/associate-project';
      Map params = {
        "user_id": userId,
        "action": widget.isEdit ? "update" : "add",
        // "state_code": stateOptions
        //     .where((state) => selectedState.contains(state.name))
        //     .map((state) => state.state_code)
        //     .toList(),
        // "district_code": districtOptions
        //     .where((district) => selectedDistrict.contains(district.name))
        //     .map((district) => district.district_code)
        //     .toList(),
        // "village_code": villageOptions
        //     .where((village) => selectedVillage.contains(village.name))
        //     .map((village) => village.village_code)
        //     .toList(),
        "location": locationList,
        "financial_year": selectedYear,
        "project_code": projectOptions
            .firstWhere((element) => element.project_name == selectedProject)
            .project_code,
        "project_name": selectedProject,
        "associate_project_name": _nameController.text.trim(),
        "start_date": startD,
        "end_date": endD,
        "total_budget": _budgetController.text,
        "milestone": _milestoneController.text,
        "ENFAID": _ENFAIDController.text,
        "entity": entityName,
        "budget_source": sourceName,
        "focus_area": focusAreaName,
        "status": statusName == 'Active',
        "local_csr_name": selectedUser,
        "local_csr_id": userOptions
            .firstWhere((element) => element.user_name == selectedUser)
            .user_id,
        "mobile": _mobileController.text.trim(),
        "email_id": _emailController.text.trim().toLowerCase(),
      };
      if (widget.isEdit) {
        params['associate_project_code'] = data!.associate_project_code;
      }

      Map<String, dynamic> tempMap = await apiController.fetchData(uri, params);
      setState(() {
        bool isFind = tempMap['isValid'];
        if (isFind) {
          // List tempList = tempMap['info'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(widget.isEdit
                    ? 'Associate Project Updated Successfully!'
                    : 'Associate Project Added Successfully!')),
          );
          Get.back(result: true);
        } else {
          String msg = tempMap['message'];
          UtilsWidgets.showToastFunc(msg);
        }
      });
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startdateController.dispose();
    _enddateController.dispose();
    _budgetController.dispose();
    _milestoneController.dispose();
    _ENFAIDController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }
}
