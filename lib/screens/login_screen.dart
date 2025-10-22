import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/utilities/api-service.dart';
import 'package:sterlite_csr/utilities/function_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool isObscure = true;
  APIController apiController = Get.put(APIController());
  TextEditingController phoneController = TextEditingController();
  TextEditingController passController = TextEditingController();
  FocusNode _usernameFocus = FocusNode();
  FocusNode _passwordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Form(
            key: _formKey,
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isDesktop = constraints.maxWidth < 600;
                  return Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child: Column(
                          children: [
                            isDesktop
                                ? Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Align(
                                        alignment: Alignment.topCenter,
                                        child: Image.asset(
                                            'assets/images/logo.png',
                                            height: 100)),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Image.asset(
                                            'assets/images/logo.png',
                                            height: 60)),
                                  ),
                            Center(
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                width: 400,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        'Sign in',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Username',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                        TextFormField(
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter your username';
                                            } else if (value.length < 5 ||
                                                value.length > 50) {
                                              return "email address must be between 05-50 characters";
                                            }
                                          },
                                          controller: phoneController,
                                          focusNode: _usernameFocus,
                                          textInputAction: TextInputAction.next,
                                          onFieldSubmitted: (_) {
                                            FocusScope.of(context)
                                                .requestFocus(_passwordFocus);
                                          },
                                          keyboardType: TextInputType.text,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700),
                                          decoration: const InputDecoration(
                                            hintText: 'Enter your username',
                                            prefixIcon:
                                                Icon(Icons.person_outline),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Password',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                        TextFormField(
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter your password';
                                            }
                                          },
                                          controller: passController,
                                          focusNode: _passwordFocus,
                                          textInputAction: TextInputAction.done,
                                          onFieldSubmitted: (_) async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              await userLogin(context);
                                            }
                                          },
                                          keyboardType: TextInputType.text,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700),
                                          obscureText: isObscure,
                                          decoration: InputDecoration(
                                            hintText: 'Enter your password',
                                            prefixIcon:
                                                Icon(Icons.lock_outline),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                isObscure
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  isObscure = !isObscure;
                                                });
                                              },
                                            ),
                                            enabledBorder:
                                                const UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 40),
                                    apiController.isLoading.value
                                        ? Center(
                                            child: CircularProgressIndicator(
                                                color: Constants.primaryColor))
                                        : SizedBox(
                                            width: 350,
                                            height: 50,
                                            child: Card(
                                              elevation: 10,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25)),
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    await userLogin(context);
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Constants.primaryColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Login',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                    const SizedBox(height: 20),
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '© Powered by Sterlite EdIndia Foundation',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    const Text(
                                      "Ver " + Constants.appVersion,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      isDesktop
                          ? Container()
                          : Flexible(
                              flex: 2,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50)),
                                elevation: 10,
                                child: Image.asset('assets/images/login.jpg',
                                    fit: BoxFit.cover),
                              ),
                            ),
                    ],
                  );
                },
              ),
            ),
          )),
    );
  }

  Future userLogin(context) async {
    try {
      String url = Constants.ADMIN_URL + '/login';
      Map param = {
        "email_id": phoneController.text.trim(),
        "password": passController.text.trim()
      };

      Map<String, dynamic> verifyMap =
          await apiController.fetchData(url, param);

      if (verifyMap['isValid']) {
        Map<String, dynamic> info = verifyMap['info'];
        SharedPreferences prefs = await SharedPreferences.getInstance();

        Utils.storeMapInPrefs(info, "user_detail");
        prefs.setString('user_id', info['user_id']);
        prefs.setString('role', info['role']);
        prefs.setString('email_id', info['email_id']);
        Utils.storeMapInPrefs(info['access_control'], "access_control");

        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);

        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const HomePage()),
        // );
      } else {
        UtilsWidgets.showGetDialog(context,
            verifyMap['message'] ?? "Login Failed", Constants.redColor);
      }
    } catch (e) {
      UtilsWidgets.showToastFunc(Constants.errorMessage);
    }
  }
}
