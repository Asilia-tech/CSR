import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/models/associate_model.dart';
import 'package:sterlite_csr/models/indicator_model.dart';
import 'package:sterlite_csr/models/project_model.dart';
import 'package:sterlite_csr/screens/master/indicator/indicator_edit.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/function_utils.dart';
import 'package:sterlite_csr/utilities/method_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:sterlite_csr/utilities/widget_decoration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sterlite_csr/utilities/utils/search-dropdown_utils.dart';

class IndicatorList extends StatefulWidget {
  const IndicatorList({super.key});

  @override
  _IndicatorListState createState() => _IndicatorListState();
}

class _IndicatorListState extends State<IndicatorList> {
  APIController apiController = Get.put(APIController());
  bool isFind = false;
  String msg = 'Please wait...';
  String userRole = "";

  String selectedProject = "";
  List<ProjectModel> projectOptions = [];
  String selectedAssociate = "";
  List<AssociateModel> associateOptions = [];

  final TextEditingController _searchController = TextEditingController();

  List<IndicatorModel> _indicators = [];
  List<IndicatorModel> _filteredindicator = [];

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
      _filterindicators();
    });
  }

  void _onMobileSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredindicator = List.from(_indicators); // restore all data
      } else {
        _filteredindicator = _indicators.where((e) {
          final name = e.indicator_name.toLowerCase();
          final code = e.project_name.toLowerCase();
          return name.contains(query) || code.contains(query);
        }).toList();
      }
    });
  }

  void _filterindicators() {
    if (_searchQuery.isEmpty) {
      _filteredindicator = List.from(_indicators);
    } else {
      _filteredindicator = _indicators.where((Indicators) {
        return Indicators.indicator_name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            Indicators.project_name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }
    _sortindicators();
  }

  void _sortindicators() {
    _filteredindicator.sort((a, b) {
      var aValue;
      var bValue;

      switch (_sortColumnIndex) {
        case 0: // ID
          aValue = a.indicator_name;
          bValue = b.indicator_name;
          break;
        case 1: // Name
          aValue = a.project_name;
          bValue = b.project_name;
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
        appBar: UtilsWidgets.buildAppBar('Indicator Database', Get.isDarkMode,
            subtitle: 'Manage your indicator efficiently',
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
                      builder: (context) => const EditIndicator(),
                    ),
                  );
                },
                label: Text('Add indicator',
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
                          associateOptions.clear();
                        });
                      }
                      await getAssociateInfo();
                    },
                    displayTextFn: (item) => item,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please select a project";
                      }
                    },
                  ),
                ),
                SizedBox(width: 16),
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
                          _indicators.clear();
                          _filteredindicator.clear();
                        });
                      }
                      await getIndicatorInfo();
                    },
                    displayTextFn: (item) => item,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please select a associate project";
                      }
                    },
                  ),
                ),
              ],
            ),
            !isFind
                ? Center(child: DecorationWidgets.filterTextStyle(msg))
                : _filteredindicator.isEmpty
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
                                        'Total: ${_filteredindicator.length} indicators',
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
      setState(() {
        isFind = tempMap['isValid'];
        if (isFind) {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            projectOptions.add(ProjectModel.fromJson(item));
          }
          msg = 'Select a project and associate project to view indicators';
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
          msg = 'Select a city to view indicators';
        } else {
          msg = tempMap['message'];
        }
      });
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  Future getIndicatorInfo() async {
    setState(() {
      _indicators.clear();
    });
    try {
      String uri = Constants.OPERATION_URL + '/beneficiary-indicator';
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
          print(tempMap);
          List tempList = tempMap['info'];
          for (var item in tempList) {
            _indicators.add(IndicatorModel.fromJson(item));
          }
          _filteredindicator = List.from(_indicators);
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

  Future fetchIndicatorInfo(String indicator_code) async {
    try {
      String uri = Constants.OPERATION_URL + '/beneficiary-indicator';
      Map params = {"action": "get", 'indicator_code': indicator_code};

      Map<String, dynamic> tempMap = await MethodUtils.apiCall(uri, params);

      setState(() {
        if (tempMap['isValid']) {
          IndicatorModel indicatorData =
              IndicatorModel.fromJson(tempMap['info']);
          _indicators.removeWhere(
              (element) => element.indicator_code == indicator_code);
          _indicators.add(indicatorData);
          _filteredindicator.removeWhere(
              (element) => element.indicator_code == indicator_code);
          _filteredindicator.add(indicatorData);
        } else {
          String msg = tempMap['message'] ?? "Failed to load indicator data";
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
                  _sortindicators();
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
                  _sortindicators();
                });
              },
            ),
            DataColumn(
              label: const Text('Reviewer Status',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              onSort: (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                  _sortindicators();
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
          source: _indicatorsDataSource(
            context,
            _filteredindicator,
            onEditPressed: (Indicator) async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      EditIndicator(isEdit: true, indicator: Indicator),
                ),
              );
              if (result == true) {
                await fetchIndicatorInfo(Indicator.indicator_code);
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
              hintText: 'Search by name or indicator code',
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
                          _indicators.sort((a, b) => Utils.compareString(
                              ascending, a.indicator_code, b.indicator_code));
                          setState(() {
                            _sortAscending = ascending;
                          });
                        },
                      ),
                      DataColumn(label: Text('Indicator Code')),
                      DataColumn(label: Text('Reviewer Status')),
                      DataColumn(label: Text('Edit')),
                    ],
                    _filteredindicator
                        .map((e) => DataRow(cells: [
                              DataCell(Text(e.indicator_name)),
                              DataCell(Text(e.indicator_code)),
                              DataCell(Text(e.reviewer_status['status'])),
                              DataCell(IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () async {
                                  final result = await Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) => EditIndicator(
                                              isEdit: true, indicator: e)));
                                  if (result == true) {
                                    await fetchIndicatorInfo(e.indicator_code);
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

class _indicatorsDataSource extends DataTableSource {
  final BuildContext context;
  final List<IndicatorModel> indicators;
  final Function(IndicatorModel) onEditPressed;

  _indicatorsDataSource(this.context, this.indicators,
      {required this.onEditPressed});

  @override
  DataRow? getRow(int index) {
    if (index >= indicators.length) {
      return null;
    }
    final Indicator = indicators[index];
    String status = Indicator.reviewer_status['status'];
    return DataRow(
      cells: [
        DataCell(Text(Indicator.indicator_name)),
        DataCell(Text(Indicator.indicator_code)),
        DataCell(DecorationWidgets.buildStatusTag(context, status)),
        DataCell(
          IconButton(
            icon: const Icon(Icons.edit, size: 16),
            visualDensity: VisualDensity.compact,
            onPressed: () => onEditPressed(Indicator),
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
  int get rowCount => indicators.length;

  @override
  int get selectedRowCount => 0;
}
