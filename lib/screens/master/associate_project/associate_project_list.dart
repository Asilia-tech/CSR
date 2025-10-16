import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/models/district_model.dart';
import 'package:sterlite_csr/models/associate_model.dart';
import 'package:sterlite_csr/models/state_model.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/function_utils.dart';
import 'package:sterlite_csr/utilities/method_utils.dart';
import 'package:sterlite_csr/utilities/utils/search-dropdown_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:sterlite_csr/utilities/widget_decoration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sterlite_csr/screens/master/associate_project/associate_project_edit.dart';

class AssociateProjectList extends StatefulWidget {
  const AssociateProjectList({super.key});

  @override
  _AssociateProjectListState createState() => _AssociateProjectListState();
}

class _AssociateProjectListState extends State<AssociateProjectList> {
  APIController apiController = Get.put(APIController());
  bool isFind = false;
  String msg = 'Please wait...';
  String userRole = "";

  String selectedState = "";
  List<StateModel> stateOptions = [];
  String selectedDistrict = "";
  List<DistrictModel> districtOptions = [];
  final TextEditingController _searchController = TextEditingController();
  List<AssociateModel> _associate_projects = [];
  List<AssociateModel> _filteredassociate_project = [];
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
      _filterassociate_projects();
    });
  }

  void _onMobileSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredassociate_project =
            List.from(_associate_projects); // restore all data
      } else {
        _filteredassociate_project = _associate_projects.where((e) {
          final name = e.associate_project_name.toLowerCase();
          final code = e.associate_project_code.toLowerCase();
          return name.contains(query) || code.contains(query);
        }).toList();
      }
    });
  }

  void _filterassociate_projects() {
    if (_searchQuery.isEmpty) {
      _filteredassociate_project = List.from(_associate_projects);
    } else {
      _filteredassociate_project = _associate_projects.where((States) {
        return States.associate_project_name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            States.associate_project_code
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }
    _sortassociate_projects();
  }

  void _sortassociate_projects() {
    _filteredassociate_project.sort((a, b) {
      var aValue;
      var bValue;

      switch (_sortColumnIndex) {
        case 0: // ID
          aValue = a.associate_project_code;
          bValue = b.associate_project_code;
          break;
        case 1: // Name
          aValue = a.associate_project_name;
          bValue = b.associate_project_name;
          break;
        case 2: // Salary
          aValue = a.status;
          bValue = b.status;
          break;
        default:
          aValue = a.associate_project_name;
          bValue = b.associate_project_name;
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
        appBar: UtilsWidgets.buildAppBar(
            'Associate Project Database', Get.isDarkMode,
            subtitle: 'Manage your associate project efficiently',
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
                      builder: (context) => const EditAssociate(),
                    ),
                  );
                },
                label: Text('Add associate_project',
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
                    items: stateOptions.map((state) => state.name).toList(),
                    value: selectedState,
                    label: "State",
                    icon: Icons.map,
                    hint: "Select state",
                    onChanged: (value) async {
                      if (value != null) {
                        setState(() {
                          selectedState = value;
                          selectedDistrict = '';
                          districtOptions.clear();
                        });
                      }
                      await getDistrictInfo();
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
                SizedBox(width: 16),
                Flexible(
                  child: SearchDropdownUtils.buildSearchableDropdown<String>(
                    items: districtOptions.map((city) => city.name).toList(),
                    value: selectedDistrict,
                    label: "District",
                    icon: Icons.location_city,
                    hint: "Select city",
                    onChanged: (value) async {
                      if (value != null) {
                        setState(() {
                          selectedDistrict = value;
                          _associate_projects.clear();
                          _filteredassociate_project.clear();
                        });
                      }
                      await getAssociateProjectInfo();
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
            !isFind
                ? Center(child: DecorationWidgets.filterTextStyle(msg))
                : _filteredassociate_project.isEmpty
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
                                        'Total: ${_filteredassociate_project.length} associate_projects',
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
    await getStateInfo();
  }

  Future getStateInfo() async {
    setState(() {
      stateOptions.clear();
    });
    try {
      String uri = Constants.MASTER_URL + '/state';
      Map params = {"action": "list"};
      Map tempMap = await MethodUtils.apiCall(uri, params);
      setState(() {
        isFind = tempMap['isValid'];
        if (isFind) {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            stateOptions.add(StateModel.fromJson(item));
          }
          msg = 'Select a state and city to view associate_projects';
        } else {
          msg = tempMap['message'];
        }
      });
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
      setState(() {
        isFind = tempMap['isValid'];
        if (isFind) {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            districtOptions.add(DistrictModel.fromJson(item));
          }
          msg = 'Select a city to view associate_projects';
        } else {
          msg = tempMap['message'];
        }
      });
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  Future getAssociateProjectInfo() async {
    setState(() {
      _associate_projects.clear();
    });
    try {
      String uri = Constants.MASTER_URL + '/associate_project';
      Map params = {
        "action": "list",
        "state_code": stateOptions
            .firstWhere((element) => element.name == selectedState)
            .state_code,
        "district_code": districtOptions
            .firstWhere((element) => element.name == selectedDistrict)
            .district_code,
      };
      Map<String, dynamic> tempMap = await apiController.fetchData(uri, params);
      setState(() {
        isFind = tempMap['isValid'];
        if (isFind) {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            _associate_projects.add(AssociateModel.fromJson(item));
          }
          _filteredassociate_project = List.from(_associate_projects);
          _searchController.addListener(_onDesktopSearchChanged);
          _searchController.addListener(_onMobileSearchChanged);
        } else {
          msg = tempMap['message'];
        }
      });
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  Future fetchAssociateProjectInfo(String associate_project_code) async {
    try {
      String uri = Constants.MASTER_URL + '/associate_project';
      Map params = {
        "action": "get",
        'associate_project_code': associate_project_code
      };

      Map<String, dynamic> tempMap = await MethodUtils.apiCall(uri, params);

      setState(() {
        if (tempMap['isValid']) {
          AssociateModel associate_projectData =
              AssociateModel.fromJson(tempMap['info']);
          _associate_projects.removeWhere((element) =>
              element.associate_project_code == associate_project_code);
          _associate_projects.add(associate_projectData);
          _filteredassociate_project.removeWhere((element) =>
              element.associate_project_code == associate_project_code);
          _filteredassociate_project.add(associate_projectData);
        } else {
          String msg =
              tempMap['message'] ?? "Failed to load associate_project data";
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
                  _sortassociate_projects();
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
                  _sortassociate_projects();
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
                  _sortassociate_projects();
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
          source: _associate_projectsDataSource(
            context,
            _filteredassociate_project,
            onEditPressed: (AssociateProject) async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditAssociate(
                      isEdit: true, associate_project: AssociateProject),
                ),
              );
              if (result == true) {
                await fetchAssociateProjectInfo(
                    AssociateProject.associate_project_code);
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
              hintText: 'Search by name or associate_project code',
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
                          _associate_projects.sort((a, b) =>
                              Utils.compareString(
                                  ascending,
                                  a.associate_project_name,
                                  b.associate_project_name));
                          setState(() {
                            _sortAscending = ascending;
                          });
                        },
                      ),
                      DataColumn(label: Text('AssociateProject Code')),
                      DataColumn(label: Text('Edit')),
                    ],
                    _filteredassociate_project
                        .map((e) => DataRow(cells: [
                              DataCell(Text(e.associate_project_name)),
                              DataCell(Text(e.associate_project_code)),
                              DataCell(IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () async {
                                  final result = await Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) => EditAssociate(
                                              isEdit: true,
                                              associate_project: e)));
                                  if (result == true) {
                                    await fetchAssociateProjectInfo(
                                        e.associate_project_code);
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

class _associate_projectsDataSource extends DataTableSource {
  final BuildContext context;
  final List<AssociateModel> associate_projects;
  final Function(AssociateModel) onEditPressed;

  _associate_projectsDataSource(this.context, this.associate_projects,
      {required this.onEditPressed});

  @override
  DataRow? getRow(int index) {
    if (index >= associate_projects.length) {
      return null;
    }
    final AssociateProject = associate_projects[index];
    String status = AssociateProject.status ? 'Active' : 'Inactive';
    return DataRow(
      cells: [
        DataCell(Text(AssociateProject.associate_project_name)),
        DataCell(Text(AssociateProject.associate_project_code)),
        DataCell(DecorationWidgets.buildStatusTag(context, status)),
        DataCell(
          IconButton(
            icon: const Icon(Icons.edit, size: 16),
            visualDensity: VisualDensity.compact,
            onPressed: () => onEditPressed(AssociateProject),
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
  int get rowCount => associate_projects.length;

  @override
  int get selectedRowCount => 0;
}
