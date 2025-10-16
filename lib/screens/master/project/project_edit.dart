import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sterlite_csr/models/project_model.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/utils/radiobutton_utils.dart';
import 'package:sterlite_csr/utilities/utils/textfield_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';

class EditProject extends StatefulWidget {
  final bool isEdit;
  final ProjectModel? project;

  const EditProject({super.key, this.isEdit = false, this.project});

  @override
  _EditProjectState createState() => _EditProjectState();
}

class _EditProjectState extends State<EditProject> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  ProjectModel? data;

  String userRole = "";
  String userId = "";

  APIController apiController = Get.put(APIController());

  List<String> statusList = ['Active', 'Inactive'];
  String statusName = 'Active';

  @override
  void initState() {
    getUserInfo();
    super.initState();
    if (widget.isEdit && widget.project != null) {
      data = widget.project;
      _nameController.text = data!.project_name;
      statusName = data!.status ? 'Active' : 'Inactive';
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // bool isDesktop = constraints.maxWidth < 600;
      return Scaffold(
          appBar: UtilsWidgets.buildAppBar(
            widget.isEdit ? 'Edit Project' : 'Add Project',
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
              Container(
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
                                label: 'Project Name',
                                hint: 'Enter project name',
                                icon: Icons.badge,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter project name';
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Flexible(
                              child: RadioButtonUtils.buildRadioGroup<String>(
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
                        UtilsWidgets.buildPrimaryBtn(context,
                            widget.isEdit ? 'Edit Project' : 'Add Project',
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
      String uri = Constants.MASTER_URL + '/main-project';
      Map params = {
        "user_id": userId,
        "action": widget.isEdit ? "update" : "add",
        "project_name": _nameController.text.trim(),
        "status": statusName == 'Active' ? true : false
      };
      if (widget.isEdit) {
        params['project_code'] = data!.project_code;
      }
      Map<String, dynamic> tempMap = await apiController.fetchData(uri, params);
      setState(() {
        bool isFind = tempMap['isValid'];
        if (isFind) {
          // List tempList = tempMap['info'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(widget.isEdit
                    ? 'Project Updated Successfully!'
                    : 'Project Added Successfully!')),
          );
          String code = tempMap['code'] ?? data!.project_code;
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
