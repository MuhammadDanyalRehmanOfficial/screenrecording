import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'utils/app_colors.dart';
import 'utils/firebase_utils.dart';
import 'utils/translations.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/call/call_other_screen.dart';
import 'screens/call/incoming_call_screen.dart';
import 'screens/contact/add_contact_screen.dart';
import 'screens/contact/confirm_screen.dart';
import 'screens/favorite/favorite_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen/welcome_screen.dart';
import 'screens/welcome_screen/auth_screen.dart';
import 'firebase_options.dart';

String channelName = '';
String token = '';
int uid = 0; // uid of the local user

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseUtils().initNotifications();
  runApp(const SoilephoneUser());
}

class SoilephoneUser extends StatelessWidget {
  const SoilephoneUser({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColor.darkBlueColor1,
      systemNavigationBarColor: AppColor.darkBlueColor1,
    ));

    // screen layouts
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    return GetMaterialApp(
      translations: TranslationService.instance,
      locale: Locale('en', 'US'),
      fallbackLocale: Locale('en', 'US'),
      title: 'Soilephone User',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/welcome': (context) => const LanguageScreen(),
        '/auth': (context) => const AuthScreen(),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/addContact': (context) => const AddContactScreen(),
        '/confirm': (context) => const ConfirmScreen(),
        '/home': (context) => const HomeScreen(),
        '/favorie': (context) => const FavoriteScreen(),
        '/callUsers': (context) => const CallUserScreen(),
        '/incomingCall': (context) => const IncomingCallScreen(),
      },
    );
  }
}
