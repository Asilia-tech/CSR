import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/models/associate_model.dart';
import 'package:sterlite_csr/models/indicator_model.dart';
import 'package:sterlite_csr/models/project_model.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/function_utils.dart';
import 'package:sterlite_csr/utilities/method_utils.dart';
import 'package:sterlite_csr/utilities/utils/dropdown_utils.dart';
import 'package:sterlite_csr/utilities/utils/radiobutton_utils.dart';
import 'package:sterlite_csr/utilities/utils/search-dropdown_utils.dart';
import 'package:sterlite_csr/utilities/utils/textfield_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditIndicator extends StatefulWidget {
  final bool isEdit;
  final IndicatorModel? indicator;

  const EditIndicator({super.key, this.isEdit = false, this.indicator});

  @override
  _EditIndicatorState createState() => _EditIndicatorState();
}

class _EditIndicatorState extends State<EditIndicator> {
  APIController apiController = Get.put(APIController());
  bool isFind = false;
  String msg = 'Please wait...';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameIndicatorController =
      TextEditingController();

  Map<String, dynamic> indicator_map = {};

  IndicatorModel? data;
  AssociateModel? associate_projectData;

  List<String> beneficiary_type_List = ['Beneficiary', 'Non-Beneficiary'];
  String beneficiary_type = 'Beneficiary';

  List<String> fieldList = ['Number', 'Individual'];
  String fieldName = 'Number';

  List<String> frequencyList = ['Monthly', 'Quarterly', 'Yearly'];
  String frequencyName = 'Monthly';

  List<ProjectModel> projectOptions = [];
  String selectedProject = "";

  String selectedAssociate = "";
  List<AssociateModel> associateOptions = [];

  String userId = "";
  String userRole = "";

  List<TextEditingController> fieldNameList = [];
  List<String> selectedFieldTypes = [];
  List<String> fieldTypeList = [
    'Character',
    'Number',
    'Boolean',
    'Date',
    'Email',
    'Mobile',
    'Image'
  ];

  String keyName = '';
  Map<String, dynamic> fieldData = {};

  void addField() {
    setState(() {
      fieldNameList.add(TextEditingController(text: ''));
      selectedFieldTypes.add('');
    });
  }

  void removeField(int index) {
    setState(() {
      fieldNameList.removeAt(index);
      selectedFieldTypes.removeAt(index);
      fieldData.remove(fieldNameList[index].text);
    });
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  void dispose() {
    _nameIndicatorController.dispose();
    for (var field in fieldNameList) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isDesktop = constraints.maxWidth < 600;
      return Scaffold(
        appBar: UtilsWidgets.buildAppBar(
          widget.isEdit ? 'Edit Indicator' : 'Add Indicator',
          Get.isDarkMode,
          leading: Container(
            margin: const EdgeInsets.only(left: 15, bottom: 25),
            child: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_ios),
            ),
          ),
        ),
        body: apiController.isLoading.isTrue
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
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
                                    return null;
                                  },
                                ),
                              ),
                              Flexible(
                                child: SearchDropdownUtils
                                    .buildSearchableDropdown<String>(
                                  items: associateOptions
                                      .map(
                                          (city) => city.associate_project_name)
                                      .toList(),
                                  value: selectedAssociate,
                                  label: "Associate Project",
                                  icon: Icons.location_city,
                                  hint: "Select associate project",
                                  onChanged: (value) async {
                                    if (value != null) {
                                      setState(() {
                                        selectedAssociate = value;
                                      });
                                      await fetchAssociateProjectInfo(
                                          associateOptions
                                              .firstWhere((element) =>
                                                  element
                                                      .associate_project_name ==
                                                  selectedAssociate)
                                              .associate_project_code);
                                    }
                                  },
                                  displayTextFn: (item) => item,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please select an associate project";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: TextFiledUtils.buildTextField(
                                    controller: _nameIndicatorController,
                                    label: 'Name of Indicator',
                                    hint: 'Enter name of indicator',
                                    icon: Icons.calendar_today,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter name of indicator';
                                      }
                                    }),
                              ),
                              Flexible(
                                  child: DropdownUtils.buildDropdown(
                                      items: frequencyList,
                                      value: frequencyName,
                                      label: 'Frequency',
                                      icon: Icons.factory,
                                      hint: 'Select Frequency',
                                      onChanged: (value) {
                                        setState(() {
                                          frequencyName = value ?? '';
                                        });
                                      },
                                      displayTextFn: (item) => item)),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: RadioButtonUtils.buildRadioGroup<String>(
                                    items: beneficiary_type_List,
                                    selectedValue: beneficiary_type,
                                    label: "Beneficiary Type",
                                    icon: Icons.toggle_on,
                                    onChanged: (value) {
                                      setState(() {
                                        beneficiary_type = value ?? '';
                                      });
                                    },
                                    displayTextFn: (item) => item,
                                    horizontal: true),
                              ),
                              Flexible(
                                child: DropdownUtils.buildDropdown(
                                    items: fieldList,
                                    value: fieldName,
                                    label: 'Type of Field',
                                    icon: Icons.factory,
                                    hint: 'Select Type of Field',
                                    onChanged: (value) {
                                      setState(() {
                                        fieldName = value ?? '';
                                      });
                                    },
                                    displayTextFn: (item) => item),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Define Individual Fields',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: addField,
                                  icon: const Icon(Icons.add, size: 20),
                                  label: const Text(
                                    'Add Field',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD1F5F5),
                                    foregroundColor: Colors.black87,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Column(
                              children:
                                  List.generate(fieldNameList.length, (index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFiledUtils.buildTextField(
                                          controller: fieldNameList[index],
                                          label: 'Field Name',
                                          hint: 'Enter field name',
                                          icon: Icons.label,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter field name';
                                            }
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                              selectedFieldTypes[index] = '';
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: SearchDropdownUtils
                                            .buildSearchableDropdown(
                                          items: fieldTypeList,
                                          value: selectedFieldTypes[index],
                                          label: 'Field Type',
                                          icon: Icons.category,
                                          hint: 'Select field type',
                                          onChanged: (value) {
                                            setState(() {
                                              selectedFieldTypes[index] =
                                                  value!;
                                            });
                                          },
                                          displayTextFn: (item) => item,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => removeField(index),
                                        icon: Icon(
                                          Icons.delete,
                                          color: Constants.redColor,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            fieldData[
                                                    fieldNameList[index].text] =
                                                selectedFieldTypes[index];
                                          });
                                        },
                                        icon: Icon(
                                          Icons.save,
                                          color: Constants.greenColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                            if (fieldData.isNotEmpty)
                              SearchDropdownUtils.buildSearchableDropdown(
                                  items: fieldData.keys.toList(),
                                  value: keyName,
                                  label: fieldName == 'Number'
                                      ? 'Counter Key'
                                      : 'Primary Key',
                                  icon: Icons.factory,
                                  hint: 'Select Key',
                                  onChanged: (value) {
                                    setState(() {
                                      keyName = value ?? '';
                                    });
                                  },
                                  displayTextFn: (item) => item),
                          ],
                        ),
                      ),
                      apiController.isLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : UtilsWidgets.buildPrimaryBtn(
                              context,
                              widget.isEdit
                                  ? 'Edit Indicator'
                                  : 'Add Indicator', () async {
                              if (_formKey.currentState!.validate()) {
                                await _submitForm();
                              }
                            }),
                    ],
                  ),
                ),
              ),
      );
    });
  }

  getUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id') ?? '';
      userRole = prefs.getString('role') ?? '';
      data = widget.indicator;
      frequencyName = data!.frequency;
      beneficiary_type = data!.beneficiary_type;
      fieldName = data!.type_of_field;
      _nameIndicatorController.text = data!.indicator_name;
      indicator_map = data!.indicator_map;
      indicator_map.remove('age');
      indicator_map.remove('gender');
      indicator_map.remove('location');
      indicator_map.remove('month_year');
      keyName = indicator_map['key_field'];
      indicator_map.remove('key_field');
      indicator_map.remove('key_type');
      fieldData = Map<String, dynamic>.from(indicator_map);
      fieldData.forEach((key, value) {
        fieldNameList.add(TextEditingController(text: key));
        selectedFieldTypes.add(value);
      });
    });
    await getProjectInfo();
    if (data != null) {
      await getAssociateInfo();
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
      isFind = tempMap['isValid'];
      if (isFind) {
        List tempList = tempMap['info'];
        for (var item in tempList) {
          projectOptions.add(ProjectModel.fromJson(item));
        }
        setState(() {
          if (widget.isEdit && data!.project_code != '') {
            selectedProject = projectOptions
                .firstWhere(
                    (element) => element.project_code == data!.project_code)
                .project_name;
          }
        });
        msg = 'Select a project and associate project to view indicators';
      } else {
        msg = tempMap['message'] ?? 'Failed to load project data';
      }
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
      isFind = tempMap['isValid'];
      if (isFind) {
        List tempList = tempMap['info'];
        for (var item in tempList) {
          associateOptions.add(AssociateModel.fromJson(item));
        }
        setState(() {
          if (widget.isEdit && data!.associate_project_code != '') {
            selectedAssociate = associateOptions
                .firstWhere((element) =>
                    element.associate_project_code ==
                    data!.associate_project_code)
                .associate_project_name;
          }
        });
        msg = 'Select a project to view indicators';
      } else {
        msg = tempMap['message'] ?? 'Failed to load associate project data';
      }
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  Future fetchAssociateProjectInfo(String associate_project_code) async {
    try {
      String uri = Constants.OPERATION_URL + '/associate-project';
      Map params = {
        "action": "get",
        'associate_project_code': associate_project_code
      };

      Map<String, dynamic> tempMap = await MethodUtils.apiCall(uri, params);

      setState(() {
        if (tempMap['isValid']) {
          associate_projectData = AssociateModel.fromJson(tempMap['info']);
        } else {
          String msg =
              tempMap['message'] ?? "Failed to load associate_project data";
          UtilsWidgets.showToastFunc(msg);
        }
      });
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  Future _submitForm() async {
    try {
      if (beneficiary_type == 'Beneficiary') {
        fieldList = ['Number', 'Individual'];
        String start_date = associate_projectData!.start_date;
        String end_date = associate_projectData!.end_date;

        List monthList = Utils.getMonthsInFinancialYear(start_date, end_date);
        indicator_map = {
          'age': [
            'Less than 18',
            '18 - 30',
            '31 - 45',
            '46 - 60',
            'Greater than 61'
          ],
          'gender': ['Male', 'Female', 'Other'],
          'location': associate_projectData!.location,
          'month_year': monthList
        };
      } else {
        fieldList = ['Number'];
        fieldName = 'Number';
        indicator_map = {};
      }
      indicator_map.addAll(fieldData);

      indicator_map['key_field'] = keyName;
      indicator_map['key_type'] =
          fieldName == 'Number' ? 'Countable Key' : 'Primary Key';

      String uri = Constants.OPERATION_URL + '/beneficiary-indicator';
      Map params = {
        "user_id": userId,
        "action": widget.isEdit ? "update" : "add",
        "type": beneficiary_type,
        "indicator_name": _nameIndicatorController.text.trim(),
        "frequency": frequencyName,
        "type_of_field": fieldName,
        "project_code": projectOptions
            .firstWhere((p) => p.project_name == selectedProject)
            .project_code,
        "associate_project_code": associateOptions
            .firstWhere((a) => a.associate_project_name == selectedAssociate)
            .associate_project_code,
        "reviewer_status": {
          "status": "Pending",
          "remarks": "",
          "updated_by": userId,
          "updated_on": DateTime.now().toString()
        },
        "indicator_map": indicator_map,
      };
      if (widget.isEdit) {
        params["indicator_code"] = data!.indicator_code;
      }

      Map<String, dynamic> tempMap = await apiController.fetchData(uri, params);
      setState(() {
        bool isFind = tempMap['isValid'];
        if (isFind) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Indicator Updated Successfully!')),
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
}
