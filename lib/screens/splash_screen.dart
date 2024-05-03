import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soylephone_user/utils/app_colors.dart';

import '../utils/app_utils.dart';
import 'auth/auth_service.dart';

String? finaltoken;
String? language;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    // getValidationData();
    // Add this line to start the animation after a 1-second delay
    Future.delayed(Duration(seconds: 1), () {
      _animationController.forward();
    });

    // Add this line to introduce a 3-second delay before navigating
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/welcome');
      // nextScreen();
    });
  }

  // user relogin
  Future<void> nextScreen() async {
    if (finaltoken == null) {
      Navigator.pushReplacementNamed(context, '/welcome');
    } else {
      if (language != null) {
        Get.updateLocale(
            Locale(language!.split('-')[0], language!.split('-')[1]));
      }
      AuthService authService = AuthService();
      User? user = await authService.getUserData(finaltoken!);
      // You can now save the user data in the UserData singleton
      UserData().setUser(user!);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', UserData().user!.token);
      // Navigate to the home screen or perform other actions
      AppUtils.showSnackBar(context, 'Welcome Back!');
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  Future getValidationData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLanguage = prefs.getString('language');
    setState(() {
      language = savedLanguage;
    });
    String? token = prefs.getString('token');
    setState(() {
      finaltoken = token;
    });
    print(finaltoken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.darkBlueColor1,
      body: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Image.asset(
            'assets/icon.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
