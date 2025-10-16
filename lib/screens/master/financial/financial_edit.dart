import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/models/financial_model.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/utils/radiobutton_utils.dart';
import 'package:sterlite_csr/utilities/utils/textfield_utils.dart';
import 'package:sterlite_csr/utilities/widget_decoration.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditFinancial extends StatefulWidget {
  final bool isEdit;
  final FinancialModel? financial;

  const EditFinancial({super.key, this.isEdit = false, this.financial});

  @override
  _EditFinancialState createState() => _EditFinancialState();
}

class _EditFinancialState extends State<EditFinancial> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  FinancialModel? data;

  String userRole = "";
  String userId = "";

  APIController apiController = Get.put(APIController());

  List<String> statusList = ['Active', 'Inactive'];
  String statusName = 'Active';

  @override
  void initState() {
    getUserInfo();
    super.initState();

    if (widget.isEdit && widget.financial != null) {
      data = widget.financial;
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
            widget.isEdit ? 'Edit Financial Year' : 'Add Financial Year',
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
                                  label: 'Financial Year',
                                  hint: 'Enter your financial year',
                                  icon: Icons.calendar_today,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter financial year';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
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
                              ? Center(
                                  child: DecorationWidgets.showProgressDialog(
                                      context))
                              : UtilsWidgets.buildPrimaryBtn(
                                  context,
                                  widget.isEdit
                                      ? 'Edit Financial'
                                      : 'Add Financial', () async {
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
      String uri = Constants.MASTER_URL + '/financial-year';
      Map params = {
        "user_id": userId,
        "action": widget.isEdit ? "update" : "add",
        "name": _nameController.text.trim(),
        "status": statusName == 'Active',
      };
      if (widget.isEdit) {
        params['financial_year_code'] = data!.financial_year_code;
      }
      Map<String, dynamic> tempMap = await apiController.fetchData(uri, params);
      setState(() {
        bool isFind = tempMap['isValid'];
        if (isFind) {
          // List tempList = tempMap['info'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(widget.isEdit
                    ? 'Financial year Updated Successfully!'
                    : 'Financial year Added Successfully!')),
          );
          String code = tempMap['code'] ?? data!.financial_year_code;
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
