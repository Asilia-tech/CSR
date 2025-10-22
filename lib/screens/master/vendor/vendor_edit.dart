import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/models/associate_model.dart';
import 'package:sterlite_csr/models/district_model.dart';
import 'package:sterlite_csr/models/project_model.dart';
import 'package:sterlite_csr/models/village_model.dart';
import 'package:sterlite_csr/models/vendor_model.dart';
import 'package:sterlite_csr/models/state_model.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/method_utils.dart';
import 'package:sterlite_csr/utilities/utils/radiobutton_utils.dart';
import 'package:sterlite_csr/utilities/utils/search-dropdown_utils.dart';
import 'package:sterlite_csr/utilities/utils/textfield_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditVendor extends StatefulWidget {
  final bool isEdit;
  final VendorModel? vendor;

  const EditVendor({super.key, this.isEdit = false, this.vendor});

  @override
  _EditVendorState createState() => _EditVendorState();
}

class _EditVendorState extends State<EditVendor> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactpController = TextEditingController();
  final TextEditingController _email_idController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  VendorModel? data;

  APIController apiController = Get.put(APIController());
  String userId = "";
  String userRole = "";

  List<String> statusList = ['Active', 'Inactive'];
  String statusName = 'Active';

  List<String> typeList = ['VENDOR', 'NGO'];
  String typeName = 'VENDOR';

  String selectedState = "";
  List<StateModel> stateOptions = [];

  String selectedProject = "";
  List<ProjectModel> projectOptions = [];

  String selectedAssociatedProject = "";
  List<AssociateModel> associatedProjectOptions = [];

  String selectedDistrict = "";
  List<DistrictModel> districtOptions = [];

  String selectedVillage = "";
  List<VillageModel> villageOptions = [];

  @override
  void initState() {
    super.initState();
    getUserInfo();
    if (widget.isEdit && widget.vendor != null) {
      data = widget.vendor;
      _nameController.text = data!.vendor_name;
      _contactpController.text = data!.contact_person;
      _email_idController.text = data!.email_id;
      _mobileController.text = data!.mobile;
      _passwordController.text = data!.password;
      typeName = data!.type;
      statusName = data!.status ? 'Active' : 'Inactive';
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isDesktop = constraints.maxWidth < 600;
      return Scaffold(
          appBar: UtilsWidgets.buildAppBar(
            widget.isEdit ? 'Edit Vendor/NGO' : 'Add Vendor/NGO',
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
                            RadioButtonUtils.buildRadioGroup<String>(
                              items: typeList,
                              selectedValue: typeName,
                              label: "Type",
                              icon: Icons.toggle_on,
                              onChanged: (value) {
                                setState(() {
                                  typeName = value ?? '';
                                });
                              },
                              displayTextFn: (item) => item,
                              horizontal: true,
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: TextFiledUtils.buildTextField(
                                    controller: _nameController,
                                    label: '$typeName Name',
                                    hint: 'Enter your $typeName name',
                                    icon: Icons.person,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your $typeName name';
                                      }
                                    },
                                  ),
                                ),
                                Flexible(
                                  child: TextFiledUtils.buildTextField(
                                    controller: _contactpController,
                                    label: 'Contact person name',
                                    hint: 'Enter contact person name',
                                    icon: Icons.person_2,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter contact person name';
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
                                        });
                                        await getAssociatedProjectInfo();
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
                                  child: SearchDropdownUtils
                                      .buildSearchableDropdown(
                                    items: associatedProjectOptions
                                        .map((e) => e.associate_project_name)
                                        .toList(),
                                    value: selectedAssociatedProject,
                                    label: "Associated Project",
                                    icon: Icons.map,
                                    hint: "Select associated project",
                                    onChanged: (value) async {
                                      if (value != null) {
                                        setState(() {
                                          selectedAssociatedProject = value;
                                        });
                                      }
                                    },
                                    displayTextFn: (item) => item,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please select a associated project";
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SearchDropdownUtils.buildSearchableDropdown(
                              items: stateOptions.map((e) => e.name).toList(),
                              value: selectedState,
                              label: "State",
                              icon: Icons.map,
                              hint: "Select state",
                              onChanged: (value) async {
                                if (value != null) {
                                  setState(() {
                                    selectedState = value;
                                  });
                                  await getDistrictInfo();
                                }
                              },
                              displayTextFn: (item) => item,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please select a state";
                                }
                                return null;
                              },
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: SearchDropdownUtils
                                      .buildSearchableDropdown(
                                    items: districtOptions
                                        .map((e) => e.name)
                                        .toList(),
                                    value: selectedDistrict,
                                    label: "District",
                                    icon: Icons.location_city,
                                    hint: "Select District",
                                    onChanged: (value) async {
                                      if (value != null) {
                                        setState(() {
                                          selectedDistrict = value;
                                        });
                                        await getVillageInfo();
                                      }
                                    },
                                    displayTextFn: (item) => item,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please select a District";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Flexible(
                                  child: SearchDropdownUtils
                                      .buildSearchableDropdown(
                                    items: villageOptions
                                        .map((e) => e.name)
                                        .toList(),
                                    value: selectedVillage,
                                    label: "Village",
                                    icon: Icons.layers,
                                    hint: "Select village",
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          selectedVillage = value;
                                        });
                                      }
                                    },
                                    displayTextFn: (item) => item,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please select a village";
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
                                    },
                                  ),
                                ),
                                Flexible(
                                  child: TextFiledUtils.buildTextField(
                                    controller: _email_idController,
                                    label: 'Email Address',
                                    hint: 'Enter email_id address',
                                    icon: Icons.email,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter email_id address';
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
                                    controller: _passwordController,
                                    label: 'Password',
                                    hint: 'Enter password',
                                    icon: Icons.lock,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter password';
                                      }
                                    },
                                  ),
                                ),
                                Flexible(
                                  child:
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
                                ),
                              ],
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
                                            ? 'Edit $typeName'
                                            : 'Add $typeName', () async {
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
    await getStateInfo();
    await getProjectInfo();
    if (widget.isEdit && data != null) {
      await getDistrictInfo();
      await getVillageInfo();
      await getAssociatedProjectInfo();
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
          if (widget.isEdit && data!.state_code != '') {
            bool isStateExist = stateOptions
                .map((e) => e.state_code)
                .toList()
                .contains(data!.state_code);
            if (isStateExist) {
              selectedState = stateOptions
                  .firstWhere(
                      (element) => element.state_code == data!.state_code)
                  .name;
            }
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
            .firstWhere((element) => element.name == selectedState)
            .state_code,
      };

      Map tempMap = await MethodUtils.apiCall(uri, params);
      if (tempMap['isValid']) {
        setState(() {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            districtOptions.add(DistrictModel.fromJson(item));
          }
          if (widget.isEdit && data!.district_code != '') {
            bool isDistrictExist = districtOptions
                .map((e) => e.district_code)
                .toList()
                .contains(data!.district_code);
            if (isDistrictExist) {
              selectedDistrict = districtOptions
                  .firstWhere(
                      (element) => element.district_code == data!.district_code)
                  .name;
            }
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
            .firstWhere((element) => element.name == selectedState)
            .state_code,
        "district_code": districtOptions
            .firstWhere((element) => element.name == selectedDistrict)
            .district_code,
      };

      Map tempMap = await MethodUtils.apiCall(uri, params);
      if (tempMap['isValid']) {
        setState(() {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            villageOptions.add(VillageModel.fromJson(item));
          }

          if (widget.isEdit && data!.village_code != '') {
            bool isVillageExist = villageOptions
                .map((e) => e.village_code)
                .toList()
                .contains(data!.village_code);
            if (isVillageExist) {
              selectedVillage = villageOptions
                  .firstWhere(
                      (element) => element.village_code == data!.village_code)
                  .name;
            }
          }
        });
      } else {
        String msg = tempMap['message'] ?? "Failed to load villages";
        UtilsWidgets.showToastFunc(msg);
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
            selectedProject = projectOptions
                .firstWhere(
                    (element) => element.project_code == data!.project_code)
                .project_name;
          }
        });
      }
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  Future getAssociatedProjectInfo() async {
    setState(() {
      associatedProjectOptions.clear();
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
      if (tempMap['isValid']) {
        setState(() {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            associatedProjectOptions.add(AssociateModel.fromJson(item));
          }
          if (widget.isEdit && data!.district_code != '') {
            selectedAssociatedProject = associatedProjectOptions
                .firstWhere((element) =>
                    element.associate_project_code ==
                    data!.associate_project_code)
                .associate_project_name;
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

  Future _submitForm() async {
    try {
      String uri = Constants.MASTER_URL + '/vendor';

      Map<String, dynamic> accessControl = {
        "add": true,
        "edit": false,
        "delete": false,
        "view": true,
        "report": false,
        "master": false
      };

      Map params = {
        "user_id": userId,
        "action": widget.isEdit ? "update" : "add",
        "state_code": stateOptions
            .firstWhere((element) => element.name == selectedState)
            .state_code,
        "district_code": districtOptions
            .firstWhere((element) => element.name == selectedDistrict)
            .district_code,
        "village_code": villageOptions
            .firstWhere((element) => element.name == selectedVillage)
            .village_code,
        "access_control": accessControl,
        "vendor_name": _nameController.text.trim(),
        "contact_person": _contactpController.text.trim(),
        "mobile": _mobileController.text.trim(),
        "email_id": _email_idController.text.trim().toLowerCase(),
        "password": _passwordController.text.trim(),
        "role": 'NGO/ Vendor Partner',
        "type": typeName,
        "status": statusName == 'Active',
        "project_code": projectOptions
            .firstWhere((element) => element.project_name == selectedProject)
            .project_code,
        "associate_project_code": associatedProjectOptions
            .firstWhere((element) =>
                element.associate_project_name == selectedAssociatedProject)
            .associate_project_code,
      };
      if (widget.isEdit) {
        params['vendor_code'] = data!.vendor_code;
      }
      Map<String, dynamic> tempMap = await apiController.fetchData(uri, params);
      setState(() {
        bool isFind = tempMap['isValid'];
        if (isFind) {
          // List tempList = tempMap['info'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(widget.isEdit
                    ? '$typeName Updated Successfully!'
                    : '$typeName Added Successfully!')),
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
    _contactpController.dispose();
    _email_idController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
