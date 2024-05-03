import 'package:flutter/material.dart';

import '../screens/welcome_screen/welcome_screen.dart';
import 'app_colors.dart';

class AppUtils {
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColor.yellow,
        elevation: 4,
        content: CustomText(
          text: message,
          fontSize: 24,
          color: AppColor.darkBlueColor1,
        ),
      ),
    );
  }
}
