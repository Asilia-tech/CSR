import 'package:get/get.dart';
import 'package:sterlite_csr/utilities/report_utils.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';

class NonBeneficiaryPage extends StatefulWidget {
  const NonBeneficiaryPage({Key? key}) : super(key: key);

  @override
  State<NonBeneficiaryPage> createState() => _NonBeneficiaryPageState();
}

class _NonBeneficiaryPageState extends State<NonBeneficiaryPage> {
  bool _isLoading = true;

  String? _selectedFinancialYear;
  String? _selectedMonth;
  String? _selectedProject;
  String? _selectedEntity;
  String? _selectedFocusArea;
  String? _selectedNgo;
  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedVillage;

  List<String> _financialYears = [];
  List<String> _projects = [];
  List<String> _entities = [];
  List<String> _focusAreas = [];
  List<String> _ngos = [];
  List<String> _states = [];
  List<String> _districts = [];
  List<String> _villages = [];

  List<NonBeneficiaryData> _tableData = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      final apiResponse = {
        'filters': {
          'financial_years': ['2023-2024', '2024-2025', '2025-2026'],
          'projects': ['Project Shiksha', 'Project Arogya', 'Project Harit'],
          'entities': ['Serentica', 'Sterlite Electric', 'Resonia'],
          'focus_areas': ['Education', 'Health', 'Environment'],
          'ngos': ['Goonj', 'Smile Foundation', 'HelpAge India'],
          'states': ['Maharashtra', 'Rajasthan', 'Uttarakhand'],
          'districts': ['Pune', 'Jaipur', 'Dehradun'],
          'villages': ['Rampur', 'Bhavnipur', 'Chandpur'],
        },
        'table_data': [
          {
            'month': 'January',
            'indicator': 'Awareness Campaign Reach',
            'value': '1,250 People'
          },
          {
            'month': 'January',
            'indicator': 'School Dropouts Prevented',
            'value': '15 Students'
          },
          {
            'month': 'February',
            'indicator': 'Awareness Campaign Reach',
            'value': '1,400 People'
          },
          {
            'month': 'February',
            'indicator': 'Community Meetings Held',
            'value': '8 Meetings'
          },
          {
            'month': 'March',
            'indicator': 'Awareness Campaign Reach',
            'value': '1,320 People'
          },
          {
            'month': 'March',
            'indicator': 'Health Checkups Conducted',
            'value': '250 Individuals'
          },
          {
            'month': 'April',
            'indicator': 'School Dropouts Prevented',
            'value': '18 Students'
          },
          {
            'month': 'May',
            'indicator': 'Community Meetings Held',
            'value': '12 Meetings'
          },
        ]
      };

      _processAndSetState(apiResponse);
    } catch (e) {
      UtilsWidgets.showToastFunc("An error occurred: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _processAndSetState(Map<String, dynamic> data) {
    final filters = data['filters'];
    final tableData = data['table_data'];

    setState(() {
      _financialYears = List<String>.from(filters['financial_years']);
      _projects = List<String>.from(filters['projects']);
      _entities = List<String>.from(filters['entities']);
      _focusAreas = List<String>.from(filters['focus_areas']);
      _ngos = List<String>.from(filters['ngos']);
      _states = List<String>.from(filters['states']);
      _districts = List<String>.from(filters['districts']);
      _villages = List<String>.from(filters['villages']);

      _tableData = (tableData as List)
          .map((item) => NonBeneficiaryData.fromJson(item))
          .toList();

      _selectedFinancialYear ??=
          _financialYears.isNotEmpty ? _financialYears.first : null;
      _selectedMonth ??=
          Constants.months.isNotEmpty ? Constants.months.first : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.background,
      appBar: UtilsWidgets.buildAppBar(
          'Detailed Non-Beneficiary Analysis', Get.isDarkMode),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(),
                  const SizedBox(height: 32),
                  _buildTableSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterSection() {
    final filterWidgets = _getFilterWidgets();

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 800;
        bool isDesktop = constraints.maxWidth >= 800;

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: filterWidgets.map((widget) {
                  return SizedBox(
                    width: (constraints.maxWidth - 36) / 2,
                    child: widget,
                  );
                }).toList(),
              ),
            ],
          );
        } else {
          return GridView.count(
            crossAxisCount: constraints.maxWidth > 1200 ? 5 : 4,
            childAspectRatio: 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: filterWidgets,
          );
        }
      },
    );
  }

  List<Widget> _getFilterWidgets() {
    return [
      ReportUtils.buildDropdown(
          'Financial Year', _financialYears, _selectedFinancialYear, (val) {
        setState(() => _selectedFinancialYear = val);
        _fetchData();
      }),
      ReportUtils.buildDropdown('Month', Constants.months, _selectedMonth,
          (val) {
        setState(() => _selectedMonth = val);
        _fetchData();
      }),
      ReportUtils.buildDropdown('Project', _projects, _selectedProject, (val) {
        setState(() => _selectedProject = val);
        _fetchData();
      }),
      ReportUtils.buildDropdown('Entity', _entities, _selectedEntity, (val) {
        setState(() => _selectedEntity = val);
        _fetchData();
      }),
      ReportUtils.buildDropdown('Focus Area', _focusAreas, _selectedFocusArea,
          (val) {
        setState(() => _selectedFocusArea = val);
        _fetchData();
      }),
      ReportUtils.buildDropdown('NGO', _ngos, _selectedNgo, (val) {
        setState(() => _selectedNgo = val);
        _fetchData();
      }),
      ReportUtils.buildDropdown('State', _states, _selectedState, (val) {
        setState(() => _selectedState = val);
        _fetchData();
      }),
      ReportUtils.buildDropdown('District', _districts, _selectedDistrict,
          (val) {
        setState(() => _selectedDistrict = val);
        _fetchData();
      }),
      ReportUtils.buildDropdown('Village', _villages, _selectedVillage, (val) {
        setState(() => _selectedVillage = val);
        _fetchData();
      }),
    ];
  }

  Widget _buildTableSection() {
    return ReportUtils.buildStyledCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list, color: Constants.greyColor, size: 18),
              SizedBox(width: 12),
              Text(
                'Non-Beneficiary Data List',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Constants.canvasColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Constants.background, thickness: 1),
          const SizedBox(height: 16),
          if (_tableData.isEmpty)
            Container(
              height: 200,
              alignment: Alignment.center,
              child: Text(
                'No data available for the selected filters.',
                style: TextStyle(color: Constants.greyColor, fontSize: 15),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width - 96,
                    ),
                    child: DataTable(
                      headingRowHeight: 48,
                      dataRowHeight: 52,
                      headingRowColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 13, 35, 72)),
                      columns: const [
                        DataColumn(
                            label: Text('MONTH',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5))),
                        DataColumn(
                            label: Text('INDICATOR',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5))),
                        DataColumn(
                            label: Text('VALUE',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5))),
                      ],
                      rows: _tableData.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final NonBeneficiaryData data = entry.value;
                        return DataRow(
                          color: MaterialStateProperty.all(
                            index.isEven ? Colors.white : Constants.greyColor,
                          ),
                          cells: [
                            DataCell(Text(data.month,
                                style: TextStyle(color: Constants.greyColor))),
                            DataCell(Text(data.indicator,
                                style:
                                    TextStyle(color: Constants.canvasColor))),
                            DataCell(Text(data.value,
                                style: TextStyle(
                                    color: Constants.canvasColor,
                                    fontWeight: FontWeight.w600))),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class NonBeneficiaryData {
  final String month;
  final String indicator;
  final String value;

  NonBeneficiaryData(
      {required this.month, required this.indicator, required this.value});

  factory NonBeneficiaryData.fromJson(Map<String, dynamic> json) {
    return NonBeneficiaryData(
      month: json['month'] as String,
      indicator: json['indicator'] as String,
      value: json['value'] as String,
    );
  }
}
