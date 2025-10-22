import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/models/user_model.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/function_utils.dart';
import 'package:sterlite_csr/utilities/utils/dropdown_utils.dart';
import 'package:sterlite_csr/utilities/utils/radiobutton_utils.dart';
import 'package:sterlite_csr/utilities/utils/textfield_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditUser extends StatefulWidget {
  final bool isEdit;
  final UserModel? user;

  const EditUser({super.key, this.isEdit = false, this.user});

  @override
  _EditUserState createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _email_idController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  UserModel? data;

  APIController apiController = Get.put(APIController());
  String userId = "";
  String userRole = "";

  List<String> statusList = ['Active', 'Inactive'];
  String statusName = 'Active';

  List<String> roleList = ['CSR Head', 'Reviewer', 'Local CSR SPOC'];
  String roleListName = 'CSR Head';

  Map<String, dynamic> serviceMap = {
    "add": false,
    "edit": false,
    "delete": false,
    "view": false,
    "report": false,
    "master": false,
  };
  Map<String, dynamic> tempServiceMap = {};

  @override
  void initState() {
    super.initState();
    getUserInfo();
    if (widget.isEdit && widget.user != null) {
      data = widget.user;
      _nameController.text = data!.user_name;
      _email_idController.text = data!.email_id;
      _mobileController.text = data!.mobile;
      _passwordController.text = data!.password;
      serviceMap = data!.access_control;
      statusName = data!.status ? 'Active' : 'Inactive';
    }
    tempServiceMap = Map.from(serviceMap);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isDesktop = constraints.maxWidth < 600;
      return Scaffold(
          appBar: UtilsWidgets.buildAppBar(
            widget.isEdit ? 'Edit User' : 'Add User',
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
                                  child: TextFiledUtils.buildTextField(
                                    controller: _nameController,
                                    label: 'User Name',
                                    hint: 'Enter your user name',
                                    icon: Icons.person,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your user name';
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
                                    controller: _email_idController,
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
                            Row(
                              children: [
                                Flexible(
                                  child: DropdownUtils.buildDropdown(
                                      items: roleList,
                                      value: roleListName,
                                      label: 'Role',
                                      icon: Icons.area_chart,
                                      hint: 'Select Role',
                                      onChanged: (value) {
                                        setState(() {
                                          roleListName = value ?? '';
                                        });
                                      },
                                      displayTextFn: (item) => item),
                                ),
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
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        'Permissions',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(15, 8, 15, 8),
                                    decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        border: Border.all(
                                            color: Constants.blackColor,
                                            width: 0.0)),
                                    child: Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      alignment: WrapAlignment.center,
                                      runAlignment: WrapAlignment.center,
                                      children:
                                          tempServiceMap.entries.map((entry) {
                                        bool isEnabled = serviceMap[entry.key];
                                        return Container(
                                          padding: const EdgeInsets.all(8.0),
                                          width: isDesktop
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.75
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.25,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Row(
                                                children: [
                                                  Icon(
                                                    Utils.getServiceIcon(
                                                        entry.key),
                                                    color: isEnabled
                                                        ? Constants.primaryColor
                                                        : Colors.grey,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    Utils.getServiceName(
                                                        entry.key),
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              )),
                                              Expanded(
                                                flex: 2,
                                                child:
                                                    UtilsWidgets.toggleWidget(
                                                  [isEnabled, !isEnabled],
                                                  (index) {
                                                    setState(() {
                                                      serviceMap[entry.key] =
                                                          index == 0;
                                                    });
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
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
                                            ? 'Edit User'
                                            : 'Add User', () async {
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
  }

  Future _submitForm() async {
    try {
      String uri = Constants.USER_URL + '/user';
      Map params = {
        "changer_id": userId,
        "action": widget.isEdit ? "update" : "add",
        "user_name": _nameController.text.trim(),
        "mobile": _mobileController.text.trim(),
        "email": _email_idController.text.trim().toLowerCase(),
        "password": _passwordController.text.trim(),
        "access_control": tempServiceMap,
        "role": roleListName,
        "status": statusName == 'Active',
      };
      if (widget.isEdit) {
        params['user_id'] = data!.user_id;
      }
      Map<String, dynamic> tempMap = await apiController.fetchData(uri, params);
      setState(() {
        bool isFind = tempMap['isValid'];
        if (isFind) {
          // List tempList = tempMap['info'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(widget.isEdit
                    ? 'User Updated Successfully!'
                    : 'User Added Successfully!')),
          );

          String code = tempMap['code'] ?? data!.user_id;
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
    _mobileController.dispose();
    _email_idController.dispose();
    super.dispose();
  }
}
