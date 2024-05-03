import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soylephone_user/screens/auth/register_screen.dart';
import 'package:soylephone_user/screens/welcome_screen/welcome_screen.dart';
import 'package:soylephone_user/utils/app_colors.dart';
import 'package:soylephone_user/utils/app_utils.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();

  String? _selectedRole = 'Choose your role'.tr;

  @override
  Widget build(BuildContext context) {
    var maskFormatterMilitary = MaskTextInputFormatter(
      mask: '#####-####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.eager,
    );
    var maskFormatterPrision = MaskTextInputFormatter(
      mask: '###-####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.eager,
    );
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColor.darkBlueColor1,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  text: 'Login to your account'.tr,
                  fontSize: 32,
                  color: AppColor.white,
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                _buildRoleDropdown(),
                SizedBox(
                  height: size.height * 0.02,
                ),
                CustomRowText(
                  size: 0.05,
                  controller: _idcontroller,
                  text: 'ID Number'.tr,
                  color: AppColor.yellow,
                  width: 0.6,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    _selectedRole == "Military".tr
                        ? maskFormatterMilitary
                        : maskFormatterPrision
                  ],
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                CustomRowText(
                  size: 0.06,
                  controller: _passwordcontroller,
                  text: 'Password'.tr,
                  color: AppColor.yellow,
                  width: 0.6,
                  keyboardType: TextInputType.visiblePassword,
                  inputFormatters: [],
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                CustomButton(
                  text: 'Login'.tr,
                  onPressed: () {
                    login();
                  },
                  color: AppColor.yellow,
                  textColor: AppColor.blackColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    var sizes = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomText(
          text: 'Role'.tr,
          fontSize: 18,
          color: AppColor.white,
        ),
        SizedBox(
          width: sizes.width * 0.18,
        ),
        Container(
          alignment: Alignment.center,
          width: sizes.width * 0.6,
          decoration: BoxDecoration(
            color: AppColor.yellow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: _selectedRole,
            dropdownColor: AppColor.yellow,
            onChanged: (String? newValue) {
              setState(() {
                _selectedRole = newValue;
              });
            },
            items: <String>['Choose your role'.tr, 'Military'.tr, 'Prisoner'.tr]
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: CustomText(
                  text: value,
                  fontSize: 16,
                  color: AppColor.blackColor,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<void> login() async {
    final String idNumber = _idcontroller.text.trim();
    final String password = _passwordcontroller.text.trim();

    // Check if any field is empty or null
    if (idNumber.isEmpty || password.isEmpty) {
      AppUtils.showSnackBar(context, 'Please fill all the fields.');
    } else {
      // Instantiate the AuthService
      AuthService authService = AuthService();
      try {
        User? user = await authService.login(idNumber, password);
        if (user != null) {
          // You can now save the user data in the UserData singleton
          UserData().setUser(user);
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('token', UserData().user!.token);
          final token = await FirebaseMessaging.instance.getToken();
          print(token);
          await authService.updateFCMToken(UserData().user!.token, token!);
          // Navigate to the home screen or perform other actions
          AppUtils.showSnackBar(context, 'Login successful!'.tr);
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // Login failed, handle the error
          AppUtils.showSnackBar(context, 'Login failed. Please try again.');
        }
      } catch (e) {
        // Handle network errors or other exceptions
        AppUtils.showSnackBar(context, 'Error: $e');
      }
    }
  }
}
