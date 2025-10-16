import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/models/financial_model.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/function_utils.dart';
import 'package:sterlite_csr/utilities/method_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:sterlite_csr/models/budget_model.dart';
import 'package:sterlite_csr/utilities/widget_decoration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sterlite_csr/screens/master/budget/budget_edit.dart';
import 'package:sterlite_csr/utilities/utils/search-dropdown_utils.dart';

class BudgetList extends StatefulWidget {
  const BudgetList({super.key});

  @override
  _BudgetListState createState() => _BudgetListState();
}

class _BudgetListState extends State<BudgetList> {
  List<BudgetModel> _budgets = [];
  List<BudgetModel> _filteredbudget = [];
  final TextEditingController _searchController = TextEditingController();
  APIController apiController = Get.put(APIController());
  bool isFind = false;
  String msg = 'Please Select Financial Year';
  String userRole = "";
  String verticalCode = "";
  String _searchQuery = '';
  int _rowsPerPage = 5;
  int _sortColumnIndex = 1;
  bool _sortAscending = true;
  List<FinancialModel> financialOptions = [];
  String selectedFinancial = '';

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
      _filterbudgets();
    });
  }

  void _onMobileSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredbudget = List.from(_budgets); // restore all data
      } else {
        _filteredbudget = _budgets.where((e) {
          final name = e.name.toLowerCase();
          final code = e.budget_code.toLowerCase();
          return name.contains(query) || code.contains(query);
        }).toList();
      }
    });
  }

  void _filterbudgets() {
    if (_searchQuery.isEmpty) {
      _filteredbudget = List.from(_budgets);
    } else {
      _filteredbudget = _budgets.where((States) {
        return States.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            States.budget_code
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }
    _sortbudgets();
  }

  void _sortbudgets() {
    _filteredbudget.sort((a, b) {
      var aValue;
      var bValue;

      switch (_sortColumnIndex) {
        case 0: // ID
          aValue = a.budget_code;
          bValue = b.budget_code;
          break;
        case 1: // Name
          aValue = a.name;
          bValue = b.name;
          break;
        case 3: // Salary
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isDesktop = constraints.maxWidth < 600;
      return Scaffold(
        appBar: UtilsWidgets.buildAppBar('Budget Database', Get.isDarkMode,
            subtitle: 'Manage your budget efficiently',
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
                      builder: (context) => const EditBudget(),
                    ),
                  );
                },
                label: Text('Add Budget',
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
                  SearchDropdownUtils.buildSearchableDropdown<String>(
                    items: financialOptions.map((e) => e.name).toList(),
                    label: 'Financial Year',
                    value: selectedFinancial,
                    icon: Icons.list,
                    hint: 'Choose...',
                    onChanged: (p0) async {
                      setState(() {
                        selectedFinancial = p0!;
                      });
                      await getBudgetInfo();
                    },
                    displayTextFn: (item) => item,
                    validator: (value) =>
                        value == null ? 'Required field' : null,
                    showSearchBox: true,
                  ),
                  !isFind
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
                                          'Total: ${_filteredbudget.length} budgets',
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
      verticalCode = prefs.getString('code') ?? '';
    });
    await getFinancialInfo();
  }

  Future getFinancialInfo() async {
    setState(() {
      financialOptions.clear();
    });
    try {
      String uri = Constants.MASTER_URL + '/financial-year';
      Map params = {"action": "list"};

      Map<String, dynamic> tempMap = await MethodUtils.apiCall(uri, params);

      setState(() {
        bool isFind = tempMap['isValid'];
        if (isFind) {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            financialOptions.add(FinancialModel.fromJson(item));
          }
        } else {
          String msg = tempMap['message'];
          UtilsWidgets.showToastFunc(msg);
        }
      });
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  Future getBudgetInfo() async {
    try {
      String uri = Constants.MASTER_URL + '/budget';
      Map params = {
        "financial_year": financialOptions
            .firstWhere((element) => element.name == selectedFinancial)
            .financial_year_code,
        "action": "list"
      };

      Map<String, dynamic> tempMap = await apiController.fetchData(uri, params);

      bool isValid = tempMap['isValid'];

      setState(() {
        if (isValid) {
          List tempList = tempMap['info'];
          _budgets.clear();
          for (var item in tempList) {
            _budgets.add(BudgetModel.fromJson(item));
          }
          _filteredbudget = List.from(_budgets);
          isFind = true;

          _searchController.addListener(_onDesktopSearchChanged);
          _searchController.addListener(_onMobileSearchChanged);
        } else {
          msg = tempMap['message'];
        }
      });
    } catch (e) {
      setState(() {
        isFind = false;
        msg = e.toString();
      });
    }
  }

  Future fetchBudgetInfo(String budget_code) async {
    try {
      String uri = Constants.MASTER_URL + '/budget';
      Map params = {"action": "get", 'budget_code': budget_code};

      Map<String, dynamic> tempMap = await MethodUtils.apiCall(uri, params);

      setState(() {
        if (tempMap['isValid']) {
          BudgetModel budgetData = BudgetModel.fromJson(tempMap['info']);
          _budgets.removeWhere((element) => element.budget_code == budget_code);
          _budgets.add(budgetData);
          _filteredbudget
              .removeWhere((element) => element.budget_code == budget_code);
          _filteredbudget.add(budgetData);
        } else {
          String msg = tempMap['message'] ?? "Failed to load budget data";
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
                  _sortbudgets();
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
                  _sortbudgets();
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
                  _sortbudgets();
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
          source: _budgetsDataSource(
            context,
            _filteredbudget,
            onEditPressed: (Budget) async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      EditBudget(isEdit: true, budget: Budget),
                ),
              );
              if (result == true) {
                await fetchBudgetInfo(Budget.budget_code);
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
              hintText: 'Search by name or budget code',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Data Budget
        Expanded(
          child: !isFind
              ? Center(child: DecorationWidgets.msgDecor(context, msg))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: UtilsWidgets.drawTable(
                          [
                            DataColumn(
                              label: Text('Name'),
                              onSort: (columnIndex, ascending) {
                                _budgets.sort((a, b) => Utils.compareString(
                                    ascending, a.name, b.name));
                                setState(() {
                                  _sortAscending = ascending;
                                });
                              },
                            ),
                            DataColumn(label: Text('Budget Code')),
                            DataColumn(label: Text('Edit')),
                          ],
                          _filteredbudget
                              .map((e) => DataRow(cells: [
                                    DataCell(Text(e.name)),
                                    DataCell(Text(e.budget_code)),
                                    DataCell(IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () async {
                                        final result =
                                            await Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditBudget(
                                                            isEdit: true,
                                                            budget: e)));
                                        if (result == true) {
                                          await fetchBudgetInfo(e.budget_code);
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

class _budgetsDataSource extends DataTableSource {
  final BuildContext context;
  final List<BudgetModel> budgets;
  final Function(BudgetModel) onEditPressed;

  _budgetsDataSource(this.context, this.budgets, {required this.onEditPressed});

  @override
  DataRow? getRow(int index) {
    if (index >= budgets.length) {
      return null;
    }
    final Budgets = budgets[index];
    String status = Budgets.status ? 'Active' : 'Inactive';
    return DataRow(
      cells: [
        DataCell(Text(Budgets.name)),
        DataCell(Text(Budgets.budget_code)),
        DataCell(DecorationWidgets.buildStatusTag(context, status)),
        DataCell(
          IconButton(
            icon: const Icon(Icons.edit, size: 16),
            visualDensity: VisualDensity.compact,
            onPressed: () => onEditPressed(Budgets),
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
  int get rowCount => budgets.length;

  @override
  int get selectedRowCount => 0;
}
