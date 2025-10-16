import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/models/user_model.dart';
import 'package:sterlite_csr/screens/master/user/user_edit.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/function_utils.dart';
import 'package:sterlite_csr/utilities/method_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:sterlite_csr/utilities/widget_decoration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  APIController apiController = Get.put(APIController());
  bool isFind = false;
  String msg = 'Please wait...';
  String userRole = "";

  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _users = [];
  List<UserModel> _filtereduser = [];
  String _searchQuery = '';
  int _rowsPerPage = 5;
  int _sortColumnIndex = 1;
  bool _sortAscending = true;

  @override
  void initState() {
    getInfo();
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
      _filterusers();
    });
  }

  void _onMobileSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtereduser = List.from(_users); // restore all data
      } else {
        _filtereduser = _users.where((e) {
          final name = e.user_name.toLowerCase();
          final code = e.user_id.toLowerCase();
          return name.contains(query) || code.contains(query);
        }).toList();
      }
    });
  }

  void _filterusers() {
    if (_searchQuery.isEmpty) {
      _filtereduser = List.from(_users);
    } else {
      _filtereduser = _users.where((States) {
        return States.user_name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            States.user_id.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    _sortusers();
  }

  void _sortusers() {
    _filtereduser.sort((a, b) {
      var aValue;
      var bValue;

      switch (_sortColumnIndex) {
        case 0: // ID
          aValue = a.user_id;
          bValue = b.user_id;
          break;
        case 1: // Name
          aValue = a.user_name;
          bValue = b.user_name;
          break;
        case 2: // Salary
          aValue = a.status;
          bValue = b.status;
          break;
        default:
          aValue = a.user_name;
          bValue = b.user_name;
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
        appBar: UtilsWidgets.buildAppBar('User Database', Get.isDarkMode,
            subtitle: 'Manage your user efficiently',
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
                    MaterialPageRoute(builder: (context) => EditUser()),
                  );
                  if (result != null) {
                    await fetchUserInfo(result);
                  }
                },
                label: Text('Add user',
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
                                    'Total: ${_filtereduser.length} users',
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
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: Get.isDarkMode
                                                  ? Colors.black
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: UtilsWidgets.textFormField(
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
                                                          color: Colors.grey),
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

  Future getInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role') ?? '';
    });
    await getUserInfo();
  }

  Future getUserInfo() async {
    setState(() {
      _users.clear();
    });
    try {
      String uri = Constants.USER_URL + '/user';
      Map params = {"action": "list"};
      Map<String, dynamic> tempMap = await apiController.fetchData(uri, params);
      setState(() {
        isFind = tempMap['isValid'];
        if (isFind) {
          List tempList = tempMap['info'];
          for (var item in tempList) {
            _users.add(UserModel.fromJson(item));
          }
          _filtereduser = List.from(_users);
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

  Future fetchUserInfo(String user_id) async {
    try {
      String uri = Constants.USER_URL + '/user';
      Map params = {"action": "get", 'user_id': user_id};

      Map<String, dynamic> tempMap = await MethodUtils.apiCall(uri, params);

      setState(() {
        if (tempMap['isValid']) {
          UserModel userData = UserModel.fromJson(tempMap['info']);
          _users.removeWhere((element) => element.user_id == user_id);
          _users.add(userData);
          _filtereduser.removeWhere((element) => element.user_id == user_id);
          _filtereduser.add(userData);
        } else {
          String msg = tempMap['message'] ?? "Failed to load users data";
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
                  _sortusers();
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
                  _sortusers();
                });
              },
            ),
            DataColumn(
              label: const Text('Role',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              onSort: (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                  _sortusers();
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
                  _sortusers();
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
          source: _usersDataSource(
            context,
            _filtereduser,
            onEditPressed: (User) async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditUser(isEdit: true, user: User),
                ),
              );
              if (result == true) {
                await fetchUserInfo(User.user_id);
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
              hintText: 'Search by name or user code',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Data Section
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: UtilsWidgets.drawTable(
            [
              DataColumn(
                label: Text('Name'),
                onSort: (columnIndex, ascending) {
                  _users.sort((a, b) =>
                      Utils.compareString(ascending, a.user_name, b.user_name));
                  setState(() {
                    _sortAscending = ascending;
                  });
                },
              ),
              DataColumn(label: Text('User Code')),
              DataColumn(label: Text('User Role')),
              DataColumn(label: Text('Edit')),
            ],
            _filtereduser
                .map((e) => DataRow(cells: [
                      DataCell(Text(e.user_name)),
                      DataCell(Text(e.user_id)),
                      DataCell(Text(e.role)),
                      DataCell(IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EditUser(isEdit: true, user: e)));
                          if (result == true) {
                            await fetchUserInfo(e.user_id);
                          }
                        },
                      )),
                    ]))
                .toList(),
            isAscending: _sortAscending,
            sortColumnIndex: _sortColumnIndex,
          ),
        ),
      ],
    );
  }
}

class _usersDataSource extends DataTableSource {
  final BuildContext context;
  final List<UserModel> users;
  final Function(UserModel) onEditPressed;

  _usersDataSource(this.context, this.users, {required this.onEditPressed});

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) {
      return null;
    }
    final User = users[index];
    String status = User.status ? 'Active' : 'Inactive';
    return DataRow(
      cells: [
        DataCell(Text(User.user_name)),
        DataCell(Text(User.user_id)),
        DataCell(Text(User.role)),
        DataCell(DecorationWidgets.buildStatusTag(context, status)),
        DataCell(
          IconButton(
            icon: const Icon(Icons.edit, size: 16),
            visualDensity: VisualDensity.compact,
            onPressed: () => onEditPressed(User),
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
  int get rowCount => users.length;

  @override
  int get selectedRowCount => 0;
}
