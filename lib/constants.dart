import 'package:flutter/material.dart';

class Constants {
  static String CLIENTNAME = 'CEO';
  static String APPNAME = 'Sterlite CSR';
  static const appVersion = '1.3.0';

  static Color primaryColor = Color.fromARGB(255, 8, 51, 68);
  static Color secondaryColor = Color.fromARGB(255, 6, 182, 212);
  static Color ternaryColor = Color.fromARGB(255, 20, 184, 166);
  static Color quartaryColor = Color.fromARGB(255, 21, 94, 117);

  static Color blackColor = Color.fromARGB(255, 0, 0, 0);
  static Color greyColor = Color.fromARGB(175, 175, 175, 175);
  static Color whiteColor = Color.fromARGB(255, 255, 255, 255);
  static Color redColor = Color.fromARGB(174, 216, 11, 11);
  static Color greenColor = Color.fromARGB(255, 13, 109, 6);
  static Color canvasColor = Color(0xFF1E293B);
  static Color scaffoldBackgroundColor = Color(0xFF464667);
  static Color accentCanvasColor = Color(0xFF3E3E61);
  static Color actionColor = Color(0xFF5F5FA7).withOpacity(0.6);
  static const Color background = Color.fromARGB(255, 240, 244, 244);

  static const Color group1_deep = Color(0xFF1E3A8A);
  static const Color group1_light = Color(0xFFBFDBFE);
  static const Color group2_deep = Color(0xFF4D7C0F);
  static const Color group2_light = Color(0xFFD9F99D);
  static const Color group3_deep = Color(0xFFD97706);
  static const Color group3_light = Color(0xFFFDE047);
  static const Color group4_deep = Color(0xFFBE185D);
  static const Color group4_light = Color(0xFFFBCFE8);
  static const Color group5_deep = Color(0xFFE11D48);
  static const Color group5_light = Color(0xFFFECDD3);

  static List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  static String errorMessage =
      'Something went wrong. Please contact admiministrator.';

  static String errorCatch = 'Failed to load data. Please try again later.';

  static String errorConnection =
      'No internet connection. Please check your internet connection.';

  static String ADMIN_URL =
      'https://dfvaw0kvrg.execute-api.ap-south-1.amazonaws.com/prod';
  static String MASTER_URL =
      'https://hr7qeioevi.execute-api.ap-south-1.amazonaws.com/prod';
  static String USER_URL =
      'https://gqogettv12.execute-api.ap-south-1.amazonaws.com/prod';
  static String OPERATION_URL =
      'https://rd4c6xnvc2.execute-api.ap-south-1.amazonaws.com/prod';
  static String BULK_URL =
      'https://4ussigez8l.execute-api.ap-south-1.amazonaws.com/prod';
  static String RESOURCE_URL =
      'https://y8ss6nl5hk.execute-api.ap-south-1.amazonaws.com/prod/masoomdata';
}
