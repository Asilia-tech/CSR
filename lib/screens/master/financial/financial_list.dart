import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/utilities/function_utils.dart';
import 'package:sterlite_csr/utilities/method_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:sterlite_csr/models/financial_model.dart';
import 'package:sterlite_csr/utilities/widget_decoration.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sterlite_csr/screens/master/financial/financial_edit.dart';

class FinancialList extends StatefulWidget {
  const FinancialList({super.key});

  @override
  _FinancialListState createState() => _FinancialListState();
}

class _FinancialListState extends State<FinancialList> {
  APIController apiController = Get.put(APIController());

  bool isFind = false;
  String msg = 'Please wait...';
  String userRole = "";

  List<FinancialModel> _financials = [];
  List<FinancialModel> _filteredfinancial = [];

  final TextEditingController _searchController = TextEditingController();
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
      _filterfinancials();
    });
  }

  void _onMobileSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredfinancial = List.from(_financials); // restore all data
      } else {
        _filteredfinancial = _financials.where((e) {
          final name = e.name.toLowerCase();
          final code = e.financial_year_code.toLowerCase();
          return name.contains(query) || code.contains(query);
        }).toList();
      }
    });
  }

  void _filterfinancials() {
    if (_searchQuery.isEmpty) {
      _filteredfinancial = List.from(_financials);
    } else {
      _filteredfinancial = _financials.where((States) {
        return States.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            States.financial_year_code
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }
    _sortfinancials();
  }

  void _sortfinancials() {
    _filteredfinancial.sort((a, b) {
      var aValue;
      var bValue;

      switch (_sortColumnIndex) {
        case 0: // ID
          aValue = a.financial_year_code;
          bValue = b.financial_year_code;
          break;
        case 1: // Name
          aValue = a.name;
          bValue = b.name;
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isDesktop = constraints.maxWidth < 600;
      return Scaffold(
        appBar: UtilsWidgets.buildAppBar('Financial Database', Get.isDarkMode,
            subtitle: 'Manage your financial efficiently',
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
                    MaterialPageRoute(builder: (context) => EditFinancial()),
                  );
                  if (result != null) {
                    await fetchFinancialInfo(result);
                  }
                },
                label: Text('Add Financial',
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
                                          'Total: ${_filteredfinancial.length} financials',
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
    await getFinancialInfo();
  }

  Future getFinancialInfo() async {
    setState(() {
      _financials.clear();
    });
    try {
      String uri = Constants.MASTER_URL + '/financial-year';
      Map params = {"action": "list"};
      Map<String, dynamic> tempMap = await apiController.fetchData(uri, params);
      setState(() {
        isFind = tempMap['isValid'];
        if (isFind) {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            _financials.add(FinancialModel.fromJson(item));
          }
          _filteredfinancial = List.from(_financials);
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

  Future fetchFinancialInfo(String financial_year_code) async {
    try {
      String uri = Constants.MASTER_URL + '/financial-year';
      Map params = {
        "action": "get",
        'financial_year_code': financial_year_code
      };

      Map<String, dynamic> tempMap = await MethodUtils.apiCall(uri, params);

      setState(() {
        if (tempMap['isValid']) {
          FinancialModel financialData =
              FinancialModel.fromJson(tempMap['info']);
          _financials.removeWhere(
              (element) => element.financial_year_code == financial_year_code);
          _financials.add(financialData);
          _filteredfinancial.removeWhere(
              (element) => element.financial_year_code == financial_year_code);
          _filteredfinancial.add(financialData);
        } else {
          String msg = tempMap['message'] ?? "Failed to load financial data";
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
                  _sortfinancials();
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
                  _sortfinancials();
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
                  _sortfinancials();
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
          source: _financialsDataSource(
            context,
            _filteredfinancial,
            onEditPressed: (Financial) async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      EditFinancial(isEdit: true, financial: Financial),
                ),
              );
              if (result == true) {
                await fetchFinancialInfo(Financial.financial_year_code);
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
              hintText: 'Search by name or financial code',
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
                                _financials.sort((a, b) => Utils.compareString(
                                    ascending, a.name, b.name));
                                setState(() {
                                  _sortAscending = ascending;
                                });
                              },
                            ),
                            DataColumn(label: Text('District Code')),
                            DataColumn(label: Text('Edit')),
                          ],
                          _filteredfinancial
                              .map((e) => DataRow(cells: [
                                    DataCell(Text(e.name)),
                                    DataCell(Text(e.financial_year_code)),
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
                                                        EditFinancial(
                                                            isEdit: true,
                                                            financial: e)));
                                        if (result == true) {
                                          await fetchFinancialInfo(
                                              e.financial_year_code);
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

class _financialsDataSource extends DataTableSource {
  final BuildContext context;
  final List<FinancialModel> financiales;
  final Function(FinancialModel) onEditPressed;

  _financialsDataSource(this.context, this.financiales,
      {required this.onEditPressed});

  @override
  DataRow? getRow(int index) {
    if (index >= financiales.length) {
      return null;
    }
    final Financials = financiales[index];
    String status = Financials.status ? 'Active' : 'Inactive';
    return DataRow(
      cells: [
        DataCell(Text(Financials.name)),
        DataCell(Text(Financials.financial_year_code)),
        DataCell(DecorationWidgets.buildStatusTag(context, status)),
        DataCell(
          IconButton(
            icon: const Icon(Icons.edit, size: 16),
            visualDensity: VisualDensity.compact,
            onPressed: () => onEditPressed(Financials),
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
  int get rowCount => financiales.length;

  @override
  int get selectedRowCount => 0;
}
