import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/screens/master/project/project_edit.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/function_utils.dart';
import 'package:sterlite_csr/utilities/method_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:sterlite_csr/models/project_model.dart';
import 'package:sterlite_csr/utilities/widget_decoration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectList extends StatefulWidget {
  const ProjectList({super.key});

  @override
  _ProjectListState createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList> {
  APIController apiController = Get.put(APIController());
  bool isFind = false;
  String msg = 'Please wait...';
  String userRole = "";

  List<ProjectModel> _projects = [];
  final TextEditingController _searchController = TextEditingController();
  List<ProjectModel> _filteredproject = [];
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
      _filterprojects();
    });
  }

  void _onMobileSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredproject = List.from(_projects); // restore all data
      } else {
        _filteredproject = _projects.where((e) {
          final project_name = e.project_name.toLowerCase();
          final code = e.project_code.toLowerCase();
          return project_name.contains(query) || code.contains(query);
        }).toList();
      }
    });
  }

  void _filterprojects() {
    if (_searchQuery.isEmpty) {
      _filteredproject = List.from(_projects);
    } else {
      _filteredproject = _projects.where((Projets) {
        return Projets.project_name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            Projets.project_code
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }
    _sortprojects();
  }

  void _sortprojects() {
    _filteredproject.sort((a, b) {
      var aValue;
      var bValue;

      switch (_sortColumnIndex) {
        case 0: // ID
          aValue = a.project_code;
          bValue = b.project_code;
          break;
        case 1:
          aValue = a.status;
          bValue = b.status;
          break;
        default:
          aValue = a.project_name;
          bValue = b.project_name;
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
        appBar: UtilsWidgets.buildAppBar('Project Database', Get.isDarkMode,
            subtitle: 'Manage your project efficiently',
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
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => EditProject()),
                  );
                  if (result != null) {
                    await fetchProjectInfo(result);
                  }
                },
                label: Text('Add Project',
                    style: TextStyle(
                      color: Get.isDarkMode
                          ? Colors.white
                          : Constants.primaryColor,
                      fontWeight: FontWeight.bold,
                    )),
              )
            ]),
        body: apiController.isLoading.value
            ? Center(child: DecorationWidgets.showProgressDialog(context))
            : Column(
                children: [
                  !isFind
                      ? Center(child: DecorationWidgets.msgDecor(context, msg))
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
                                          'Total: ${_filteredproject.length} projects',
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
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                                  decoration: BoxDecoration(
                                                    color: Get.isDarkMode
                                                        ? Colors.black
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: UtilsWidgets
                                                      .textFormField(
                                                    '',
                                                    'Search by project_name, code ...',
                                                    (p0) => null,
                                                    _searchController,
                                                    Get.isDarkMode,
                                                    prefixIcon: Icon(
                                                      Icons.search,
                                                      color: Get.isDarkMode
                                                          ? Colors.white
                                                          : Constants
                                                              .canvasColor,
                                                    ),
                                                    suffixIcon:
                                                        _searchQuery.isNotEmpty
                                                            ? IconButton(
                                                                icon: const Icon(
                                                                    Icons.clear,
                                                                    color: Colors
                                                                        .grey),
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
                                                      child:
                                                          Text('5 per page')),
                                                  DropdownMenuItem(
                                                      value: 10,
                                                      child:
                                                          Text('10 per page')),
                                                  DropdownMenuItem(
                                                      value: 15,
                                                      child:
                                                          Text('15 per page')),
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
      _projects.clear();
    });
    try {
      String uri = Constants.MASTER_URL + '/main-project';
      Map params = {"action": "list"};
      Map<String, dynamic> tempMap = await apiController.fetchData(uri, params);
      setState(() {
        isFind = tempMap['isValid'];
        if (isFind) {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            _projects.add(ProjectModel.fromJson(item));
          }
          _filteredproject = List.from(_projects);
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

  Future fetchProjectInfo(String project_code) async {
    try {
      String uri = Constants.MASTER_URL + '/main-project';
      Map params = {"action": "get", 'project_code': project_code};

      Map<String, dynamic> tempMap = await MethodUtils.apiCall(uri, params);

      setState(() {
        if (tempMap['isValid']) {
          ProjectModel projectData = ProjectModel.fromJson(tempMap['info']);
          _projects
              .removeWhere((element) => element.project_code == project_code);
          _projects.add(projectData);
          _filteredproject
              .removeWhere((element) => element.project_code == project_code);
          _filteredproject.add(projectData);
        } else {
          String msg = tempMap['message'] ?? "Failed to load project data";
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
            (Set<MaterialState> m_sortprojects) {
              if (m_sortprojects.contains(MaterialState.selected)) {
                return Colors.blue[100];
              }
              return m_sortprojects.contains(MaterialState.hovered)
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
                  _sortprojects();
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
                  _sortprojects();
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
                  _sortprojects();
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
          source: _projectsDataSource(
            context,
            _filteredproject,
            onEditPressed: (Project) async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      EditProject(isEdit: true, project: Project),
                ),
              );
              if (result == true) {
                await fetchProjectInfo(Project.project_code);
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
              hintText: 'Search by project_name or project code',
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
                child: !isFind
                    ? Center(child: DecorationWidgets.msgDecor(context, msg))
                    : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: UtilsWidgets.drawTable(
                          [
                            DataColumn(
                              label: Text('Name'),
                              onSort: (columnIndex, ascending) {
                                _projects.sort((a, b) => Utils.compareString(
                                    ascending, a.project_name, b.project_name));
                                setState(() {
                                  _sortAscending = ascending;
                                });
                              },
                            ),
                            DataColumn(label: Text('Project Code')),
                            DataColumn(label: Text('Edit')),
                          ],
                          _filteredproject
                              .map((e) => DataRow(cells: [
                                    DataCell(Text(e.project_name)),
                                    DataCell(Text(e.project_code)),
                                    DataCell(IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () async {
                                        final result =
                                            await Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditProject(
                                                            isEdit: true,
                                                            project: e)));
                                        if (result == true) {
                                          await fetchProjectInfo(
                                              e.project_code);
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

class _projectsDataSource extends DataTableSource {
  final BuildContext context;
  final List<ProjectModel> projects;
  final Function(ProjectModel) onEditPressed;

  _projectsDataSource(this.context, this.projects,
      {required this.onEditPressed});

  @override
  DataRow? getRow(int index) {
    if (index >= projects.length) {
      return null;
    }
    final Project = projects[index];
    String status = Project.status ? 'Active' : 'Inactive';
    return DataRow(
      cells: [
        DataCell(Text(Project.project_name)),
        DataCell(Text(Project.project_code)),
        DataCell(DecorationWidgets.buildStatusTag(context, status)),
        DataCell(
          IconButton(
            icon: const Icon(Icons.edit, size: 16),
            visualDensity: VisualDensity.compact,
            onPressed: () => onEditPressed(Project),
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
  int get rowCount => projects.length;

  @override
  int get selectedRowCount => 0;
}
