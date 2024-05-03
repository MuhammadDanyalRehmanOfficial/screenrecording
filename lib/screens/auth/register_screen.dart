import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:soylephone_user/screens/auth/auth_service.dart';
import 'package:soylephone_user/screens/welcome_screen/welcome_screen.dart';
import 'package:soylephone_user/utils/app_colors.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../utils/app_utils.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _idcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  final TextEditingController _conformcontroller = TextEditingController();

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
    var sizes = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColor.darkBlueColor1,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  text: 'Create new account!'.tr,
                  fontSize: 32,
                  color: AppColor.white,
                ),
                SizedBox(height: sizes.height * 0.02),
                _buildRoleDropdown(),
                SizedBox(height: sizes.height * 0.02),
                CustomRowText(
                  size: 0.19,
                  controller: _idcontroller,
                  text: 'ID Number'.tr,
                  color: Colors.yellow, // Change to your desired text color
                  width: 0.5,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    _selectedRole == "Military".tr
                        ? maskFormatterMilitary
                        : maskFormatterPrision
                  ],
                ),
                SizedBox(height: sizes.height * 0.02),
                CustomRowText(
                  size: 0.2,
                  controller: _passwordcontroller,
                  text: 'Password'.tr,
                  color: Colors.yellow, // Change to your desired text color
                  width: 0.5,
                  keyboardType: TextInputType.visiblePassword,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                  ],
                ),
                SizedBox(height: sizes.height * 0.02),
                CustomRowText(
                  size: 0.03,
                  controller: _conformcontroller,
                  text: 'Confirm Password'.tr,
                  color: Colors.yellow, // Change to your desired text
                  width: 0.5,
                  keyboardType: TextInputType.visiblePassword,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                  ],
                ),
                SizedBox(height: sizes.height * 0.02),
                CustomButton(
                  text: 'Register'.tr,
                  onPressed: () {
                    register();
                    // Navigator.pushReplacementNamed(context, '/addContact',
                    //     arguments: _selectedRole);
                    print(_idcontroller.text);
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
          width: sizes.width * 0.32,
        ),
        Container(
          alignment: Alignment.center,
          width: sizes.width * 0.5,
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

  Future<void> register() async {
    final String idNumber = _idcontroller.text.trim();
    final String password = _passwordcontroller.text.trim();
    final String confirmPassword = _conformcontroller.text.trim();

    if (idNumber.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        _selectedRole == 'Choose your role') {
      AppUtils.showSnackBar(context, 'Please fill all the fields.');
    } else {
      if (password != confirmPassword) {
        AppUtils.showSnackBar(
            context, 'Please make sure the passwords match. 🔑');
      } else {
        // Instantiate the AuthService
        AuthService authService = AuthService();
        try {
          User? user = await authService.register(idNumber, password);
          if (user != null) {
            // You can now save the user data in the UserData singleton
            UserData().setUser(user);
            print(user.token);
            AppUtils.showSnackBar(context, 'Register successful!');
            Navigator.pushReplacementNamed(context, '/addContact',
                arguments: _selectedRole);
          } else {
            // Login failed, handle the error
            AppUtils.showSnackBar(
                context, 'Register failed. Please try again.');
          }
        } catch (e) {
          // Handle network errors or other exceptions
          AppUtils.showSnackBar(context, 'Error: $e');
        }
      }
    }
  }
}

class CustomRowText extends StatelessWidget {
  const CustomRowText({
    super.key,
    required this.size,
    required this.controller,
    required this.text,
    required this.color,
    required this.width,
    required this.keyboardType,
    required this.inputFormatters,
  });

  final double size;
  final TextEditingController controller;
  final String text;
  final double width;
  final Color color;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;

  @override
  Widget build(BuildContext context) {
    var sizes = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomText(
          text: text,
          fontSize: 18,
          color: AppColor.white,
        ),
        SizedBox(
          width: sizes.width * size,
        ),
        CustomTextField(
          width: width,
          controller: controller,
          hint: text,
          color: color,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
        ),
      ],
    );
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.color,
    required this.width,
    required this.keyboardType,
    required this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final Color color;
  final TextInputType keyboardType;
  final double width;
  final List<TextInputFormatter> inputFormatters;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width * width,
      height: size.height * 0.08,
      child: TextFormField(        
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          filled: true,
          fillColor: color,
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColor.blackColor,
          ),
          border: const OutlineInputBorder(),
        ),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColor.blackColor1,
        ),
      ),
    );
  }
}
