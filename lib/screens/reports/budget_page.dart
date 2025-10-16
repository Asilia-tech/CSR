import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sterlite_csr/utilities/report_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sterlite_csr/constants.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({Key? key}) : super(key: key);

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
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

  List<BudgetChartData> _entityBasedBudgetData = [];
  List<BudgetChartData> _focusAreaBudgetData = [];
  List<BudgetChartData> _stateBasedBudgetData = [];
  List<BudgetChartData> _monthBasedBudgetData = [];

  List<BudgetTableData> _tableData = [];

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
        'budget_details': {
          'entity_wise': [
            {'x': 'Serentica', 'budget': 320, 'utilized': 290},
            {'x': 'Sterlite Electric', 'budget': 280, 'utilized': 260},
            {'x': 'Resonia Foundation', 'budget': 210, 'utilized': 190},
          ],
          'focus_area_wise': [
            {'x': 'Education', 'budget': 400, 'utilized': 360},
            {'x': 'Health', 'budget': 300, 'utilized': 270},
            {'x': 'Environment', 'budget': 250, 'utilized': 200},
          ],
          'state_wise': [
            {'x': 'Maharashtra', 'budget': 450, 'utilized': 410},
            {'x': 'Rajasthan', 'budget': 350, 'utilized': 300},
            {'x': 'Uttarakhand', 'budget': 300, 'utilized': 280},
          ],
          'month_wise': [
            {'x': 'Jan', 'budget': 120, 'utilized': 110},
            {'x': 'Feb', 'budget': 140, 'utilized': 130},
            {'x': 'Mar', 'budget': 110, 'utilized': 95},
            {'x': 'Apr', 'budget': 160, 'utilized': 150},
            {'x': 'May', 'budget': 180, 'utilized': 170},
            {'x': 'Jun', 'budget': 120, 'utilized': 110},
            {'x': 'July', 'budget': 140, 'utilized': 130},
          ],
          'table_data': [
            {
              'state': 'Maharashtra',
              'district': 'Pune',
              'entities': {
                'Serentica': {'budget': 100, 'utilized': 80},
                'Resonia': {'budget': 300, 'utilized': 140},
                'Sterlite Electric': {'budget': 200, 'utilized': 123},
              }
            },
            {
              'state': 'Maharashtra',
              'district': 'Thane',
              'entities': {
                'Serentica': {'budget': 67, 'utilized': 21},
                'Resonia': {'budget': 324, 'utilized': 323},
                'Sterlite Electric': {'budget': 120, 'utilized': 100},
              }
            },
            {
              'state': 'Rajasthan',
              'district': 'Jaipur',
              'entities': {
                'Serentica': {'budget': 300, 'utilized': 123},
                'Resonia': {'budget': 343, 'utilized': 321},
                'Sterlite Electric': {'budget': 222, 'utilized': 122},
              }
            },
          ],
        }
      };

      _processAndSetState(apiResponse);
    } catch (e) {
      print("An error occurred: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _processAndSetState(Map<String, dynamic> data) {
    final filters = data['filters'];
    final budgetDetails = data['budget_details'];

    setState(() {
      _financialYears = List<String>.from(filters['financial_years']);
      _projects = List<String>.from(filters['projects']);
      _entities = List<String>.from(filters['entities']);
      _focusAreas = List<String>.from(filters['focus_areas']);
      _ngos = List<String>.from(filters['ngos']);
      _states = List<String>.from(filters['states']);
      _districts = List<String>.from(filters['districts']);
      _villages = List<String>.from(filters['villages']);

      _entityBasedBudgetData = (budgetDetails['entity_wise'] as List)
          .map((item) => BudgetChartData.fromJson(item))
          .toList();
      _focusAreaBudgetData = (budgetDetails['focus_area_wise'] as List)
          .map((item) => BudgetChartData.fromJson(item))
          .toList();
      _stateBasedBudgetData = (budgetDetails['state_wise'] as List)
          .map((item) => BudgetChartData.fromJson(item))
          .toList();
      _monthBasedBudgetData = (budgetDetails['month_wise'] as List)
          .map((item) => BudgetChartData.fromJson(item))
          .toList();

      _tableData = (budgetDetails['table_data'] as List)
          .map((item) => BudgetTableData.fromJson(item))
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
      appBar:
          UtilsWidgets.buildAppBar('Detailed Budget Analysis', Get.isDarkMode),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildFilterSection(),
                  const SizedBox(height: 32),
                  _buildChartSection(
                    'Entity Based Budget Analysis',
                    _entityBasedBudgetData,
                    Constants.group1_deep,
                    Constants.group1_light,
                    'Focus Area Based Budget Analysis',
                    _focusAreaBudgetData,
                    Constants.group2_deep,
                    Constants.group2_light,
                  ),
                  const SizedBox(height: 24),
                  _buildChartSection(
                    'State Based Budget Analysis',
                    _stateBasedBudgetData,
                    Constants.group3_deep,
                    Constants.group3_light,
                    'Month Based Budget Analysis',
                    _monthBasedBudgetData,
                    Constants.group4_deep,
                    Constants.group4_light,
                  ),
                  const SizedBox(height: 24),
                  _buildBudgetTable(),
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

  Widget _buildChartSection(
    String title1,
    List<BudgetChartData> data1,
    Color color1,
    Color color1b,
    String title2,
    List<BudgetChartData> data2,
    Color color2,
    Color color2b,
  ) {
    return ReportUtils.buildStyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 800;

              if (isMobile) {
                return Column(
                  children: [
                    _buildChart(title1, data1, color1, color1b),
                    const SizedBox(height: 32),
                    Divider(color: Constants.background, thickness: 1.5),
                    const SizedBox(height: 32),
                    _buildChart(title2, data2, color2, color2b),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(
                        child: _buildChart(title1, data1, color1, color1b)),
                    const SizedBox(width: 24),
                    Container(
                        width: 1.5, height: 300, color: Constants.background),
                    const SizedBox(width: 24),
                    Expanded(
                        child: _buildChart(title2, data2, color2, color2b)),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChart(String title, List<BudgetChartData> data,
      Color budgetColor, Color utilizedColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Constants.canvasColor)),
        ),
        const SizedBox(height: 10),
        Divider(color: Constants.background, thickness: 1),
        const SizedBox(height: 14),
        SizedBox(
          height: 280,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              majorGridLines: const MajorGridLines(width: 0),
              axisLine: const AxisLine(width: 0),
              labelStyle: TextStyle(
                  color: Constants.greyColor, fontWeight: FontWeight.w500),
            ),
            primaryYAxis: NumericAxis(isVisible: false),
            plotAreaBorderWidth: 0,
            legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                overflowMode: LegendItemOverflowMode.wrap,
                textStyle: TextStyle(color: Constants.greyColor, fontSize: 13)),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              elevation: 4,
              canShowMarker: false,
              header: '',
              builder: (dynamic data, dynamic point, dynamic series,
                  int pointIndex, int seriesIndex) {
                final BudgetChartData chartData = data as BudgetChartData;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Constants.canvasColor,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chartData.x,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Budget: ${chartData.budget.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        'Utilized: ${chartData.utilized.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            series: <ChartSeries>[
              ColumnSeries<BudgetChartData, String>(
                  dataSource: data,
                  xValueMapper: (BudgetChartData d, _) => d.x,
                  yValueMapper: (BudgetChartData d, _) => d.budget,
                  name: 'Budget',
                  color: budgetColor,
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: TextStyle(
                          fontSize: 10,
                          color: Constants.greyColor,
                          fontWeight: FontWeight.bold))),
              ColumnSeries<BudgetChartData, String>(
                  dataSource: data,
                  xValueMapper: (BudgetChartData d, _) => d.x,
                  yValueMapper: (BudgetChartData d, _) => d.utilized,
                  name: 'Utilized',
                  color: utilizedColor,
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: TextStyle(
                          fontSize: 10,
                          color: Constants.canvasColor,
                          fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetTable() {
    final entities = ['Serentica', 'Resonia', 'Sterlite Electric'];

    return ReportUtils.buildStyledCard(
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 48,
            ),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Constants.group1_deep),
              columnSpacing: 30,
              horizontalMargin: 20,
              dataRowHeight: 56,
              headingRowHeight: 70,
              columns: [
                DataColumn(
                  label: Text('State',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Constants.group1_light,
                          fontSize: 14)),
                ),
                DataColumn(
                  label: Text('District',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Constants.group1_light,
                          fontSize: 14)),
                ),
                ...entities.map((entity) => DataColumn(
                      label: Container(
                        width: 150,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(entity,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Constants.group1_light,
                                    fontSize: 14)),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Budget',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Constants.background)),
                                SizedBox(width: 20),
                                Text('Utilized',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Constants.background)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
              rows: _buildTableRows(entities),
            ),
          ),
        ),
      ),
    );
  }

  List<DataRow> _buildTableRows(List<String> entities) {
    List<DataRow> rows = [];
    String? currentState;

    for (var data in _tableData) {
      bool isNewState = currentState != data.state;
      currentState = data.state;

      rows.add(DataRow(cells: [
        DataCell(Text(
          isNewState ? data.state : '',
          style: TextStyle(
              fontWeight: FontWeight.w600, color: Colors.black, fontSize: 13),
        )),
        DataCell(Text(
          data.district,
          style: TextStyle(color: Constants.greyColor, fontSize: 13),
        )),
        ...entities.map((entity) {
          final entityBudget = data.entityData[entity];
          return DataCell(
            Container(
              width: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      entityBudget?.budget.toStringAsFixed(0) ?? '-',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color.fromARGB(255, 45, 53, 63), fontSize: 13),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      entityBudget?.utilized.toStringAsFixed(0) ?? '-',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color.fromARGB(255, 45, 53, 63), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ]));
    }

    return rows;
  }
}

class BudgetChartData {
  BudgetChartData(this.x, this.budget, this.utilized);
  final String x;
  final double budget;
  final double utilized;

  factory BudgetChartData.fromJson(Map<String, dynamic> json) {
    return BudgetChartData(
      json['x'] as String,
      (json['budget'] as num).toDouble(),
      (json['utilized'] as num).toDouble(),
    );
  }
}

class BudgetTableData {
  final String state;
  final String district;
  final Map<String, EntityBudget> entityData;

  BudgetTableData({
    required this.state,
    required this.district,
    required this.entityData,
  });

  factory BudgetTableData.fromJson(Map<String, dynamic> json) {
    Map<String, EntityBudget> entityMap = {};
    (json['entities'] as Map<String, dynamic>).forEach((key, value) {
      entityMap[key] = EntityBudget(
        budget: (value['budget'] as num).toDouble(),
        utilized: (value['utilized'] as num).toDouble(),
      );
    });

    return BudgetTableData(
      state: json['state'] as String,
      district: json['district'] as String,
      entityData: entityMap,
    );
  }
}

class EntityBudget {
  final double budget;
  final double utilized;

  EntityBudget({required this.budget, required this.utilized});
}
