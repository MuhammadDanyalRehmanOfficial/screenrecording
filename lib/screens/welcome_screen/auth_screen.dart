import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soylephone_user/screens/welcome_screen/welcome_screen.dart';
import 'package:soylephone_user/utils/app_colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColor.darkBlueColor1,
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
              text: 'Welcome to SÖILEPHONE!'.tr,
              fontSize: 48,
              color: AppColor.white,
            ),
            SizedBox(height: size.height * 0.09),
            CustomButton(
              text: 'Create Account'.tr,
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              color: AppColor.yellow,
              textColor: AppColor.blackColor,
            ),
            SizedBox(height: size.height * 0.02),
            CustomButton(
              text: 'Sign In'.tr,
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              color: AppColor.yellow,
              textColor: AppColor.blackColor,
            ),
          ],
        ),
      )),
    );
  }
}
