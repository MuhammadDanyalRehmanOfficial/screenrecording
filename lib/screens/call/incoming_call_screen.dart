import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../auth/auth_service.dart';
import '../welcome_screen/welcome_screen.dart';
import 'package:soylephone_user/main.dart';
import 'video_call_screen.dart';

class IncomingCallScreen extends StatefulWidget {
  const IncomingCallScreen({super.key});

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  @override
  Widget build(BuildContext context) {
    final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage;
    return Scaffold(
      backgroundColor: AppColor.darkBlueColor1,
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // body
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 8),
            width: 300,
            child: Column(
              children: [
                CustomText(
                  text: 'Incoming Video Call From'.tr,
                  fontSize: 32,
                  color: AppColor.white,
                ),
                CustomText(
                  text: '${message.notification?.body}',
                  fontSize: 32,
                  color: AppColor.white,
                ),
              ],
            ),
          ),
          // bottom
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  // video / voice call functionality
                  channelName = message.data['channel_name'];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoCallScreen(
                        isUser: false,
                        name: '${message.notification?.body}',
                        userId: UserData().user!.idNumber,
                      ),
                    ),
                  );
                },
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(AppColor.green),
                ).merge(ElevatedButton.styleFrom(
                  minimumSize: const Size(150, 50),
                )),
                child: const Text(
                  'ACCEPT',
                  style: TextStyle(
                    fontSize: 22,
                    color: AppColor.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // video / voice call functionality
                  Navigator.pop(context);
                },
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(AppColor.red),
                ).merge(ElevatedButton.styleFrom(
                  minimumSize: const Size(150, 50),
                )),
                child: const Text(
                  'DECLINE',
                  style: TextStyle(
                    fontSize: 22,
                    color: AppColor.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      )),
    );
  }
}
