import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/models/district_model.dart';
import 'package:sterlite_csr/models/state_model.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/method_utils.dart';
import 'package:sterlite_csr/utilities/utils/radiobutton_utils.dart';
import 'package:sterlite_csr/utilities/utils/search-dropdown_utils.dart';
import 'package:sterlite_csr/utilities/utils/textfield_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditDistrict extends StatefulWidget {
  final bool isEdit;
  final DistrictModel? cities;
  const EditDistrict({super.key, this.isEdit = false, this.cities});

  @override
  _EditDistrictState createState() => _EditDistrictState();
}

class _EditDistrictState extends State<EditDistrict> {
  final _formKey = GlobalKey<FormState>();
  DistrictModel? data;

  String userRole = "";
  String userId = "";

  APIController apiController = Get.put(APIController());

  final TextEditingController _nameController = TextEditingController();

  String selectedState = "";
  List<StateModel> stateOptions = [];
  List<String> statusList = ['Active', 'Inactive'];
  String statusName = 'Active';

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isDesktop = constraints.maxWidth < 600;
      return Scaffold(
          appBar: UtilsWidgets.buildAppBar(
            widget.isEdit ? 'Edit District' : 'Add District',
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
                                  label: 'District Name',
                                  hint: 'Enter your District name',
                                  icon: Icons.location_city,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your District name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              Flexible(
                                child: SearchDropdownUtils
                                    .buildSearchableDropdown<String>(
                                  items:
                                      stateOptions.map((e) => e.name).toList(),
                                  value: selectedState,
                                  label: "State",
                                  icon: Icons.map,
                                  hint: "Select state",
                                  onChanged: (value) {
                                    if (value != null) {
                                      selectedState = value;
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
                                      ? 'Edit District'
                                      : 'Add District', () async {
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
  }

  Future getStateInfo() async {
    setState(() {
      stateOptions.clear();
    });
    try {
      String uri = Constants.MASTER_URL + '/state';
      Map params = {"action": "list"};

      Map<String, dynamic> tempMap = await MethodUtils.apiCall(uri, params);

      setState(() {
        bool isFind = tempMap['isValid'];
        if (isFind) {
          List tempList = tempMap['info'];
          setState(() {
            for (var item in tempList) {
              stateOptions.add(StateModel.fromJson(item));
            }
            if (widget.isEdit && widget.cities != null) {
              data = widget.cities;
              _nameController.text = data!.name;
              selectedState = stateOptions
                  .firstWhere(
                      (element) => element.state_code == data!.state_code)
                  .name;

              statusName = data!.status ? 'Active' : 'Inactive';
            }
          });
        } else {
          String msg = tempMap['message'];
          UtilsWidgets.showToastFunc(msg);
        }
      });
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  Future _submitForm() async {
    try {
      String uri = Constants.MASTER_URL + '/district';
      Map params = {
        "user_id": userId,
        "action": widget.isEdit ? "update" : "add",
        "state_code": stateOptions
            .firstWhere((element) => element.name == selectedState)
            .state_code,
        "name": _nameController.text.trim(),
        "status": statusName == 'Active',
      };
      if (widget.isEdit) {
        params['district_code'] = data!.district_code;
      }
      Map<String, dynamic> tempMap = await apiController.fetchData(uri, params);
      setState(() {
        bool isFind = tempMap['isValid'];
        if (isFind) {
          // List tempList = tempMap['info'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(widget.isEdit
                    ? 'District Updated Successfully!'
                    : 'District Added Successfully!')),
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
