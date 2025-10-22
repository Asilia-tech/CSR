import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/models/associate_model.dart';
import 'package:sterlite_csr/models/project_model.dart';
import 'package:sterlite_csr/models/vendor_model.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/function_utils.dart';
import 'package:sterlite_csr/utilities/method_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:sterlite_csr/utilities/widget_decoration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sterlite_csr/screens/master/vendor/vendor_edit.dart';
import 'package:sterlite_csr/utilities/utils/search-dropdown_utils.dart';

class VendorList extends StatefulWidget {
  const VendorList({super.key});

  @override
  _VendorListState createState() => _VendorListState();
}

class _VendorListState extends State<VendorList> {
  APIController apiController = Get.put(APIController());
  bool isFind = false;
  String msg = 'Please wait...';
  String userRole = "";

  String selectedProject = "";
  List<ProjectModel> projectOptions = [];

  String selectedAssociatedProject = "";
  List<AssociateModel> associatedProjectOptions = [];

  final TextEditingController _searchController = TextEditingController();
  List<VendorModel> _vendors = [];
  List<VendorModel> _filteredvendor = [];
  String _searchQuery = '';
  int _rowsPerPage = 5;
  int _sortColumnIndex = 1;
  bool _sortAscending = true;

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onDesktopSearchChanged);
    _searchController.removeListener(_onMobileSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onDesktopSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filtervendors();
    });
  }

  void _onMobileSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredvendor = List.from(_vendors); // restore all data
      } else {
        _filteredvendor = _vendors.where((e) {
          final name = e.vendor_name.toLowerCase();
          final code = e.vendor_code.toLowerCase();
          return name.contains(query) || code.contains(query);
        }).toList();
      }
    });
  }

  void _filtervendors() {
    if (_searchQuery.isEmpty) {
      _filteredvendor = List.from(_vendors);
    } else {
      _filteredvendor = _vendors.where((States) {
        return States.vendor_name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            States.vendor_code
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }
    _sortvendors();
  }

  void _sortvendors() {
    _filteredvendor.sort((a, b) {
      var aValue;
      var bValue;

      switch (_sortColumnIndex) {
        case 0: // ID
          aValue = a.vendor_code;
          bValue = b.vendor_code;
          break;
        case 1: // Name
          aValue = a.vendor_name;
          bValue = b.vendor_name;
          break;
        case 2: // Salary
          aValue = a.status;
          bValue = b.status;
          break;
        default:
          aValue = a.vendor_name;
          bValue = b.vendor_name;
      }

      int comparison;
      if (aValue is String && bValue is String) {
        comparison = aValue.compareTo(bValue);
      } else if (aValue is num && bValue is num) {
        comparison = aValue.compareTo(bValue);
      } else {
        comparison = aValue.toString().compareTo(bValue.toString());
      }

      return _sortAscending ? comparison : -comparison;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isDesktop = constraints.maxWidth < 600;
      return Scaffold(
        appBar: UtilsWidgets.buildAppBar('Vendor/NGO Database', Get.isDarkMode,
            subtitle: 'Manage your vendor/NGO efficiently',
            leading: !isDesktop
                ? null
                : Container(
                    margin: const EdgeInsets.only(left: 15, bottom: 25),
                    child: IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/home');
                        },
                        icon: const Icon(Icons.arrow_back_ios)),
                  ),
            Widgets: [
              TextButton.icon(
                icon: Icon(Icons.add,
                    size: 16,
                    color:
                        Get.isDarkMode ? Colors.white : Constants.primaryColor),
                onPressed: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const EditVendor(),
                    ),
                  );
                },
                label: Text('Add vendor/NGO',
                    style: TextStyle(
                      color: Get.isDarkMode
                          ? Colors.white
                          : Constants.primaryColor,
                      fontWeight: FontWeight.bold,
                    )),
              )
            ]),
        body: Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: SearchDropdownUtils.buildSearchableDropdown(
                    items: projectOptions.map((e) => e.project_name).toList(),
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
                  child: SearchDropdownUtils.buildSearchableDropdown(
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
                        await getVendorInfo();
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
            !isFind
                ? Center(child: DecorationWidgets.filterTextStyle(msg))
                : _filteredvendor.isEmpty
                    ? Center(child: DecorationWidgets.filterTextStyle(msg))
                    : Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: !isDesktop ? 20 : 8,
                            vertical: 16,
                          ),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total: ${_filteredvendor.length} vendors/NGOs',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (!isDesktop)
                                        Row(
                                          children: [
                                            Container(
                                                width: 300,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 10),
                                                decoration: BoxDecoration(
                                                  color: Get.isDarkMode
                                                      ? Colors.black
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child:
                                                    UtilsWidgets.textFormField(
                                                  '',
                                                  'Search by name, code ...',
                                                  (p0) => null,
                                                  _searchController,
                                                  Get.isDarkMode,
                                                  prefixIcon: Icon(
                                                    Icons.search,
                                                    color: Get.isDarkMode
                                                        ? Colors.white
                                                        : Constants.canvasColor,
                                                  ),
                                                  suffixIcon: _searchQuery
                                                          .isNotEmpty
                                                      ? IconButton(
                                                          icon: const Icon(
                                                              Icons.clear,
                                                              color:
                                                                  Colors.grey),
                                                          onPressed: () {
                                                            _searchController
                                                                .clear();
                                                          },
                                                        )
                                                      : null,
                                                )),
                                            DropdownButton<int>(
                                              dropdownColor: Get.isDarkMode
                                                  ? Colors.black
                                                  : Colors.white,
                                              value: _rowsPerPage,
                                              items: const [
                                                DropdownMenuItem(
                                                    value: 5,
                                                    child: Text('5 per page')),
                                                DropdownMenuItem(
                                                    value: 10,
                                                    child: Text('10 per page')),
                                                DropdownMenuItem(
                                                    value: 15,
                                                    child: Text('15 per page')),
                                              ],
                                              onChanged: (value) {
                                                setState(() {
                                                  _rowsPerPage = value!;
                                                });
                                              },
                                              underline: Container(),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: !isDesktop
                                      ? _buildDesktopTable(context)
                                      : _buildMobileTable(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
          ],
        ),
      );
    });
  }

  Future getUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role') ?? '';
    });
    await getProjectInfo();
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
          msg = tempMap['message'] ?? "choose project to continue";
          for (var item in tempList) {
            projectOptions.add(ProjectModel.fromJson(item));
          }
        });
      } else {
        String msg = tempMap['message'] ?? "Failed to load projects";
        UtilsWidgets.showToastFunc(msg);
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
          msg = tempMap['message'] ?? "choose associate project to continue";
          for (var item in tempList) {
            associatedProjectOptions.add(AssociateModel.fromJson(item));
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
        "associate_project_code": associatedProjectOptions
            .firstWhere((element) =>
                element.associate_project_name == selectedAssociatedProject)
            .associate_project_code,
      };

      Map<String, dynamic> tempMap = await apiController.fetchData(uri, params);
      setState(() {
        isFind = tempMap['isValid'];
        if (isFind) {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            _vendors.add(VendorModel.fromJson(item));
          }
          _filteredvendor = List.from(_vendors);
          _searchController.addListener(_onDesktopSearchChanged);
          _searchController.addListener(_onMobileSearchChanged);
        } else {
          msg = tempMap['message'] ?? 'Failed to load vendor data';
        }
      });
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  Future fetchVendorInfo(String vendor_code) async {
    try {
      String uri = Constants.MASTER_URL + '/vendor';
      Map params = {"action": "get", 'vendor_code': vendor_code};

      Map<String, dynamic> tempMap = await MethodUtils.apiCall(uri, params);
      setState(() {
        if (tempMap['isValid']) {
          VendorModel vendorData = VendorModel.fromJson(tempMap['info']);
          _vendors.removeWhere((element) => element.vendor_code == vendor_code);
          _vendors.add(vendorData);
          _filteredvendor
              .removeWhere((element) => element.vendor_code == vendor_code);
          _filteredvendor.add(vendorData);
        } else {
          String msg = tempMap['message'] ?? "Failed to load vendor data";
          UtilsWidgets.showToastFunc(msg);
        }
      });
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  Widget _buildDesktopTable(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: Colors.white,
        dataTableTheme: DataTableThemeData(
          headingRowColor: MaterialStateProperty.all(Constants.primaryColor),
          dataRowColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return Colors.blue[100];
              }
              return states.contains(MaterialState.hovered)
                  ? Colors.blue[50]
                  : null;
            },
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: PaginatedDataTable(
          rowsPerPage: _rowsPerPage,
          showFirstLastButtons: true,
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columns: [
            DataColumn(
              label: const Text('Name',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              onSort: (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                  _sortvendors();
                });
              },
            ),
            DataColumn(
              label: const Text('Code',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              onSort: (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                  _sortvendors();
                });
              },
            ),
            DataColumn(
              label: const Text('Status',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              onSort: (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                  _sortvendors();
                });
              },
              numeric: true,
            ),
            const DataColumn(
              label: Text('Actions',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
          source: _vendorsDataSource(
            context,
            _filteredvendor,
            onEditPressed: (Vendor) async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      EditVendor(isEdit: true, vendor: Vendor),
                ),
              );
              if (result == true) {
                await fetchVendorInfo(Vendor.vendor_code);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileTable(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search',
              hintText: 'Search by name or vendor code',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Data Section
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: UtilsWidgets.drawTable(
                    [
                      DataColumn(
                        label: Text('Name'),
                        onSort: (columnIndex, ascending) {
                          _vendors.sort((a, b) => Utils.compareString(
                              ascending, a.vendor_name, b.vendor_name));
                          setState(() {
                            _sortAscending = ascending;
                          });
                        },
                      ),
                      DataColumn(label: Text('Vendor Code')),
                      DataColumn(label: Text('Edit')),
                    ],
                    _filteredvendor
                        .map((e) => DataRow(cells: [
                              DataCell(Text(e.vendor_name)),
                              DataCell(Text(e.vendor_code)),
                              DataCell(IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () async {
                                  final result = await Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) => EditVendor(
                                              isEdit: true, vendor: e)));
                                  if (result == true) {
                                    await fetchVendorInfo(e.vendor_code);
                                  }
                                },
                              )),
                            ]))
                        .toList(),
                    isAscending: _sortAscending,
                    sortColumnIndex: _sortColumnIndex,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _vendorsDataSource extends DataTableSource {
  final BuildContext context;
  final List<VendorModel> vendors;
  final Function(VendorModel) onEditPressed;

  _vendorsDataSource(this.context, this.vendors, {required this.onEditPressed});

  @override
  DataRow? getRow(int index) {
    if (index >= vendors.length) {
      return null;
    }
    final Vendor = vendors[index];
    String status = Vendor.status ? 'Active' : 'Inactive';
    return DataRow(
      cells: [
        DataCell(Text(Vendor.vendor_name)),
        DataCell(Text(Vendor.vendor_code)),
        DataCell(DecorationWidgets.buildStatusTag(context, status)),
        DataCell(
          IconButton(
            icon: const Icon(Icons.edit, size: 16),
            visualDensity: VisualDensity.compact,
            onPressed: () => onEditPressed(Vendor),
            tooltip: 'Edit',
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => vendors.length;

  @override
  int get selectedRowCount => 0;
}
