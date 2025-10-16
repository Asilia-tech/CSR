import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/models/state_model.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/utils/radiobutton_utils.dart';
import 'package:sterlite_csr/utilities/utils/textfield_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditState extends StatefulWidget {
  final bool isEdit;
  final StateModel? states;

  const EditState({super.key, this.isEdit = false, this.states});

  @override
  _EditStateState createState() => _EditStateState();
}

class _EditStateState extends State<EditState> {
  final _formKey = GlobalKey<FormState>();

  APIController apiController = Get.put(APIController());
  String userRole = "";
  String userId = "";

  StateModel? data;
  final TextEditingController _nameController = TextEditingController();

  List<String> statusList = ['Active', 'Inactive'];
  String statusName = 'Active';

  @override
  void initState() {
    getUserInfo();
    if (widget.isEdit && widget.states != null) {
      data = widget.states;
      _nameController.text = data!.name;

      statusName = data!.status ? 'Active' : 'Inactive';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isDesktop = constraints.maxWidth < 600;
      return Scaffold(
          appBar: UtilsWidgets.buildAppBar(
            widget.isEdit ? 'Edit State' : 'Add State',
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
                          TextFiledUtils.buildTextField(
                            controller: _nameController,
                            label: 'State Name',
                            hint: 'Enter your state name',
                            icon: Icons.map,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your state name';
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
                              : UtilsWidgets.buildPrimaryBtn(context,
                                  widget.isEdit ? 'Edit State' : 'Add State',
                                  () async {
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
  }

  Future _submitForm() async {
    try {
      String uri = Constants.MASTER_URL + '/state';
      Map params = {
        "user_id": userId,
        "action": widget.isEdit ? "update" : "add",
        "country_code": "IN",
        "name": _nameController.text.trim(),
        "status": statusName == 'Active',
      };
      if (widget.isEdit) {
        params['state_code'] = data!.state_code;
      }
      Map<String, dynamic> tempMap = await apiController.fetchData(uri, params);
      setState(() {
        bool isFind = tempMap['isValid'];
        if (isFind) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(widget.isEdit
                    ? 'State Updated Successfully!'
                    : 'State Added Successfully!')),
          );
          String code = tempMap['code'] ?? data!.state_code;
          Get.back(result: widget.isEdit ? true : code);
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
