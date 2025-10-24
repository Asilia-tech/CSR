import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/routes.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:sterlite_csr/screens/master/indicator/data_entry.dart';
import 'package:sterlite_csr/screens/home_screen.dart';
import 'package:sterlite_csr/theme/theme_controller.dart';
import 'package:sterlite_csr/theme/theme_utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ThemeController themeController = Get.put(ThemeController());
  await themeController.loadThemeFromPrefs();
  usePathUrlStrategy();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (controller) {
      return GetMaterialApp(
        title: Constants.APPNAME,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode:
            controller.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
        routes: AppRoutes.routes,
      );
    });
  }
}
