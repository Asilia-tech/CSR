import 'package:flutter/material.dart';
import 'package:sterlite_csr/screens/404_screen.dart';
import 'package:sterlite_csr/screens/change_password.dart';
import 'package:sterlite_csr/screens/home_screen.dart';
import 'package:sterlite_csr/screens/landing_screen.dart';
import 'package:sterlite_csr/screens/login_screen.dart';
import 'package:sterlite_csr/screens/master/budget/budget_list.dart';
import 'package:sterlite_csr/screens/master/district/district_list.dart';
import 'package:sterlite_csr/screens/master/due_dilligence/due_diligence_list.dart';
import 'package:sterlite_csr/screens/master/financial/financial_list.dart';
import 'package:sterlite_csr/screens/master/project/project_list.dart';
import 'package:sterlite_csr/screens/master/state/state_list.dart';
import 'package:sterlite_csr/screens/master/user/user_list.dart';
import 'package:sterlite_csr/screens/master/vendor/vendor_list.dart';
import 'package:sterlite_csr/screens/master/village/village_list.dart';
import 'package:sterlite_csr/screens/master/associate_project/associate_project_list.dart';
import 'package:sterlite_csr/screens/reports/beneficiary_page.dart';
import 'package:sterlite_csr/screens/reports/budget_page.dart';
import 'package:sterlite_csr/screens/reports/non_beneficiary_page.dart';
import 'package:sterlite_csr/screens/reports/summary_page.dart';

class AppRoutes {
  static final Map<String, Widget> _screens = {
    'login': const LoginPage(),
    'home': const HomePage(),
    'loading': const LandingPage(),
    '404': const Flutter404Page(),
    'change-password': const ChangePasswordPage(),
    'state-list': const StateList(),
    'district-list': const DistrictList(),
    'village-list': const VillageList(),
    'financial-list': const FinancialList(),
    'project-list': const ProjectList(),
    'associate-project-list': const AssociateProjectList(),
    'vendor-list': const VendorList(),
    'user-list': const UserList(),
    'budget-list': const BudgetList(),
    'reports': const Flutter404Page(),
    'key-indicators': const Flutter404Page(),
    'data-entry': const Flutter404Page(),
    'due-dilligence': DueDiligenceList(),
    'agreement': const Flutter404Page(),
    'report-summary': SummaryPage(),
    'report-budget': BudgetPage(),
    'report-beneficiary': BeneficiaryPage(),
    'report-non-beneficiary': NonBeneficiaryPage(),
  };

  // Display names mapped to their internal route keys
  static final Map<String, String> _tabToRouteKey = {
    'Dashboard': 'home',
    'State': 'state-list',
    'District': 'district-list',
    'Village': 'village-list',
    'Financial Year': 'financial-list',
    'Project': 'project-list',
    'Associate Project': 'associate-project-list',
    'Vendor/NGO': 'vendor-list',
    'User': 'user-list',
    'Budget': 'budget-list',
    'Change Password': 'change-password',
    'Reports': 'reports',
    'Key Indicators': 'key-indicators',
    'Data Entry': 'data-entry',
    'Due Dilligence': 'due-dilligence',
    'Agreement': 'agreement',
    'Summary Report': 'report-summary',
    'Budget Report': 'report-budget',
    'Beneficiary Report': 'report-beneficiary',
    'Non Beneficiary Report': 'report-non-beneficiary',
  };

  static Map<String, Widget Function(BuildContext)> get routes {
    return Map.fromEntries(
      _screens.entries.map(
        (entry) => MapEntry(
          '/${entry.key}',
          (BuildContext context) => entry.value,
        ),
      ),
    );
  }

  // Get screen by tab name
  static Widget getSelectedScreen(String selectedTab) {
    final routeKey = _tabToRouteKey[selectedTab];
    return _screens[routeKey] ?? _screens['home'] ?? const Flutter404Page();
  }

  static Route createPopupRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 1000),
      reverseTransitionDuration: const Duration(milliseconds: 1000),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Scale Transition
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInCubic)),
          child: child,
        );
      },
    );
  }

  static Route createFadeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Fade Transition
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}
