import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/models/district_model.dart';
import 'package:sterlite_csr/models/state_model.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/function_utils.dart';
import 'package:sterlite_csr/utilities/method_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:sterlite_csr/models/village_model.dart';
import 'package:sterlite_csr/utilities/widget_decoration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sterlite_csr/screens/master/village/village_edit.dart';
import 'package:sterlite_csr/utilities/utils/search-dropdown_utils.dart';

class VillageList extends StatefulWidget {
  const VillageList({super.key});

  @override
  _VillageListState createState() => _VillageListState();
}

class _VillageListState extends State<VillageList> {
  APIController apiController = Get.put(APIController());
  bool isFind = false;
  String msg = 'Please Select...';
  String userRole = "";

  List<VillageModel> _villages = [];
  String selectedState = "";
  List<StateModel> stateOptions = [];
  String selectedDistrict = "";
  List<DistrictModel> districtOptions = [];
  TextEditingController _searchController = TextEditingController();
  List<VillageModel> _filteredvillage = [];
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
      _filtervillage();
    });
  }

  void _onMobileSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredvillage = List.from(_villages); // restore all data
      } else {
        _filteredvillage = _villages.where((e) {
          final name = e.name.toLowerCase();
          final code = e.state_code.toLowerCase();
          return name.contains(query) || code.contains(query);
        }).toList();
      }
    });
  }

  void _filtervillage() {
    if (_searchQuery.isEmpty) {
      _filteredvillage = List.from(_villages);
    } else {
      _filteredvillage = _villages.where((States) {
        return States.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            States.village_code
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }
    _sortstates();
  }

  void _sortstates() {
    _filteredvillage.sort((a, b) {
      var aValue;
      var bValue;

      switch (_sortColumnIndex) {
        case 0: // Salary
          aValue = a.status;
          bValue = b.status;
          break;
        case 1: // Name
          aValue = a.name;
          bValue = b.name;
          break;
        case 2: // Department
          aValue = a.village_code;
          bValue = b.village_code;
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isDesktop = constraints.maxWidth < 600;
      return Scaffold(
        appBar: UtilsWidgets.buildAppBar('Village Database', Get.isDarkMode,
            subtitle: 'Manage your village efficiently',
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
                      builder: (context) => const EditVillage(),
                    ),
                  );
                },
                label: Text('Add Village',
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
                  Row(
                    children: [
                      Flexible(
                        child: SearchDropdownUtils.buildSearchableDropdown(
                          items:
                              stateOptions.map((state) => state.name).toList(),
                          value: selectedState,
                          label: "State",
                          icon: Icons.map,
                          hint: "Select state",
                          onChanged: (value) async {
                            if (value != null) {
                              setState(() {
                                selectedState = value;
                                selectedDistrict = "";
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
                        child:
                            SearchDropdownUtils.buildSearchableDropdown<String>(
                          items: districtOptions
                              .map((District) => District.name)
                              .toList(),
                          value: selectedDistrict,
                          label: "District",
                          icon: Icons.location_city,
                          hint: "Select District",
                          onChanged: (value) async {
                            if (value != null) {
                              setState(() {
                                selectedDistrict = value;
                                _villages.clear();
                                _filteredvillage.clear();
                              });
                            }
                            await getVillageInfo();
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
                      : _filteredvillage.isEmpty
                          ? Center(
                              child: DecorationWidgets.filterTextStyle(msg))
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Total: ${_filteredvillage.length} villages',
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
                                                            BorderRadius
                                                                .circular(8),
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
                                                        suffixIcon: _searchQuery
                                                                .isNotEmpty
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
                                                    dropdownColor:
                                                        Get.isDarkMode
                                                            ? Colors.black
                                                            : Colors.white,
                                                    value: _rowsPerPage,
                                                    items: const [
                                                      DropdownMenuItem(
                                                          value: 5,
                                                          child: Text(
                                                              '5 per page')),
                                                      DropdownMenuItem(
                                                          value: 10,
                                                          child: Text(
                                                              '10 per page')),
                                                      DropdownMenuItem(
                                                          value: 15,
                                                          child: Text(
                                                              '15 per page')),
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
          msg = 'Select a state and District to view village';
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
          msg = 'Select a District to view village';
        } else {
          msg = tempMap['message'];
        }
      });
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  Future getVillageInfo() async {
    setState(() {
      _villages.clear();
    });
    try {
      String uri = Constants.MASTER_URL + '/village';
      Map params = {
        "action": "list",
        "state_code": stateOptions
            .firstWhere((element) => element.name == selectedState)
            .state_code,
        "district_code": districtOptions
            .firstWhere((element) => element.name == selectedDistrict)
            .district_code,
      };

      print(params);

      Map<String, dynamic> tempMap = await apiController.fetchData(uri, params);
      isFind = tempMap['isValid'];
      setState(() {
        if (isFind) {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            _villages.add(VillageModel.fromJson(item));
          }

          _filteredvillage = List.from(_villages);
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

  Future fetchVillageInfo(String village_code) async {
    try {
      String uri = Constants.MASTER_URL + '/village';
      Map params = {"action": "get", 'village_code': village_code};

      Map<String, dynamic> tempMap = await MethodUtils.apiCall(uri, params);

      setState(() {
        if (tempMap['isValid']) {
          VillageModel villageData = VillageModel.fromJson(tempMap['info']);
          _villages
              .removeWhere((element) => element.village_code == village_code);
          _villages.add(villageData);
          _filteredvillage
              .removeWhere((element) => element.village_code == village_code);
          _filteredvillage.add(villageData);
        } else {
          String msg = tempMap['message'] ?? "Failed to load village data";
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
          source: _villagesDataSource(
            context,
            _filteredvillage,
            onEditPressed: (Villages) async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      EditVillage(isEdit: true, village: Villages),
                ),
              );
              if (result == true) {
                await fetchVillageInfo(Villages.village_code);
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
              hintText: 'Search by name or village code',
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
                          _villages.sort((a, b) =>
                              Utils.compareString(ascending, a.name, b.name));
                          setState(() {
                            _sortAscending = ascending;
                          });
                        },
                      ),
                      DataColumn(label: Text('District Code')),
                      DataColumn(label: Text('Edit')),
                    ],
                    _filteredvillage
                        .map((e) => DataRow(cells: [
                              DataCell(Text(e.name)),
                              DataCell(Text(e.village_code)),
                              DataCell(IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  final result = await Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) => EditVillage(
                                              isEdit: true, village: e)));
                                  if (result == true) {
                                    await fetchVillageInfo(e.village_code);
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

class _villagesDataSource extends DataTableSource {
  final BuildContext context;
  final List<VillageModel> villages;
  final Function(VillageModel) onEditPressed;

  _villagesDataSource(this.context, this.villages,
      {required this.onEditPressed});

  @override
  DataRow? getRow(int index) {
    if (index >= villages.length) {
      return null;
    }
    final Villages = villages[index];
    String status = Villages.status ? 'Active' : 'Inactive';
    return DataRow(
      cells: [
        DataCell(Text(Villages.name)),
        DataCell(Text(Villages.village_code)),
        DataCell(DecorationWidgets.buildStatusTag(context, status)),
        DataCell(
          IconButton(
            icon: const Icon(Icons.edit, size: 16),
            visualDensity: VisualDensity.compact,
            onPressed: () => onEditPressed(Villages),
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
  int get rowCount => villages.length;

  @override
  int get selectedRowCount => 0;
}
