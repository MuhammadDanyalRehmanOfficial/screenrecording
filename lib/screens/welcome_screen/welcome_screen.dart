import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColor.darkBlueColor1,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.asset(
                'assets/icon.jpg',
                fit: BoxFit.contain,
                width: size.width * 1,
                height: size.height * 0.6,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButton(
                      text: 'Қазақша',
                      onPressed: () async {
                        await saveLanguage('kk', 'KZ');
                        Get.updateLocale(Locale('kk', 'KZ'));
                        Navigator.pushReplacementNamed(context, '/auth');
                      },
                      color: AppColor.yellow,
                      textColor: AppColor.blackColor,
                    ),
                    CustomButton(
                      text: 'Русский',
                      onPressed: () async {
                        await saveLanguage('ru', 'RU');
                        Get.updateLocale(Locale('ru', 'RU'));
                        Navigator.pushReplacementNamed(context, '/auth');
                      },
                      color: AppColor.yellow,
                      textColor: AppColor.blackColor,
                    ),
                    CustomButton(
                      text: 'English',
                      onPressed: () async {
                        await saveLanguage('en', 'US');
                        Get.updateLocale(Locale('en', 'US'));
                        Navigator.pushReplacementNamed(context, '/auth');
                      },
                      color: AppColor.yellow,
                      textColor: AppColor.blackColor,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveLanguage(String languageCode, String countryCode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('language', '$languageCode-$countryCode');
  }
}

class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.color,
  });
  final String text;
  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.color,
    required this.textColor,
  });
  final String text;
  final Color color;
  final Color textColor;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(color),
      ).merge(ElevatedButton.styleFrom(
        minimumSize: const Size(250, 50),
      )),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 24,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
