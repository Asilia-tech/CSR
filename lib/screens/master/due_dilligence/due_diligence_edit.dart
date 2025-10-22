import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/models/associate_model.dart';
import 'package:sterlite_csr/models/due_diligence_model.dart';
import 'package:sterlite_csr/models/project_model.dart';
import 'package:sterlite_csr/models/vendor_model.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/function_utils.dart';
import 'package:sterlite_csr/utilities/method_utils.dart';
import 'package:sterlite_csr/utilities/utils/radiobutton_utils.dart';
import 'package:sterlite_csr/utilities/utils/search-dropdown_utils.dart';
import 'package:sterlite_csr/utilities/utils/textfield_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class EditDueDiligence extends StatefulWidget {
  final bool isEdit;
  final DueDiligenceModel? due_diligence;

  const EditDueDiligence({super.key, this.isEdit = false, this.due_diligence});

  @override
  _EditDueDiligenceState createState() => _EditDueDiligenceState();
}

class _EditDueDiligenceState extends State<EditDueDiligence> {
  APIController apiController = Get.put(APIController());
  bool isFind = false;
  String msg = 'Please wait...';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _yearsOfexistenceController =
      TextEditingController();
  final TextEditingController _clienteleController = TextEditingController();
  final TextEditingController _turnaroundTimeController =
      TextEditingController();
  final TextEditingController _subjectKnowledgeController =
      TextEditingController();
  final TextEditingController _turnoverController = TextEditingController();

  Map<String, File> _uploadedFiles = {};

  Map<String, dynamic> document_map = {};

  DueDiligenceModel? data;
  List<String> typeList = ['Vendor', 'NGO'];
  String typeName = 'Vendor';
  List<String> statusList = ['Active', 'Inactive'];
  String statusName = 'Active';
  String selectedProject = "";
  String selectedNV = "";
  List<ProjectModel> projectOptions = [];
  String selectedAssociate = "";
  List<AssociateModel> associateOptions = [];
  List<VendorModel> _vendors = [];

  String userId = "";
  String userRole = "";

  @override
  void initState() {
    super.initState();
    getUserInfo();
    if (widget.due_diligence != null) {
      data = widget.due_diligence;
      _yearsOfexistenceController.text = data!.years_existence;
      _clienteleController.text = data!.clientele;
      _turnaroundTimeController.text = data!.turnaround_time;
      _subjectKnowledgeController.text = data!.subject_knowledge;
      _turnoverController.text = data!.turnover;
      document_map = data!.document_map;
      statusName = data!.status ? 'Active' : 'Inactive';
      typeName = data!.type;
    }
  }

  @override
  void dispose() {
    _yearsOfexistenceController.dispose();
    _clienteleController.dispose();
    _turnaroundTimeController.dispose();
    _subjectKnowledgeController.dispose();
    _turnoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isDesktop = constraints.maxWidth < 600;
      return Scaffold(
        appBar: UtilsWidgets.buildAppBar(
          'Edit Due Diligence',
          Get.isDarkMode,
          leading: !isDesktop
              ? null
              : Container(
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
                      if (userRole == 'vendor_admin')
                        _buildAddForm()
                      else if (userRole == 'super_admin')
                        // && data!.isSubmit)
                        _buildVendorInfoCard()
                      else if (userRole == 'Local CSR SPOC' ||
                          userRole == 'Reviewer')
                        _buildVendorInfoCard(),
                      const SizedBox(height: 24),
                      _buildDocumentsSection(),
                      const SizedBox(height: 16),
                      if (userRole == 'vendor_admin')
                        apiController.isLoading.value
                            ? const Center(child: CircularProgressIndicator())
                            : UtilsWidgets.buildPrimaryBtn(
                                context, 'Update Due Diligence', () async {
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

  Widget _buildAddForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: RadioButtonUtils.buildRadioGroup<String>(
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
              ),
              Flexible(
                child: SearchDropdownUtils.buildSearchableDropdown(
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
                        selectedNV = "";
                        associateOptions.clear();
                        _vendors.clear();
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
            ],
          ),
          Row(
            children: [
              Flexible(
                child: SearchDropdownUtils.buildSearchableDropdown<String>(
                  items: associateOptions
                      .map((city) => city.associate_project_name)
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
                    }

                    await getVendorInfo();
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
              SizedBox(width: 16),
              Flexible(
                child: SearchDropdownUtils.buildSearchableDropdown(
                  items: _vendors.map((vendor) => vendor.vendor_name).toList(),
                  value: selectedNV,
                  label: "NGO/Vendor",
                  icon: Icons.business,
                  hint: "Select NGO/Vendor",
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedNV = value;
                      });
                    }
                  },
                  displayTextFn: (item) => item,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please select an NGO/Vendor";
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
                  controller: _yearsOfexistenceController,
                  label: 'Year of existence',
                  hint: 'Enter year of existence',
                  icon: Icons.calendar_today,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter year of existence';
                    }
                  },
                  keyboardType: TextInputType.number,
                  inputFormatter: Utils.allowInputFormatter('[0-9.]'),
                ),
              ),
              SizedBox(width: 16),
              Flexible(
                child: TextFiledUtils.buildTextField(
                  controller: _clienteleController,
                  label: 'Clientele',
                  hint: 'Enter clientele',
                  icon: Icons.people,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your clientele';
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
                  controller: _subjectKnowledgeController,
                  label: 'Subject Knowledge',
                  hint: 'Enter subject knowledge',
                  icon: Icons.book,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter subject knowledge';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16),
              Flexible(
                child: TextFiledUtils.buildTextField(
                  controller: _turnaroundTimeController,
                  label: 'Turn around time',
                  hint: 'Enter turn around time',
                  icon: Icons.timer,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter turn around time';
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
                  controller: _turnoverController,
                  label: 'Turn over',
                  hint: 'Enter turn over',
                  icon: Icons.attach_money,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter turn over';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16),
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
        ],
      ),
    );
  }

  Future getVendorInfo() async {
    setState(() {
      _vendors.clear();
    });
    try {
      String uri = Constants.MASTER_URL + '/vendor';
      Map params = {
        "action": "list",
        "project_code": projectOptions
            .firstWhere((element) => element.project_name == selectedProject)
            .project_code,
        "associate_project_code": associateOptions
            .firstWhere((element) =>
                element.associate_project_name == selectedAssociate)
            .associate_project_code,
      };

      Map<String, dynamic> tempMap = await apiController.fetchData(uri, params);
      setState(() {
        isFind = tempMap['isValid'];
        if (isFind) {
          List tempList = tempMap['info']['vendors'];
          for (var item in tempList) {
            _vendors.add(VendorModel.fromJson(item));
          }
        } else {
          msg = tempMap['message'];
        }
      });
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
      setState(() {
        isFind = tempMap['isValid'];
        if (isFind) {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            projectOptions.add(ProjectModel.fromJson(item));
          }
          msg = 'Select a project and associate project to view duediligences';
        } else {
          msg = tempMap['message'];
        }
      });
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
      setState(() {
        isFind = tempMap['isValid'];
        if (isFind) {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            associateOptions.add(AssociateModel.fromJson(item));
          }
          msg = 'Select a city to view duediligences';
        } else {
          msg = tempMap['message'];
        }
      });
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  Future _submitForm() async {
    try {
      String uri = Constants.MASTER_URL + '/duediligence';
      print(uri);
      Map params = {
        "user_id": userId,
        "action": "update",
        "type": typeName,
        "project_code": projectOptions
            .firstWhere((p) => p.project_name == selectedProject)
            .project_code,
        "associate_project_code": associateOptions
            .firstWhere((a) => a.associate_project_name == selectedAssociate)
            .associate_project_code,
        "vendor_code":
            _vendors.firstWhere((v) => v.vendor_name == selectedNV).vendor_code,
        "years_existence": _yearsOfexistenceController.text.trim(),
        "clientele": _clienteleController.text.trim(),
        "subject_knowledge": _subjectKnowledgeController.text.trim(),
        "turnaround_time": _turnaroundTimeController.text.trim(),
        "turnover": _turnoverController.text.trim(),
        "status": statusName == 'Active',
        "document_map": document_map,
      };
      print(params);

      Map<String, dynamic> tempMap = await apiController.fetchData(uri, params);
      print(tempMap);
      setState(() {
        bool isFind = tempMap['isValid'];
        if (isFind) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Due Diligence Updated Successfully!')),
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

  Widget _buildVendorInfoCard() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Vendor Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 12),
            Wrap(
              spacing: 20.0, // Horizontal space between items
              runSpacing: 16.0, // Vertical space between rows
              children: [
                _buildInfoRow('Vendor/NGO Code', data?.vendor_code ?? 'N/A'),
                _buildInfoRow('Project Code', data?.project_code ?? 'N/A'),
                _buildInfoRow('Associated Project',
                    data?.associate_project_code ?? 'N/A'),
                _buildInfoRow(
                    'Years of Existence', data?.years_existence ?? 'N/A'),
                _buildInfoRow('Clientele', data?.clientele ?? 'N/A'),
                _buildInfoRow(
                    'Subject Knowledge', data?.subject_knowledge ?? 'N/A'),
                _buildInfoRow(
                    'Turnaround Time', data?.turnaround_time ?? 'N/A'),
                _buildInfoRow('Turnover', data?.turnover ?? 'N/A'),
                _buildInfoRow(
                  'Status',
                  data?.status == true ? 'Active' : 'Inactive',
                  valueColor: data?.status == true
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth > 550 ? 250 : double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocumentsSection() {
    Map<String, dynamic> docMap = data != null ? data!.document_map : {};
    if (docMap.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No documents available')),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Document Approval',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 16),
        Center(child: _buildDocumentTable(docMap)),
      ],
    );
  }

  Widget _buildDocumentTable(Map<String, dynamic> documentMap) {
    final columns = [
      const DataColumn(
          label: Text('Document Name',
              style: TextStyle(fontWeight: FontWeight.bold))),
      const DataColumn(
          label: Text('CSR SPOC Status',
              style: TextStyle(fontWeight: FontWeight.bold))),
      const DataColumn(
          label: Text('Reviewer Status',
              style: TextStyle(fontWeight: FontWeight.bold))),
      const DataColumn(
          label:
              Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: 2,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(
                Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              columns: columns,
              rows: documentMap.entries.map((entry) {
                String docKey = entry.key;
                Map<String, dynamic> docData =
                    Map<String, dynamic>.from(entry.value);
                String documentName = docData['name'] ?? 'Unknown Document';
                List<dynamic> approvals = docData['approvals'] ?? [];

                Map<String, dynamic> csrSpocApproval = approvals.firstWhere(
                  (a) => a['role'] == 'CSR_SPOC',
                  orElse: () => {'status': 'Pending', 'remark': ''},
                );

                Map<String, dynamic> reviewerApproval = approvals.firstWhere(
                  (a) => a['role'] == 'Reviewer',
                  orElse: () => {'status': 'Pending', 'remark': ''},
                );

                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 400,
                        child: Text(
                          documentName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                    DataCell(_buildStatusChip(
                      csrSpocApproval['status'] ?? 'Pending',
                      csrSpocApproval['approved_by'] ?? '',
                      csrSpocApproval['approved_at'] ?? '',
                      remark: csrSpocApproval['remark'] ?? '',
                      onTap: userRole == 'Local CSR SPOC'
                          ? () => _showStatusUpdateDialog(docKey, 'CSR_SPOC')
                          : () => _showStatusDetailsDialog(
                              csrSpocApproval['status'] ?? 'Pending',
                              csrSpocApproval['remark'] ?? ''),
                    )),
                    DataCell(_buildStatusChip(
                      reviewerApproval['status'] ?? 'Pending',
                      reviewerApproval['approved_by'] ?? '',
                      reviewerApproval['approved_at'] ?? '',
                      remark: reviewerApproval['remark'] ?? '',
                      onTap: userRole == 'Reviewer'
                          ? () => _showStatusUpdateDialog(docKey, 'Reviewer')
                          : () => _showStatusDetailsDialog(
                              reviewerApproval['status'] ?? 'Pending',
                              reviewerApproval['remark'] ?? ''),
                    )),
                    DataCell(
                      _buildEditModeActions(docKey, documentName,
                          csrSpocApproval, reviewerApproval),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditModeActions(String docKey, String documentName,
      Map<String, dynamic> csrSpoc, Map<String, dynamic> reviewer) {
    bool requiresResend =
        csrSpoc['status'] == 'Resend' || reviewer['status'] == 'Resend';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.visibility, size: 20),
          tooltip: 'View Document',
          onPressed: () => _viewDocument(docKey, documentName),
        ),
        // This condition now correctly shows the upload icon ONLY for vendor_admin when a document needs to be re-uploaded.
        if (userRole == 'vendor_admin' && requiresResend)
          IconButton(
            icon: Icon(Icons.upload_file, size: 20, color: Constants.redColor),
            tooltip: 'Re-upload Document',
            onPressed: () => _pickFile(docKey, isResend: true),
          ),
      ],
    );
  }

  Future<void> _pickFile(String docKey, {bool isResend = false}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        _uploadedFiles[docKey] = file;
      });
      if (isResend) {
        UtilsWidgets.showToastFunc(
            'Re-upload logic to be implemented for $docKey');
      } else {
        UtilsWidgets.showToastFunc(
            'File selected: ${file.path.split('/').last}');
      }
    } else {
      // User canceled the picker
    }
  }

  Widget _buildStatusChip(String status, String approvedBy, String approvedAt,
      {required String remark, VoidCallback? onTap}) {
    Color chipColor;
    final lowerCaseStatus = status.toLowerCase();

    switch (lowerCaseStatus) {
      case 'pending':
        chipColor = Constants.primaryColor;
        break;
      case 'resend':
      case 'rejected':
        chipColor = Constants.redColor;
        break;
      case 'approved':
        chipColor = Constants.group2_deep;
        break;
      default:
        chipColor = Colors.grey;
    }

    IconData icon = Utils.getStatusIcon(lowerCaseStatus);

    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: approvedBy.isNotEmpty
            ? 'By: $approvedBy\nAt: $approvedAt'
            : 'Status: $status. Click to see details.',
        child: Chip(
          avatar: Icon(icon, size: 16, color: Colors.white),
          label: Text(
            status,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: chipColor.withOpacity(0.5),
          side: BorderSide(color: chipColor),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ),
    );
  }

  void _showStatusDetailsDialog(String status, String remark) {
    String dialogContent;

    if (status.toLowerCase() == 'pending') {
      dialogContent = "The documents are under examination.";
    } else if (remark.isNotEmpty) {
      dialogContent = remark;
    } else {
      dialogContent = "No specific reason was provided.";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Status Details: $status'),
        content: Text(
          dialogContent,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(String docKey, String role) {
    final TextEditingController remarkController = TextEditingController();
    String selectedStatus = 'approved';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update Status for $role'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: ['approved', 'rejected', 'resend']
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status.capitalizeFirst!),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: remarkController,
                    decoration: const InputDecoration(
                      labelText: 'Remark',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _updateDocumentStatus(
                      docKey,
                      selectedStatus,
                      reason: remarkController.text,
                    );
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _viewDocument(String docKey, String documentName,
      {bool isLocal = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isLocal ? 'Preview' : documentName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 300,
              width: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: isLocal
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.description,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(documentName.split('/').last,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 8),
                          const Text('Local file preview',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.description, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Document Preview'),
                          SizedBox(height: 8),
                          Text(
                            'Implement network image/PDF viewer here',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (!isLocal)
            ElevatedButton.icon(
              onPressed: () {
                UtilsWidgets.showToastFunc(
                    'Download functionality to be implemented');
              },
              icon: const Icon(Icons.download),
              label: const Text('Download'),
            ),
        ],
      ),
    );
  }

  Future<void> getUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id') ?? '';
      userRole = prefs.getString('role') ?? '';
    });
    await fetchVendorData();
    await getProjectInfo();
  }

  Future<void> fetchVendorData() async {
    try {
      Map<String, dynamic> vendorData = {
        "type": "Vendor",
        "status": true,
        "isSubmit": true,
        "vendor_code": "VND001",
        "project_code": "PRJ2025A",
        "associate_project_code": "APJ1023",
        'vendor_name': "vendor_name",
        'project_name': "project_name",
        'associate_project_name': "associate_project_name",
        "years_existence": "10 Years",
        "clientele": "Schools, NGOs, EdTech Companies",
        "subject_knowledge": "STEM, English, and Life Skills",
        "turnaround_time": "5 Business Days",
        "turnover": "₹5 Crore per annum",
        "document_map": {
          "document_1": {
            "name":
                "Registration Proof- Trust Act / Societies Registration Act / Section 8 Company (Companies Act, 2013)",
            "isLocked": false,
            "approvals": [
              {
                "role": "CSR_SPOC",
                "status": "Resend",
                "remark":
                    "The uploaded document is not legible. Please upload a clear copy.",
                "approved_by": "",
                "approved_at": ""
              },
              {
                "role": "Reviewer",
                "status": "Pending",
                "remark": "",
                "approved_by": "",
                "approved_at": ""
              }
            ]
          },
          "document_2": {
            "name": "12A & 80G Certification (for tax exemption in India)",
            "isLocked": false,
            "approvals": [
              {
                "role": "CSR_SPOC",
                "status": "Pending",
                "remark": "",
                "approved_by": "",
                "approved_at": ""
              },
              {
                "role": "Reviewer",
                "status": "Pending",
                "remark": "",
                "approved_by": "",
                "approved_at": ""
              }
            ]
          },
          "document_3": {
            "name": "FCRA Registration (if foreign funds are involved)",
            "isLocked": true,
            "approvals": [
              {
                "role": "CSR_SPOC",
                "status": "Approved",
                "remark": "",
                "approved_by": "",
                "approved_at": ""
              },
              {
                "role": "Reviewer",
                "status": "Approved",
                "remark": "",
                "approved_by": "",
                "approved_at": ""
              }
            ]
          },
          "document_4": {
            "name": "PAN Card & TAN",
            "isLocked": false,
            "approvals": [
              {
                "role": "CSR_SPOC",
                "status": "Approved",
                "remark":
                    "The uploaded document is not legible. Please upload a clear copy.",
                "approved_by": "",
                "approved_at": ""
              },
              {
                "role": "Reviewer",
                "status": "Pending",
                "remark": "",
                "approved_by": "",
                "approved_at": ""
              }
            ]
          },
          "document_5": {
            "name": "CSR-1",
            "isLocked": false,
            "approvals": [
              {
                "role": "CSR_SPOC",
                "status": "Resend",
                "remark":
                    "The uploaded document is not legible. Please upload a clear copy.",
                "approved_by": "",
                "approved_at": ""
              },
              {
                "role": "Reviewer",
                "status": "Pending",
                "remark": "",
                "approved_by": "",
                "approved_at": ""
              }
            ]
          },
          "document_6": {
            "name": "NGO Darpan certificate",
            "isLocked": false,
            "approvals": [
              {
                "role": "CSR_SPOC",
                "status": "Resend",
                "remark":
                    "The uploaded document is not legible. Please upload a clear copy.",
                "approved_by": "",
                "approved_at": ""
              },
              {
                "role": "Reviewer",
                "status": "Pending",
                "remark": "",
                "approved_by": "",
                "approved_at": ""
              }
            ]
          },
          "document_7": {
            "name": "Audited Financial Statement of last three years",
            "isLocked": false,
            "approvals": [
              {
                "role": "CSR_SPOC",
                "status": "Approved",
                "remark":
                    "The uploaded document is not legible. Please upload a clear copy.",
                "approved_by": "",
                "approved_at": ""
              },
              {
                "role": "Reviewer",
                "status": "Pending",
                "remark": "",
                "approved_by": "",
                "approved_at": ""
              }
            ]
          },
          "document_8": {
            "name": "Latest Annual Report",
            "isLocked": false,
            "approvals": [
              {
                "role": "CSR_SPOC",
                "status": "Approved",
                "remark":
                    "The uploaded document is not legible. Please upload a clear copy.",
                "approved_by": "",
                "approved_at": ""
              },
              {
                "role": "Reviewer",
                "status": "Pending",
                "remark": "",
                "approved_by": "",
                "approved_at": ""
              }
            ]
          },
          "document_9": {
            "name": "Income Tax return for last three years",
            "isLocked": false,
            "approvals": [
              {
                "role": "CSR_SPOC",
                "status": "Pending",
                "remark":
                    "The uploaded document is not legible. Please upload a clear copy.",
                "approved_by": "",
                "approved_at": ""
              },
              {
                "role": "Reviewer",
                "status": "Pending",
                "remark": "",
                "approved_by": "",
                "approved_at": ""
              }
            ]
          },
          "document_10": {
            "name": "List of donors/partners",
            "isLocked": false,
            "approvals": [
              {
                "role": "CSR_SPOC",
                "status": "Approved",
                "remark":
                    "The uploaded document is not legible. Please upload a clear copy.",
                "approved_by": "",
                "approved_at": ""
              },
              {
                "role": "Reviewer",
                "status": "Resend",
                "remark": "",
                "approved_by": "",
                "approved_at": ""
              }
            ]
          },
        }
      };

      if (widget.due_diligence == null) {
        setState(() {
          data = DueDiligenceModel.fromJson(vendorData);
        });
      }
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  Future<void> _updateDocumentStatus(
    String docKey,
    String status, {
    String? reason,
  }) async {
    try {
      String uri = Constants.MASTER_URL + '/vendor/document';
      Map params = {
        "action": "update_status",
        "vendor_code": data?.vendor_code,
        "document_key": docKey,
        "status": status,
        "approved_by": userId,
        "role": userRole,
        "approved_at": DateTime.now().toIso8601String(),
      };

      if (reason != null && reason.isNotEmpty) {
        params['rejection_reason'] = reason;
      }

      Map tempMap = await MethodUtils.apiCall(uri, params);

      if (tempMap['isValid']) {
        UtilsWidgets.showToastFunc('Document $status successfully');
        setState(() {
          var approval =
              (data!.document_map[docKey]['approvals'] as List<dynamic>)
                  .firstWhere((a) => a['role'] == userRole);
          approval['status'] = status;
          approval['approved_by'] = userId;
          approval['approved_at'] = DateTime.now().toIso8601String();
          approval['remark'] = reason ?? '';
        });
      } else {
        UtilsWidgets.showToastFunc(
          tempMap['message'] ?? 'Failed to update document status',
        );
      }
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }
}
