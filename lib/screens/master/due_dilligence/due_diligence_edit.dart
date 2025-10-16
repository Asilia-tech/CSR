import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/models/due_diligence_model.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/method_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditDueDiligence extends StatefulWidget {
  final bool isEdit;
  final DueDiligenceModel? due_diligence;

  const EditDueDiligence({super.key, this.isEdit = false, this.due_diligence});

  @override
  _EditDueDiligenceState createState() => _EditDueDiligenceState();
}

class _EditDueDiligenceState extends State<EditDueDiligence> {
  APIController apiController = Get.put(APIController());

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _yearsOfexistenceController =
      TextEditingController();
  final TextEditingController _clienteleController = TextEditingController();
  final TextEditingController _turnaroundTimeController =
      TextEditingController();
  final TextEditingController _subjectKnowledgeController =
      TextEditingController();
  final TextEditingController _turnoverController = TextEditingController();

  Map document_map = {
    "document_1": {
      "name":
          "Registration Proof- Trust Act / Societies Registration Act / Section 8 Company (Companies Act, 2013)",
      "CSR_SPOC": {"status": "Pending", "approved_by": "", "approved_at": ""},
      "Reviewer": {"status": "Pending", "approved_by": "", "approved_at": ""}
    },
    "document_2": {
      "name": "12A & 80G Certification (for tax exemption in India)",
      "CSR_SPOC": {"status": "Pending", "approved_by": "", "approved_at": ""},
      "Reviewer": {"status": "Pending", "approved_by": "", "approved_at": ""}
    },
    "document_3": {
      "name": "FCRA Registration (if foreign funds are involved)",
      "CSR_SPOC": {"status": "Pending", "approved_by": "", "approved_at": ""},
      "Reviewer": {"status": "Pending", "approved_by": "", "approved_at": ""}
    },
    "document_4": {
      "name": "PAN Card & TAN",
      "CSR_SPOC": {"status": "Pending", "approved_by": "", "approved_at": ""},
      "Reviewer": {"status": "Pending", "approved_by": "", "approved_at": ""}
    },
    "document_5": {
      "name": "CSR-1",
      "CSR_SPOC": {"status": "Pending", "approved_by": "", "approved_at": ""},
      "Reviewer": {"status": "Pending", "approved_by": "", "approved_at": ""}
    },
    "document_6": {
      "name": "NGO Darpan certificate",
      "CSR_SPOC": {"status": "Pending", "approved_by": "", "approved_at": ""},
      "Reviewer": {"status": "Pending", "approved_by": "", "approved_at": ""}
    },
    "document_7": {
      "name": "Audited Financial Statement of last three years",
      "CSR_SPOC": {"status": "Pending", "approved_by": "", "approved_at": ""},
      "Reviewer": {"status": "Pending", "approved_by": "", "approved_at": ""}
    },
    "document_8": {
      "name": "Latest Annual Report",
      "CSR_SPOC": {"status": "Pending", "approved_by": "", "approved_at": ""},
      "Reviewer": {"status": "Pending", "approved_by": "", "approved_at": ""}
    },
    "document_9": {
      "name": "Income Tax return for last three years",
      "CSR_SPOC": {"status": "Pending", "approved_by": "", "approved_at": ""},
      "Reviewer": {"status": "Pending", "approved_by": "", "approved_at": ""}
    },
    "document_10": {
      "name": "List of donors/partners",
      "CSR_SPOC": {"status": "Pending", "approved_by": "", "approved_at": ""},
      "Reviewer": {"status": "Pending", "approved_by": "", "approved_at": ""}
    },
  };

  DueDiligenceModel? data;

  String userId = "";
  String userRole = "";

  @override
  void initState() {
    super.initState();
    getUserInfo();
    if (widget.isEdit && widget.due_diligence != null) {
      data = widget.due_diligence;
      _yearsOfexistenceController.text = data!.years_existence;
      _clienteleController.text = data!.years_existence;
      _turnaroundTimeController.text = data!.years_existence;
      _subjectKnowledgeController.text = data!.years_existence;
      _turnoverController.text = data!.years_existence;
      document_map = data!.document_map;
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
          'Due Diligence',
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
                    children: [
                      // _buildVendorInfoCard(),
                      // const SizedBox(height: 24),
                      // _buildDocumentsSection(),
                    ],
                  ),
                ),
              ),
      );
    });
  }

  // Widget _buildVendorInfoCard() {
  //   return Card(
  //     elevation: 2,
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Vendor Information',
  //             style: Theme.of(context).textTheme.titleLarge?.copyWith(
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //           ),
  //           const Divider(height: 24),
  //           _buildInfoRow('Vendor/NGO Code', data!.vendor_code),
  //           _buildInfoRow('Project Code', data!.project_code),
  //           _buildInfoRow('Associated Project', data!.associate_project_code),
  //           _buildInfoRow('Years of Existence', data!.years_existence),
  //           _buildInfoRow('Clientele', data!.clientele),
  //           _buildInfoRow('Subject Knowledge', data!.subject_knowledge),
  //           _buildInfoRow('Turnaround Time', data!.turnaround_time),
  //           _buildInfoRow('Turnover', data!.turnover),
  //           _buildInfoRow(
  //             'Status',
  //             data!.status == true ? 'Active' : 'Inactive',
  //             valueColor: data!.status == true ? Colors.green : Colors.red,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Expanded(
  //           flex: 2,
  //           child: Text(
  //             label,
  //             style: const TextStyle(
  //               fontWeight: FontWeight.w600,
  //               color: Colors.grey,
  //             ),
  //           ),
  //         ),
  //         Expanded(
  //           flex: 3,
  //           child: Text(
  //             value,
  //             style: TextStyle(
  //               fontWeight: FontWeight.w500,
  //               color: valueColor,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildDocumentsSection() {
  //   Map<String, dynamic> documentMap = data!.document_map;
  //   if (documentMap.isEmpty) {
  //     return const Card(
  //       child: Padding(
  //         padding: EdgeInsets.all(16),
  //         child: Center(child: Text('No documents available')),
  //       ),
  //     );
  //   }
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Document Approval',
  //         style: Theme.of(context).textTheme.titleLarge?.copyWith(
  //               fontWeight: FontWeight.bold,
  //             ),
  //       ),
  //       const SizedBox(height: 16),
  //       _buildDocumentTable(documentMap),
  //     ],
  //   );
  // }

  // Widget _buildDocumentTable(Map<String, dynamic> documentMap) {
  //   return Card(
  //     elevation: 2,
  //     child: SingleChildScrollView(
  //       scrollDirection: Axis.horizontal,
  //       child: DataTable(
  //         headingRowColor: MaterialStateProperty.all(
  //           Theme.of(context).primaryColor.withOpacity(0.1),
  //         ),
  //         columnSpacing: 16,
  //         horizontalMargin: 16,
  //         columns: const [
  //           DataColumn(
  //               label: Text('Document Name',
  //                   style: TextStyle(fontWeight: FontWeight.bold))),
  //           DataColumn(
  //               label: Text('CSR SPOC Status',
  //                   style: TextStyle(fontWeight: FontWeight.bold))),
  //           DataColumn(
  //               label: Text('Reviewer Status',
  //                   style: TextStyle(fontWeight: FontWeight.bold))),
  //           DataColumn(
  //               label: Text('Actions',
  //                   style: TextStyle(fontWeight: FontWeight.bold))),
  //         ],
  //         rows: documentMap.entries.map((entry) {
  //           String docKey = entry.key;
  //           Map<String, dynamic> docData = entry.value as Map<String, dynamic>;
  //           String documentName = docData['name'] ?? 'Unknown Document';
  //           Map<String, dynamic> csrSpoc = docData['CSR_SPOC'] ?? {};
  //           Map<String, dynamic> reviewer = docData['Reviewer'] ?? {};
  //           return DataRow(
  //             cells: [
  //               DataCell(
  //                 SizedBox(
  //                   width: 150,
  //                   child: Text(documentName, overflow: TextOverflow.ellipsis),
  //                 ),
  //               ),
  //               DataCell(
  //                 _buildStatusChip(
  //                   csrSpoc['status'] ?? 'Pending',
  //                   csrSpoc['approved_by'] ?? '',
  //                   csrSpoc['approved_at'] ?? '',
  //                 ),
  //               ),
  //               DataCell(
  //                 _buildStatusChip(
  //                   reviewer['status'] ?? 'Pending',
  //                   reviewer['approved_by'] ?? '',
  //                   reviewer['approved_at'] ?? '',
  //                 ),
  //               ),
  //               DataCell(
  //                 Row(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     IconButton(
  //                       icon: const Icon(Icons.visibility, size: 20),
  //                       tooltip: 'View Document',
  //                       onPressed: () => _viewDocument(docKey, documentName),
  //                     ),
  //                     if (_canApprove(csrSpoc, reviewer))
  //                       IconButton(
  //                         icon: const Icon(Icons.check_circle,
  //                             size: 20, color: Colors.green),
  //                         tooltip: 'Approve',
  //                         onPressed: () =>
  //                             _approveDocument(docKey, documentName),
  //                       ),
  //                     if (_canReject(csrSpoc, reviewer))
  //                       IconButton(
  //                         icon: const Icon(Icons.cancel,
  //                             size: 20, color: Colors.red),
  //                         tooltip: 'Reject',
  //                         onPressed: () =>
  //                             _rejectDocument(docKey, documentName),
  //                       ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           );
  //         }).toList(),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildStatusChip(String status, String approvedBy, String approvedAt) {
  //   Color chipColor = Utils.getStatusColor(status.toLowerCase());
  //   IconData icon = Utils.getStatusIcon(status.toLowerCase());
  //   return Tooltip(
  //     message: approvedBy.isNotEmpty
  //         ? 'Approved by: $approvedBy\nAt: $approvedAt'
  //         : 'Status: $status',
  //     child: Chip(
  //       avatar: Icon(icon, size: 16, color: Colors.white),
  //       label: Text(
  //         status,
  //         style: const TextStyle(color: Colors.white, fontSize: 12),
  //       ),
  //       backgroundColor: chipColor.withOpacity(0.5),
  //       side: BorderSide(color: chipColor),
  //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //     ),
  //   );
  // }

  // bool _canApprove(
  //     Map<String, dynamic> csrSpoc, Map<String, dynamic> reviewer) {
  //   if (userRole == 'CSR_SPOC') {
  //     return csrSpoc['status'] == 'Pending';
  //   } else if (userRole == 'Reviewer') {
  //     return reviewer['status'] == 'Pending' && csrSpoc['status'] == 'Approved';
  //   }
  //   return false;
  // }

  // bool _canReject(Map<String, dynamic> csrSpoc, Map<String, dynamic> reviewer) {
  //   if (userRole == 'CSR_SPOC') {
  //     return csrSpoc['status'] == 'Pending';
  //   } else if (userRole == 'Reviewer') {
  //     return reviewer['status'] == 'Pending';
  //   }
  //   return false;
  // }

  // void _viewDocument(String docKey, String documentName) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text(documentName),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Container(
  //             height: 300,
  //             width: 400,
  //             decoration: BoxDecoration(
  //               border: Border.all(color: Colors.grey),
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             child: const Center(
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Icon(Icons.description, size: 64, color: Colors.grey),
  //                   SizedBox(height: 16),
  //                   Text('Document Preview'),
  //                   SizedBox(height: 8),
  //                   Text(
  //                     'Implement image viewer here using\nImage.network() or similar',
  //                     textAlign: TextAlign.center,
  //                     style: TextStyle(fontSize: 12, color: Colors.grey),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Close'),
  //         ),
  //         ElevatedButton.icon(
  //           onPressed: () {
  //             // Implement download functionality
  //             UtilsWidgets.showToastFunc(
  //                 'Download functionality to be implemented');
  //           },
  //           icon: const Icon(Icons.download),
  //           label: const Text('Download'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // void _approveDocument(String docKey, String documentName) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Approve Document'),
  //       content: Text('Are you sure you want to approve "$documentName"?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () async {
  //             Navigator.pop(context);
  //             await _updateDocumentStatus(docKey, 'Approved');
  //           },
  //           child: const Text('Approve'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // void _rejectDocument(String docKey, String documentName) {
  //   final TextEditingController reasonController = TextEditingController();
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Reject Document'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text('Are you sure you want to reject "$documentName"?'),
  //           const SizedBox(height: 16),
  //           TextField(
  //             controller: reasonController,
  //             decoration: const InputDecoration(
  //               labelText: 'Reason for rejection',
  //               border: OutlineInputBorder(),
  //             ),
  //             maxLines: 3,
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         ElevatedButton(
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  //           onPressed: () async {
  //             Navigator.pop(context);
  //             await _updateDocumentStatus(
  //               docKey,
  //               'Rejected',
  //               reason: reasonController.text,
  //             );
  //           },
  //           child: const Text('Reject'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Future<void> getUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id') ?? '';
      userRole = prefs.getString('role') ?? '';
    });
    await fetchVendorData();
  }

  Future<void> fetchVendorData() async {
    try {
      Map<String, dynamic> vendorData = {
        "type": "Vendor",
        "status": true,
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
            "CSR_SPOC": {
              "status": "Pending",
              "approved_by": "",
              "approved_at": ""
            },
            "Reviewer": {
              "status": "Pending",
              "approved_by": "",
              "approved_at": ""
            }
          },
          "document_2": {
            "name": "12A & 80G Certification (for tax exemption in India)",
            "CSR_SPOC": {
              "status": "Pending",
              "approved_by": "",
              "approved_at": ""
            },
            "Reviewer": {
              "status": "Pending",
              "approved_by": "",
              "approved_at": ""
            }
          },
          "document_3": {
            "name": "FCRA Registration (if foreign funds are involved)",
            "CSR_SPOC": {
              "status": "Pending",
              "approved_by": "",
              "approved_at": ""
            },
            "Reviewer": {
              "status": "Pending",
              "approved_by": "",
              "approved_at": ""
            }
          },
          "document_4": {
            "name": "PAN Card & TAN",
            "CSR_SPOC": {
              "status": "Pending",
              "approved_by": "",
              "approved_at": ""
            },
            "Reviewer": {
              "status": "Pending",
              "approved_by": "",
              "approved_at": ""
            }
          },
          "document_5": {
            "name": "CSR-1",
            "CSR_SPOC": {
              "status": "Pending",
              "approved_by": "",
              "approved_at": ""
            },
            "Reviewer": {
              "status": "Pending",
              "approved_by": "",
              "approved_at": ""
            }
          },
          "document_6": {
            "name": "NGO Darpan certificate",
            "CSR_SPOC": {
              "status": "Pending",
              "approved_by": "",
              "approved_at": ""
            },
            "Reviewer": {
              "status": "Pending",
              "approved_by": "",
              "approved_at": ""
            }
          },
          "document_7": {
            "name": "Audited Financial Statement of last three years",
            "CSR_SPOC": {
              "status": "Pending",
              "approved_by": "",
              "approved_at": ""
            },
            "Reviewer": {
              "status": "Pending",
              "approved_by": "",
              "approved_at": ""
            }
          },
          "document_8": {
            "name": "Latest Annual Report",
            "CSR_SPOC": {
              "status": "Pending",
              "approved_by": "",
              "approved_at": ""
            },
            "Reviewer": {
              "status": "Pending",
              "approved_by": "",
              "approved_at": ""
            }
          },
          "document_9": {
            "name": "Income Tax return for last three years",
            "CSR_SPOC": {
              "status": "Pending",
              "approved_by": "",
              "approved_at": ""
            },
            "Reviewer": {
              "status": "Pending",
              "approved_by": "",
              "approved_at": ""
            }
          },
          "document_10": {
            "name": "List of donors/partners",
            "CSR_SPOC": {
              "status": "Pending",
              "approved_by": "",
              "approved_at": ""
            },
            "Reviewer": {
              "status": "Pending",
              "approved_by": "",
              "approved_at": ""
            }
          },
        }
      };

      data = DueDiligenceModel.fromJson(vendorData);

      // String uri = Constants.MASTER_URL + '/vendor';
      // Map params = {"action": "get", "vendor_code": userId};

      // Map tempMap = await MethodUtils.apiCall(uri, params);
      // setState(() {
      //   if (tempMap['isValid']) {
      //     vendorData = tempMap['info'];
      //   }
      // });
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
        "vendor_code": userId,
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
        await fetchVendorData(); // Refresh data
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
