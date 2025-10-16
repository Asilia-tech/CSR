import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'package:sterlite_csr/screens/landing_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sterlite_csr/utilities/function_utils.dart';
import 'package:sterlite_csr/utilities/method_utils.dart';
import 'package:sterlite_csr/utilities/widget_utils.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool isObscure = true;
  bool isNewPasswordObscure = true;
  bool isConfirmPasswordObscure = true;

  // Controllers for different steps
  TextEditingController emailController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  // Step tracking: 0 = email verification, 1 = OTP verification, 2 = new password
  int currentStep = 0;
  String verifiedEmail = '';

  String? userName;
  String? sentOTP;

  String? verifiedUserId;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: LayoutBuilder(builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth < 600;
        return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: UtilsWidgets.buildAppBar(
              'Change Password',
              Get.isDarkMode,
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
            ),
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
                                        child: SizedBox.shrink(),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: SizedBox.shrink(),
                                      ),
                                    ),
                              Center(
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                  width: 400,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          _getStepTitle(),
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      _buildCurrentStepWidget(),
                                      const SizedBox(height: 40),
                                      // Action button
                                      _isLoading
                                          ? Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : SizedBox(
                                              width: 350,
                                              height: 50,
                                              child: Card(
                                                elevation: 10,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                ),
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      await _handleCurrentStep();
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Constants.primaryColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    _getButtonText(),
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                      const SizedBox(height: 20),

                                      // Back button for steps 1 and 2
                                      if (currentStep > 0)
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              currentStep--;
                                            });
                                          },
                                          child: Text(
                                            'Back',
                                            style: TextStyle(
                                              color: Constants.primaryColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),

                                      // Footer text
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
                                  child: Image.asset(
                                      'assets/images/changepassword.jpg',
                                      fit: BoxFit.cover),
                                ),
                              ),
                      ],
                    );
                  },
                ),
              ),
            ));
      }),
    );
  }

  String _getStepTitle() {
    switch (currentStep) {
      case 0:
        return '';
      case 1:
        return 'Enter OTP';
      case 2:
        return 'Set New Password';
      default:
        return 'Change Password';
    }
  }

  String _getButtonText() {
    switch (currentStep) {
      case 0:
        return 'Send OTP';
      case 1:
        return 'Verify OTP';
      case 2:
        return 'Update Password';
      default:
        return 'Continue';
    }
  }

  Widget _buildCurrentStepWidget() {
    switch (currentStep) {
      case 0:
        return _buildEmailStep();
      case 1:
        return _buildOTPStep();
      case 2:
        return _buildNewPasswordStep();
      default:
        return _buildEmailStep();
    }
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email', style: TextStyle(fontSize: 12, color: Colors.grey)),
        TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            } else if (Utils.validateInput(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$', value)) {
              return 'Please enter a valid email_id address';
            }
            return null;
          },
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: 'Enter your email',
            prefixIcon: Icon(Icons.email_outlined),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOTPStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('OTP sent to ${verifiedEmail}',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 10),
        Text('Enter 6-digit OTP',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter OTP';
            }
            if (value.length != 6) {
              return 'OTP must be 6 digits';
            }
            return null;
          },
          controller: otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: 'Enter OTP',
            prefixIcon: Icon(Icons.security),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            counterText: '', // Hide character counter
          ),
        ),
      ],
    );
  }

  Widget _buildNewPasswordStep() {
    final alphanumericRegExp = RegExp(r'^[a-zA-Z0-9]+$');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('New Password',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter new password';
            }
            if (value.length < 7) {
              return 'Password must be at least 7 characters';
            }
            if (!alphanumericRegExp.hasMatch(value)) {
              return 'Password can contain only letters and numbers';
            }
            return null;
          },
          controller: newPasswordController,
          obscureText: isNewPasswordObscure,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: 'Enter new password',
            prefixIcon: Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(isNewPasswordObscure
                  ? Icons.visibility_off
                  : Icons.visibility),
              onPressed: () {
                setState(() {
                  isNewPasswordObscure = !isNewPasswordObscure;
                });
              },
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Confirm Password',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != newPasswordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
          controller: confirmPasswordController,
          obscureText: isConfirmPasswordObscure,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: 'Confirm new password',
            prefixIcon: Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(isConfirmPasswordObscure
                  ? Icons.visibility_off
                  : Icons.visibility),
              onPressed: () {
                setState(() {
                  isConfirmPasswordObscure = !isConfirmPasswordObscure;
                });
              },
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Future _handleCurrentStep() async {
    switch (currentStep) {
      case 0:
        await _verifyEmail();
        break;
      case 1:
        await _verifyOTP();
        break;
      case 2:
        await _updatePassword();
        break;
    }
  }

  Future _verifyEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userEmail = prefs.getString('email_id') ?? "";

      if (userEmail == emailController.text.trim()) {
        String uri = Constants.ADMIN_URL + '/verify';
        Map params = {"email_id": emailController.text.trim()};

        Map verifyMap = await MethodUtils.apiCall(uri, params);

        if (verifyMap['isValid']) {
          if (verifyMap['info'] != null) {
            verifiedUserId = verifyMap['info']['user_id']?.toString();
            userName = verifyMap['info']['name']?.toString();
          }
          if (verifiedUserId == null || verifiedUserId!.isEmpty) {
            UtilsWidgets.showGetDialog(
                context,
                "Failed to get user information. Please try again.",
                Constants.redColor);
            return;
          }
          await _sendOTP();
        } else {
          UtilsWidgets.showGetDialog(context,
              verifyMap['message'] ?? "Email not found", Constants.redColor);
        }
      } else {
        UtilsWidgets.showGetDialog(
            context, "Email not found", Constants.redColor);
      }
    } catch (e) {
      UtilsWidgets.showToastFunc(Constants.errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future _sendOTP() async {
    setState(() {
      sentOTP = Utils.generateOTP();
    });

    try {
      String uri = Constants.ADMIN_URL + '/email_otp';
      Map params = {
        "email": emailController.text.trim(),
        "otp": sentOTP,
        "name": userName ?? "User"
      };

      Map otpMap = await MethodUtils.apiCall(uri, params);

      if (otpMap['isValid']) {
        setState(() {
          verifiedEmail = emailController.text.trim();
          currentStep = 1;
        });
        UtilsWidgets.showGetDialog(
            context, "OTP sent to your email", Constants.greenColor);
      } else {
        UtilsWidgets.showGetDialog(context,
            otpMap['message'] ?? "Failed to send OTP", Constants.redColor);
      }
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    }
  }

  Future _verifyOTP() async {
    setState(() {
      _isLoading = true;
    });
    try {
      String enteredOTP = otpController.text.trim();

      if (sentOTP != null && enteredOTP == sentOTP) {
        setState(() {
          currentStep = 2;
        });
        UtilsWidgets.showGetDialog(
            context, "OTP verified successfully", Constants.greenColor);
      } else {
        UtilsWidgets.showGetDialog(context,
            "Invalid OTP. Please enter the correct OTP.", Constants.redColor);
      }
    } catch (e) {
      UtilsWidgets.showToastFunc(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future _updatePassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (verifiedUserId == null || verifiedUserId!.isEmpty) {
        UtilsWidgets.showGetDialog(
            context,
            "User verification failed. Please start again.",
            Constants.redColor);
        setState(() {
          currentStep = 0;
          verifiedUserId = null;
          verifiedEmail = '';
        });
        return;
      }

      String uri = Constants.ADMIN_URL + '/forgetpassword';

      Map params = {
        "user_id": verifiedUserId,
        "password": newPasswordController.text.trim()
      };
      Map updateMap = await MethodUtils.apiCall(uri, params);

      if (updateMap['isValid']) {
        setState(() {
          _isLoading = false;
        });
        String message = updateMap['message'];
        Get.defaultDialog(
            middleText: message,
            barrierDismissible: false,
            contentPadding: EdgeInsets.all(15),
            backgroundColor: Constants.whiteColor,
            titleStyle: TextStyle(
                color: Constants.primaryColor, fontWeight: FontWeight.bold),
            middleTextStyle: TextStyle(color: Colors.black),
            confirm: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: () async {
                  _clearFormData();
                  final pref = await SharedPreferences.getInstance();
                  await pref.clear();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const LandingPage()),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
                child: Text("Ok",
                    style: TextStyle(
                        color: Constants.whiteColor,
                        fontWeight: FontWeight.bold))),
            radius: 20);
      } else {
        UtilsWidgets.showGetDialog(
            context,
            updateMap['message'] ?? "Failed to update password",
            Constants.redColor);
      }
    } catch (e) {
      UtilsWidgets.showGetDialog(
          context, "An error occurred. Please try again.", Constants.redColor);
    } finally {
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearFormData() {
    verifiedUserId = null;
    verifiedEmail = '';
    userName = null;
    sentOTP = null;
    currentStep = 0;
    emailController.clear();
    otpController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
