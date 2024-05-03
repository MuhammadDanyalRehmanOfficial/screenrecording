import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soylephone_user/screens/welcome_screen/welcome_screen.dart';

import '../../utils/app_colors.dart';

class ConfirmScreen extends StatefulWidget {
  const ConfirmScreen({super.key});

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.darkBlueColor1,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: 'Contacts Saved!'.tr,
                fontSize: 64,
                color: AppColor.white,
              ),
              CustomButton(
                text: 'Login'.tr,
                onPressed: () {
                  // goto login

                  Navigator.pushReplacementNamed(context, '/login');
                },
                color: AppColor.yellow,
                textColor: AppColor.blackColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
