import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/routes.dart';
import 'package:sterlite_csr/theme/theme_controller.dart';
import 'package:sterlite_csr/utilities/report_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sterlite_csr/screens/landing_screen.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/function_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';
import 'package:sterlite_csr/utilities/widget_decoration.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final APIController apiController = Get.put(APIController());
  Map<String, dynamic> tempCount = {};
  String selectedTab = 'Dashboard';
  String userRole = "";

  String currentDate = '';

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return userRole == ""
        ? const LandingPage()
        : PopScope(
            canPop: false,
            child: GetBuilder<ThemeController>(builder: (themeController) {
              return LayoutBuilder(builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 600;
                return Scaffold(
                  appBar: isMobile && selectedTab == 'Dashboard'
                      ? UtilsWidgets.buildAppBar(
                          'Dashboard',
                          themeController.isDarkMode.value,
                          subtitle:
                              'Overview of your system\'s performance and metrics',
                        )
                      : null,
                  endDrawer:
                      isMobile ? _buildDrawer(themeController, context) : null,
                  body: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMobile)
                        SingleChildScrollView(
                            child: _buildSidebar(themeController, context)),
                      Expanded(
                          child: selectedTab == 'Dashboard'
                              ? apiController.isLoading.isTrue
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : _buildDashboardContent(
                                      isMobile, themeController)
                              : AppRoutes.getSelectedScreen(selectedTab)),
                    ],
                  ),
                );
              });
            }),
          );
  }

  Widget _buildSidebar(ThemeController themeController, BuildContext context) {
    return SizedBox(
      width: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Image.asset('assets/images/logo.png', height: 60),
            ),
          ),
          const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Version: ',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Text('${Constants.appVersion}', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const Divider(thickness: 1),
          _buildNavItem(Icons.home, 'Dashboard', () {
            setState(() {
              selectedTab = 'Dashboard';
            });
          }),
          if (userRole == 'super_admin') _buildAdminNavItems(context),
          const Divider(color: Colors.grey, thickness: 2),
          _buildNavItem(Icons.key, 'Key Indicators', () {
            Get.toNamed('/key-indicators');
          }),
          _buildNavItem(Icons.table_chart, 'Data Entry', () {
            Get.toNamed('/data-entry');
          }),
          _buildNavItem(Icons.percent, 'Due Dilligence', () {
            Get.toNamed('/due-dilligence');
          }),
          _buildNavItem(Icons.edit_document, 'Agreement', () {
            Get.toNamed('/agreement');
          }),
          const Divider(color: Colors.grey, thickness: 2),
          _buildReportNavItems(context),
          const Divider(color: Colors.grey, thickness: 2),
          _buildNavItem(Icons.lock_open, 'Change Password', () {
            Get.toNamed('/change-password');
          }),
          _buildNavItem(Icons.chat, 'Chat with us', () async {
            String whatsappUrl =
                'https://wa.me/917710903515?text=masoom-support';
            if (!await launchUrl(Uri.parse(whatsappUrl))) {
              throw Exception('Could not launch $whatsappUrl');
            }
          }, isLink: true),
          _buildNavItem(Icons.power_settings_new, 'Log Out', () {
            UtilsWidgets.bottomDialogs(
              'Are you sure you want to logout?',
              'Alert',
              'No',
              'Yes',
              context,
              () => Navigator.of(context).pop(),
              () async {
                final pref = await SharedPreferences.getInstance();
                pref.clear();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LandingPage()),
                  (Route<dynamic> route) => false,
                );
              },
            );
          }, isLink: true),
        ],
      ),
    );
  }

  Widget _buildDrawer(ThemeController themeController, BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Image.asset('assets/images/logo.png', height: 60),
              ),
            ),
            const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Version: ',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('${Constants.appVersion}',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const Divider(thickness: 1),
            _buildNavItem(Icons.home, 'Dashboard', () {
              setState(() {
                selectedTab = 'Dashboard';
              });
              Navigator.pop(context);
            }),
            if (userRole == 'super_admin') _buildAdminNavItems(context),
            const Divider(color: Colors.grey, thickness: 2),
            _buildNavItem(Icons.key, 'Key Indicators', () {
              Get.toNamed('/key-indicators');
            }),
            _buildNavItem(Icons.table_chart, 'Data Entry', () {
              Get.toNamed('/data-entry');
            }),
            _buildNavItem(Icons.percent, 'Due Dilligence', () {
              Get.toNamed('/due-dilligence');
            }),
            _buildNavItem(Icons.edit_document, 'Agreement', () {
              Get.toNamed('/agreement');
            }),
            const Divider(color: Colors.grey, thickness: 2),
            _buildReportNavItems(context),
            const Divider(color: Colors.grey, thickness: 2),
            _buildNavItem(Icons.key, 'Change Password', () {
              Get.toNamed('/change-password');
              Navigator.pop(context);
            }),
            _buildNavItem(Icons.chat, 'Chat with us', () async {
              String whatsappUrl = 'https://wa.me/917304336515?text=hi';
              if (!await launchUrl(Uri.parse(whatsappUrl))) {
                throw Exception('Could not launch $whatsappUrl');
              }
            }, isLink: true),
            _buildNavItem(Icons.power_settings_new, 'Log Out', () {
              UtilsWidgets.bottomDialogs(
                'Are you sure you want to logout?',
                'Alert',
                'No',
                'Yes',
                context,
                () => Navigator.of(context).pop(),
                () async {
                  final pref = await SharedPreferences.getInstance();
                  pref.clear();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const LandingPage()),
                    (Route<dynamic> route) => false,
                  );
                },
              );
            }, isLink: true),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminNavItems(BuildContext context) {
    return Column(
      children: [
        if (userRole == 'super_admin')
          DecorationWidgets.buildExpandableNavItem(
            context,
            icon: Icons.storage,
            title: 'Master Data',
            children: [
              _buildNavItem(Icons.map, 'State', () {
                Get.toNamed('/state-list');
              }),
              _buildNavItem(Icons.location_city, 'District', () {
                Get.toNamed('/district-list');
              }),
              _buildNavItem(Icons.layers, 'Village', () {
                Get.toNamed('/village-list');
              }),
              _buildNavItem(Icons.calendar_today, 'Financial Year', () {
                Get.toNamed('/financial-list');
              }),
              _buildNavItem(Icons.business, 'Project', () {
                Get.toNamed('/project-list');
              }),
              _buildNavItem(Icons.volunteer_activism, 'Associate Project', () {
                Get.toNamed('/associate-project-list');
              }),
              _buildNavItem(Icons.attach_money, 'Budget', () {
                Get.toNamed('/budget-list');
              }),
              _buildNavItem(Icons.local_shipping, 'Vendor/NGO', () {
                Get.toNamed('/vendor-list');
              }),
              if (userRole == 'super_admin') ...[
                _buildNavItem(Icons.person, 'User', () {
                  Get.toNamed('/user-list');
                }),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildReportNavItems(BuildContext context) {
    return Column(
      children: [
        if (userRole == 'super_admin')
          DecorationWidgets.buildExpandableNavItem(
            context,
            icon: Icons.storage,
            title: 'Reports',
            initiallyExpanded: true,
            children: [
              _buildNavItem(Icons.summarize, 'Summary Report', () {
                Get.toNamed('/report-summary');
              }),
              _buildNavItem(Icons.account_balance, 'Budget Report', () {
                Get.toNamed('/report-budget');
              }),
              _buildNavItem(Icons.no_backpack, 'Beneficiary Report', () {
                Get.toNamed('/report-beneficiary');
              }),
              _buildNavItem(Icons.no_accounts, 'Non Beneficiary Report', () {
                Get.toNamed('/report-non-beneficiary');
              }),
            ],
          ),
      ],
    );
  }

  Widget _buildDashboardContent(
      bool isMobile, ThemeController themeController) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            isMobile
                ? Container()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        color: Get.isDarkMode
                            ? Constants.scaffoldBackgroundColor
                            : Constants.whiteColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[400],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  margin: const EdgeInsets.only(right: 12),
                                ),
                                const Text(
                                  'Dashboard',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Platform Metrics Summary",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          transitionBuilder: (child, animation) {
                            return RotationTransition(
                              turns: animation,
                              child: child,
                            );
                          },
                          child: IconButton(
                            key: ValueKey(themeController.isDarkMode.value),
                            icon: Icon(
                              themeController.isDarkMode.value
                                  ? Icons.nightlight_round
                                  : Icons.wb_sunny,
                            ),
                            color: themeController.isDarkMode.value
                                ? Colors.white
                                : Constants.secondaryColor,
                            iconSize: 24.0,
                            onPressed: () => themeController.toggleTheme(),
                            tooltip: themeController.isDarkMode.value
                                ? 'Dark Mode'
                                : 'Light Mode',
                          ),
                        ),
                      )
                    ],
                  ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 20,
              children: [
                ReportUtils.buildMetricCard(
                  context,
                  'Total Projects',
                  tempCount['user_code']?.toString() ?? '00',
                  Colors.green[400]!,
                  Icons.badge,
                  Colors.green[700]!,
                  themeController,
                ),
                ReportUtils.buildMetricCard(
                  context,
                  'Due Diligence\n Completed',
                  tempCount['course_code']?.toString() ?? '00',
                  Colors.indigo[400]!,
                  Icons.checklist,
                  Colors.indigo[700]!,
                  themeController,
                ),
                ReportUtils.buildMetricCard(
                  context,
                  'Agreement Completed',
                  tempCount['associate_project_code']?.toString() ?? '00',
                  Colors.amber[400]!,
                  Icons.book,
                  Colors.amber[700]!,
                  themeController,
                ),
                ReportUtils.buildMetricCard(
                  context,
                  'Upcoming Reports',
                  tempCount['vendor_code']?.toString() ?? '00',
                  Colors.red[400]!,
                  Icons.line_axis,
                  Colors.red[700]!,
                  themeController,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, VoidCallback onTap,
      {String subtitle = '', bool isLink = false}) {
    bool isSelected = selectedTab == title;
    bool isDarkMode = Get.isDarkMode;
    Color selectedIconColor = isDarkMode ? Colors.white : Colors.blue[700]!;
    Color unselectedIconColor =
        isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;
    Color selectedTextColor = isDarkMode ? Colors.white : Colors.blue[700]!;
    Color unselectedTextColor =
        isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;

    return InkWell(
      onTap: () {
        if (isLink) {
          onTap();
        } else {
          setState(() {
            selectedTab = title;
          });
        }
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (isSelected)
              Container(
                width: 4,
                height: 35,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white : Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            SizedBox(width: isSelected ? 12 : 16),
            Icon(
              icon,
              size: 20,
              color: isSelected ? selectedIconColor : unselectedIconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title + subtitle,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  color: isSelected ? selectedTextColor : unselectedTextColor,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  fontSize: 14,
                ),
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role') ?? '';
      currentDate = Utils.formatDate(DateTime.now(), 'yyyy-MM-dd');
    });
    if (userRole != '') {
      logoutSession();
      await getCountInfo();
    }
  }

  Future getCountInfo() async {
    try {
      String uri = Constants.USER_URL + '/count';
      Map params = {"vertical_code": 'Master'};
      Map<String, dynamic> tempMap = await apiController.fetchData(uri, params);
      setState(() {
        tempCount.clear();
        if (tempMap['isValid']) {
          tempCount = tempMap['info'];
        } else {
          UtilsWidgets.showToastFunc(tempMap['message'] ?? '');
        }
      });
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  logoutSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String login = prefs.getString('login') ?? currentDate;

    if (prefs.getString('login') == null) {
      prefs.setString('login', currentDate);
    }

    DateTime dt1 = DateTime.parse(currentDate);
    DateTime dt2 = DateTime.parse(login);

    if (dt1.difference(dt2).inDays > 7) {
      prefs.clear();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LandingPage()),
        (Route<dynamic> route) => false,
      );
    }
  }
}
