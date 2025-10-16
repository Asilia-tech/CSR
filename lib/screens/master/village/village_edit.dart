import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/models/district_model.dart';
import 'package:sterlite_csr/models/village_model.dart';
import 'package:sterlite_csr/models/state_model.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/method_utils.dart';
import 'package:sterlite_csr/utilities/utils/radiobutton_utils.dart';
import 'package:sterlite_csr/utilities/utils/search-dropdown_utils.dart';
import 'package:sterlite_csr/utilities/utils/textfield_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditVillage extends StatefulWidget {
  final bool isEdit;
  final VillageModel? village;

  const EditVillage({super.key, this.isEdit = false, this.village});

  @override
  _EditVillageState createState() => _EditVillageState();
}

class _EditVillageState extends State<EditVillage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  APIController apiController = Get.put(APIController());
  String userId = "";
  String userRole = "";

  VillageModel? data;

  List<String> statusList = ['Active', 'Inactive'];
  String statusName = 'Active';

  String selectedState = "";
  List<StateModel> stateOptions = [];

  String selectedDistrict = "";
  List<DistrictModel> districtOptions = [];

  @override
  void initState() {
    super.initState();
    getUserInfo();
    if (widget.isEdit && widget.village != null) {
      data = widget.village;
      _nameController.text = data!.name;

      statusName = data!.status ? 'Active' : 'Inactive';
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isDesktop = constraints.maxWidth < 600;
      return Scaffold(
          appBar: UtilsWidgets.buildAppBar(
            widget.isEdit ? 'Edit Village' : 'Add Village',
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
          body: Column(
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
                                child: TextFiledUtils.buildTextField(
                                  controller: _nameController,
                                  label: 'Village Name',
                                  hint: 'Enter your village name',
                                  icon: Icons.layers,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your village name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                child:
                                    SearchDropdownUtils.buildSearchableDropdown(
                                  items:
                                      stateOptions.map((e) => e.name).toList(),
                                  value: selectedState,
                                  label: "State",
                                  icon: Icons.map,
                                  hint: "Select state",
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        selectedState = value;
                                      });
                                      getDistrictInfo();
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
                              ),
                            ],
                          ),
                          SearchDropdownUtils.buildSearchableDropdown(
                            items: districtOptions.map((e) => e.name).toList(),
                            value: selectedDistrict,
                            label: "District",
                            icon: Icons.location_city,
                            hint: "Select District",
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
                                return "Please select a District";
                              }
                              return null;
                            },
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
                              ? const Center(child: CircularProgressIndicator())
                              : UtilsWidgets.buildPrimaryBtn(
                                  context,
                                  widget.isEdit
                                      ? 'Edit Village'
                                      : 'Add Village', () async {
                                  if (_formKey.currentState!.validate()) {
                                    await _submitForm();
                                  }
                                }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
    if (widget.isEdit && data != null) {
      await getDistrictInfo();
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

  Future _submitForm() async {
    try {
      String uri = Constants.MASTER_URL + '/village';
      Map params = {
        "user_id": userId,
        "action": widget.isEdit ? "update" : "add",
        "state_code": stateOptions
            .firstWhere((element) => element.name == selectedState)
            .state_code,
        "district_code": districtOptions
            .firstWhere((element) => element.name == selectedDistrict)
            .district_code,
        "name": _nameController.text.trim(),
        "status": statusName == 'Active',
      };
      if (widget.isEdit) {
        params['village_code'] = data!.village_code;
      }
      Map<String, dynamic> tempMap = await apiController.fetchData(uri, params);
      setState(() {
        bool isFind = tempMap['isValid'];
        if (isFind) {
          // List tempList = tempMap['info'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(widget.isEdit
                    ? 'Village Updated Successfully!'
                    : 'Village Added Successfully!')),
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
    super.dispose();
  }
}
