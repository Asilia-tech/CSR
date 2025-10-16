import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/models/state_model.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/function_utils.dart';
import 'package:sterlite_csr/utilities/method_utils.dart';
import 'package:sterlite_csr/utilities/widget_decoration.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:sterlite_csr/screens/master/state/state_edit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StateList extends StatefulWidget {
  const StateList({super.key});

  @override
  _StateListState createState() => _StateListState();
}

class _StateListState extends State<StateList> {
  APIController apiController = Get.put(APIController());
  bool isFind = false;
  String msg = 'Please wait...';
  String userRole = "";

  TextEditingController _searchController = TextEditingController();
  List<StateModel> _states = [];
  List<StateModel> _filteredstates = [];
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
      _filterstates();
    });
  }

  void _onMobileSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredstates = List.from(_states); // restore all data
      } else {
        _filteredstates = _states.where((e) {
          final name = e.name.toLowerCase();
          final code = e.state_code.toLowerCase();
          return name.contains(query) || code.contains(query);
        }).toList();
      }
    });
  }

  void _filterstates() {
    if (_searchQuery.isEmpty) {
      _filteredstates = List.from(_states);
    } else {
      _filteredstates = _states.where((States) {
        return States.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            States.state_code
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }
    _sortstates();
  }

  void _sortstates() {
    if (_sortColumnIndex != -1) {
      _filteredstates.sort((a, b) {
        var aValue;
        var bValue;

        switch (_sortColumnIndex) {
          case 0: // Name
            aValue = a.name;
            bValue = b.name;
            break;
          case 1: // Department
            aValue = a.state_code;
            bValue = b.state_code;
            break;
          case 2: // Salary
            aValue = a.status;
            bValue = b.status;
            break;
          default:
            aValue = a.name;
            bValue = b.name;
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
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isDesktop = constraints.maxWidth < 600;
      return Scaffold(
        appBar: UtilsWidgets.buildAppBar('States Database', Get.isDarkMode,
            subtitle: 'Manage your states efficiently',
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
                    MaterialPageRoute(builder: (context) => EditState()),
                  );
                  if (result != null) {
                    await fetchStateInfo(result);
                  }
                },
                label: Text('Add State',
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
                                          'Total: ${_filteredstates.length} states',
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
                                                    'Search by name, code ...',
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
    await getStateInfo();
  }

  Future getStateInfo() async {
    setState(() {
      _states.clear();
    });
    try {
      String uri = Constants.MASTER_URL + '/state';
      Map params = {"action": "list"};
      Map<String, dynamic> tempMap = await apiController.fetchData(uri, params);
      setState(() {
        isFind = tempMap['isValid'];
        if (isFind) {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            _states.add(StateModel.fromJson(item));
          }
          _filteredstates = List.from(_states);
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

  Future fetchStateInfo(String state_code) async {
    try {
      String uri = Constants.MASTER_URL + '/state';
      Map params = {"action": "get", 'state_code': state_code};

      Map<String, dynamic> tempMap = await MethodUtils.apiCall(uri, params);

      setState(() {
        if (tempMap['isValid']) {
          StateModel stateData = StateModel.fromJson(tempMap['info']);
          _states.removeWhere((element) => element.state_code == state_code);
          _states.add(stateData);
          _filteredstates
              .removeWhere((element) => element.state_code == state_code);
          _filteredstates.add(stateData);
        } else {
          String msg = tempMap['message'] ?? "Failed to load state data";
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
                  _sortstates();
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
                  _sortstates();
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
                  _sortstates();
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
          source: _StatesDataSource(
            context,
            _filteredstates,
            onEditPressed: (States) async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditState(isEdit: true, states: States),
                ),
              );
              if (result == true) {
                await fetchStateInfo(States.state_code);
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
              hintText: 'Search by name or state code',
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
                                _states.sort((a, b) => Utils.compareString(
                                    ascending, a.name, b.name));
                                setState(() {
                                  _sortAscending = ascending;
                                });
                              },
                            ),
                            DataColumn(label: Text('State Code')),
                            DataColumn(label: Text('Edit')),
                          ],
                          _filteredstates
                              .map((e) => DataRow(cells: [
                                    DataCell(Text(e.name)),
                                    DataCell(Text(e.state_code)),
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
                                                        EditState(
                                                            isEdit: true,
                                                            states: e)));
                                        if (result == true) {
                                          await fetchStateInfo(e.state_code);
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

class _StatesDataSource extends DataTableSource {
  final BuildContext context;
  final List<StateModel> states;
  final Function(StateModel) onEditPressed;

  _StatesDataSource(this.context, this.states, {required this.onEditPressed});

  @override
  DataRow? getRow(int index) {
    if (index >= states.length) {
      return null;
    }
    final States = states[index];
    String status = States.status ? 'Active' : 'Inactive';
    return DataRow(
      cells: [
        DataCell(Text(States.name)),
        DataCell(Text(States.state_code)),
        DataCell(DecorationWidgets.buildStatusTag(context, status)),
        DataCell(IconButton(
            icon: const Icon(Icons.edit, size: 16),
            visualDensity: VisualDensity.compact,
            onPressed: () => onEditPressed(States),
            tooltip: 'Edit',
            color: Colors.blue)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => states.length;

  @override
  int get selectedRowCount => 0;
}
