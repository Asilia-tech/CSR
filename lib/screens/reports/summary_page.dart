import 'package:get/get.dart';
import 'package:sterlite_csr/screens/reports/beneficiary_page.dart';
import 'package:sterlite_csr/screens/reports/budget_page.dart';
import 'package:sterlite_csr/screens/reports/non_beneficiary_page.dart';
import 'package:sterlite_csr/utilities/report_utils.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sterlite_csr/constants.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({Key? key}) : super(key: key);

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
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

  List<ChartData> _stateWiseBudgetData = [];
  List<ChartData> _entityWiseBudgetData = [];
  List<ChartData> _stateWiseBeneficiaryData = [];
  List<ChartData> _entityWiseBeneficiaryData = [];

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
          'financial_years': [
            '2021-2022',
            '2022-2023',
            '2023-2024',
            '2024-2025',
            '2025-2026'
          ],
          'projects': [
            'Project Shiksha',
            'Project Arogya',
            'Project Jal',
            'Project Udaan',
            'Project Dignity',
            'Project Saksham',
            'Project Samvedna'
          ],
          'entities': ['Serentica', 'Sterlite Electric', 'Resonia'],
          'focus_areas': ['Education', 'Health', 'Environment'],
          'ngos': ['Goonj', 'Pratham', 'Smile Foundation', 'HelpAge India'],
          'states': ['Maharashtra', 'Uttarakhand', 'Rajasthan'],
          'districts': ['Thane', 'Raigad', 'Nashik', 'Pune'],
          'villages': [
            'Rampur',
            'Bhavnipur',
            'Chandpur',
            'Devgaon',
            'Sundarpur'
          ]
        },
        'budget_analysis': {
          'state_wise': [
            {'x': 'Maharashtra', 'y1': 150, 'y2': 130},
            {'x': 'Uttarakhand', 'y1': 100, 'y2': 85},
            {'x': 'Rajasthan', 'y1': 120, 'y2': 110},
          ],
          'entity_wise': [
            {'x': 'Serentica', 'y1': 250, 'y2': 230},
            {'x': 'Sterlite Electric', 'y1': 200, 'y2': 180},
            {'x': 'Resonia', 'y1': 180, 'y2': 160},
          ],
        },
        'beneficiary_analysis': {
          'state_wise': [
            {'x': 'Maharashtra', 'y1': 600, 'y2': 500},
            {'x': 'Uttarakhand', 'y1': 450, 'y2': 380},
            {'x': 'Rajasthan', 'y1': 500, 'y2': 420},
          ],
          'entity_wise': [
            {'x': 'Serentica', 'y1': 900, 'y2': 850},
            {'x': 'Sterlite Electric', 'y1': 800, 'y2': 720},
            {'x': 'Resonia', 'y1': 750, 'y2': 690},
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
    final budgetData = data['budget_analysis'];
    final beneficiaryData = data['beneficiary_analysis'];

    setState(() {
      _financialYears = List<String>.from(filters['financial_years']);
      _projects = List<String>.from(filters['projects']);
      _entities = List<String>.from(filters['entities']);
      _focusAreas = List<String>.from(filters['focus_areas']);
      _ngos = List<String>.from(filters['ngos']);
      _states = List<String>.from(filters['states']);
      _districts = List<String>.from(filters['districts']);
      _villages = List<String>.from(filters['villages']);

      _stateWiseBudgetData = (budgetData['state_wise'] as List)
          .map((item) => ChartData.fromJson(item))
          .toList();
      _entityWiseBudgetData = (budgetData['entity_wise'] as List)
          .map((item) => ChartData.fromJson(item))
          .toList();
      _stateWiseBeneficiaryData = (beneficiaryData['state_wise'] as List)
          .map((item) => ChartData.fromJson(item))
          .toList();
      _entityWiseBeneficiaryData = (beneficiaryData['entity_wise'] as List)
          .map((item) => ChartData.fromJson(item))
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
      backgroundColor: Color(0xFFF8FAFC),
      appBar: UtilsWidgets.buildAppBar('Dashboard', Get.isDarkMode),
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
                  _buildBudgetSection(),
                  const SizedBox(height: 24),
                  _buildBeneficiarySection(),
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

  Widget _buildBudgetSection() {
    return ReportUtils.buildStyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 600;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Constants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.attach_money_rounded,
                            color: Constants.primaryColor, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Budget Analysis',
                          style: TextStyle(
                              fontSize: isMobile ? 16 : 18,
                              fontWeight: FontWeight.w600,
                              color: Constants.canvasColor),
                        ),
                      ),
                      if (!isMobile) ...[
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const BudgetPage()),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward_ios, size: 14),
                          label: const Text('Detailed Budget Analysis'),
                          style: TextButton.styleFrom(
                            foregroundColor: Constants.secondaryColor,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isMobile) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BudgetPage()),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward_ios, size: 14),
                      label: const Text(
                        'Details',
                        style: TextStyle(fontSize: 13),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Constants.secondaryColor,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Divider(
            color: Constants.secondaryColor.withOpacity(0.5),
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 800;

              if (isMobile) {
                return Column(
                  children: [
                    _buildChart(
                        'State wise Budget Analysis',
                        _stateWiseBudgetData,
                        'Budget',
                        'Utilization',
                        Constants.primaryColor,
                        Constants.secondaryColor),
                    const SizedBox(height: 32),
                    Divider(color: Constants.background, thickness: 1.5),
                    const SizedBox(height: 32),
                    _buildChart(
                        'Entity wise Budget Analysis',
                        _entityWiseBudgetData,
                        'Budget',
                        'Utilization',
                        Constants.primaryColor,
                        Constants.secondaryColor),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(
                        child: _buildChart(
                            'State wise Budget Analysis',
                            _stateWiseBudgetData,
                            'Budget',
                            'Utilization',
                            Constants.primaryColor,
                            Constants.secondaryColor)),
                    const SizedBox(width: 24),
                    Container(
                        width: 1.5, height: 280, color: Constants.background),
                    const SizedBox(width: 24),
                    Expanded(
                        child: _buildChart(
                            'Entity wise Budget Analysis',
                            _entityWiseBudgetData,
                            'Budget',
                            'Utilization',
                            Constants.primaryColor,
                            Constants.secondaryColor)),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBeneficiarySection() {
    return ReportUtils.buildStyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 600;

              return Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Constants.ternaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.done_all_outlined,
                            color: Constants.ternaryColor, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Beneficiary Analysis',
                          style: TextStyle(
                              fontSize: isMobile ? 16 : 18,
                              fontWeight: FontWeight.w600,
                              color: Constants.canvasColor),
                        ),
                      ),
                      if (!isMobile) ...[
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const BeneficiaryPage()),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward_ios, size: 14),
                          label: const Text('Detailed Beneficiary Analysis'),
                          style: TextButton.styleFrom(
                            foregroundColor: Constants.quartaryColor,
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const NonBeneficiaryPage()),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward_ios, size: 14),
                          label:
                              const Text('Detailed Non-Beneficiary Analysis'),
                          style: TextButton.styleFrom(
                            foregroundColor: Constants.quartaryColor,
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isMobile) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const BeneficiaryPage()),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward_ios, size: 14),
                          label: const Text('Beneficiary',
                              style: TextStyle(fontSize: 13)),
                          style: TextButton.styleFrom(
                            foregroundColor: Constants.quartaryColor,
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const NonBeneficiaryPage()),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward_ios, size: 14),
                          label: const Text('Non-Beneficiary',
                              style: TextStyle(fontSize: 13)),
                          style: TextButton.styleFrom(
                            foregroundColor: Constants.quartaryColor,
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Divider(
            color: Constants.quartaryColor.withOpacity(0.5),
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 800;
              bool isDesktop = constraints.maxWidth >= 800;

              if (isMobile) {
                return Column(
                  children: [
                    _buildChart(
                        'State wise Beneficiary Analysis',
                        _stateWiseBeneficiaryData,
                        'Project Based',
                        'Location Based',
                        Constants.ternaryColor,
                        Constants.quartaryColor),
                    const SizedBox(height: 32),
                    Divider(color: Constants.background, thickness: 1.5),
                    const SizedBox(height: 32),
                    _buildChart(
                        'Entity wise Beneficiary Analysis',
                        _entityWiseBeneficiaryData,
                        'Project Based',
                        'Location Based',
                        Constants.ternaryColor,
                        Constants.quartaryColor),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(
                        child: _buildChart(
                            'State wise Beneficiary Analysis',
                            _stateWiseBeneficiaryData,
                            'Project Based',
                            'Location Based',
                            Constants.ternaryColor,
                            Constants.quartaryColor)),
                    const SizedBox(width: 24),
                    Container(
                        width: 1.5, height: 280, color: Constants.background),
                    const SizedBox(width: 24),
                    Expanded(
                        child: _buildChart(
                            'Entity wise Beneficiary Analysis',
                            _entityWiseBeneficiaryData,
                            'Project Based',
                            'Location Based',
                            Constants.ternaryColor,
                            Constants.quartaryColor)),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChart(String title, List<ChartData> data, String seriesOneName,
      String seriesTwoName, Color color1, Color color2) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Constants.canvasColor),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 250,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              majorGridLines: const MajorGridLines(width: 0),
              axisLine: const AxisLine(width: 0),
              majorTickLines: const MajorTickLines(size: 0),
              labelStyle: TextStyle(
                  fontSize: 12,
                  color: Constants.greyColor,
                  fontWeight: FontWeight.w500),
            ),
            primaryYAxis: NumericAxis(
              isVisible: false,
              rangePadding: ChartRangePadding.additional,
            ),
            plotAreaBorderWidth: 0,
            legend: Legend(isVisible: true, position: LegendPosition.bottom),
            tooltipBehavior: TooltipBehavior(enable: true, header: ''),
            series: <ChartSeries>[
              ColumnSeries<ChartData, String>(
                dataSource: data,
                xValueMapper: (ChartData sales, _) => sales.x,
                yValueMapper: (ChartData sales, _) => sales.y1,
                name: seriesOneName,
                color: color1,
                borderRadius: const BorderRadius.all(Radius.circular(3)),
                dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                    textStyle: TextStyle(
                        fontSize: 10,
                        color: Constants.greyColor,
                        fontWeight: FontWeight.bold)),
              ),
              ColumnSeries<ChartData, String>(
                dataSource: data,
                xValueMapper: (ChartData sales, _) => sales.x,
                yValueMapper: (ChartData sales, _) => sales.y2,
                name: seriesTwoName,
                color: color2,
                borderRadius: const BorderRadius.all(Radius.circular(3)),
                dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                    textStyle: TextStyle(
                        fontSize: 10,
                        color: Constants.canvasColor,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChartData {
  final String x;
  final double y1;
  final double y2;

  ChartData(this.x, this.y1, this.y2);

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      json['x'] as String,
      (json['y1'] as num).toDouble(),
      (json['y2'] as num).toDouble(),
    );
  }
}
