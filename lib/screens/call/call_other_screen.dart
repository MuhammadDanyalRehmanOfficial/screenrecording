// import 'dart:io';

// import 'package:ed_screen_recorder/ed_screen_recorder.dart';
// import 'package:device_screen_recorder/device_screen_recorder.dart';
// import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:soylephone_user/screens/auth/auth_service.dart';
import 'package:soylephone_user/screens/call/video_call_screen.dart';
import 'package:soylephone_user/screens/welcome_screen/welcome_screen.dart';
import 'package:soylephone_user/utils/app_colors.dart';
import '../../main.dart';
import '../auth/register_screen.dart';
import 'call_service.dart';

String path = "";

class CallUserScreen extends StatefulWidget {
  const CallUserScreen({Key? key}) : super(key: key);

  @override
  State<CallUserScreen> createState() => _CallUserScreenState();
}

class _CallUserScreenState extends State<CallUserScreen> {
  final TextEditingController _idcontroller = TextEditingController();
  final TextEditingController _codecontroller = TextEditingController();

  // bool recording = false;
  // EdScreenRecorder? screenRecorder;

  @override
  void initState() {
    super.initState();

    requestPermissions();
    // screenRecorder = EdScreenRecorder();
  }

  // Future<void> startRecord({required int width, required int height}) async {
  //   requestPermissions();
  //   Directory? tempDir = await getDownloadsDirectory();
  //   String? tempPath = tempDir!.path;

  //   // bool started =
  //   //     await FlutterScreenRecording.startRecordScreenAndAudio("soile");
  //   // setState(() {
  //   //   recording = started;
  //   // });

  //   var startResponse = await screenRecorder?.startRecordScreen(
  //     fileName: _idcontroller.text,
  //     //Optional. It will save the video there when you give the file path with whatever you want.
  //     //If you leave it blank, the Android operating system will save it to the gallery.
  //     dirPathToSave: tempPath,
  //     audioEnable: true,
  //     width: width,
  //     height: height,
  //   );
  //   setState(() {
  //     recording = startResponse!.isProgress;
  //     print("Start ");
  //   });

  //   // var status = await DeviceScreenRecorder.startRecordScreen(
  //   //     recordAudio: true, name: _idcontroller.text);
  //   // // var status = await ScreenRecorder.startRecordScreen(name: 'example');
  //   // setState(() {
  //   //   recording = status ?? false;
  //   // });
  // }

  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.camera,
      Permission.microphone, // For audio recording
    ].request();

    // Check the result for each permission
    statuses.forEach((permission, permissionStatus) {
      if (permissionStatus.isGranted) {
        print('${permission.toString()} granted');
      } else if (permissionStatus.isPermanentlyDenied) {
        openAppSettings(); // Open app settings if permission is permanently denied
      } else {
        print('${permission.toString()} denied');
      }
    });
  }

  // Future<void> stopRecord() async {
  //   // String paths = await FlutterScreenRecording.stopRecordScreen;
  //   // setState(() {
  //   //   path = paths;
  //   // });

  //   var stopResponse = await screenRecorder?.stopRecord();
  //   setState(() {
  //     path = stopResponse!.file.path;
  //     recording = stopResponse.isProgress;
  //     print("Stop");
  //   });

  //   // var file = await DeviceScreenRecorder.stopRecordScreen();
  //   // setState(() {
  //   //   path = file ?? '';
  //   //   recording = false;
  //   // });
  // }

  @override
  Widget build(BuildContext context) {
    // var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColor.darkBlueColor1,
      body: SafeArea(
        child: Column(
          children: [
            // Top
            TopCallBar(),
            // Text(
            //   path,
            //   style: TextStyle(color: Colors.white),
            // ),
            // IconButton(
            //   iconSize: 36,
            //   onPressed: () {
            //     recording
            //         ? stopRecord()
            //         : startRecord(
            //             width: size.width.toInt(),
            //             height: size.height.toInt(),
            //           );
            //   },
            //   color: Colors.white,
            //   icon: recording ? Icon(Icons.send_outlined) : Icon(Icons.start),
            // ),
            // Body
            BodyCall(
                idcontroller: _idcontroller, codecontroller: _codecontroller),
          ],
        ),
      ),
    );
  }
}

class BodyCall extends StatelessWidget {
  const BodyCall({
    Key? key,
    required this.idcontroller,
    required this.codecontroller,
  }) : super(key: key);

  final TextEditingController idcontroller;
  final TextEditingController codecontroller;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          height: size.height * 0.7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomRowText(
                size: 0.062,
                controller: idcontroller,
                text: 'ID Number'.tr,
                color: Colors.yellow, // Change to your desired color
                width: 0.6,
                keyboardType: TextInputType.number,
                inputFormatters: [],
              ),
              Divider(
                height: size.height * 0.02,
                color: Colors.transparent,
              ),
              CustomRowText(
                size: 0.17,
                controller: codecontroller,
                text: 'Code'.tr,
                color: Colors.white, // Change to your desired color
                width: 0.6,
                keyboardType: TextInputType.visiblePassword,
                inputFormatters: [],
              ),
              Divider(
                height: size.height * 0.05,
                color: Colors.transparent,
              ),
              CustomButton(
                text: 'START CALL',
                onPressed: () async {
                  final userCallResponse = await CallService.callWithUser(
                    UserData().user!.idNumber,
                    idcontroller.text,
                    codecontroller.text,
                  );
                  print(userCallResponse);
                  if (userCallResponse != null) {
                    if (userCallResponse.limit != '0') {
                      // Navigate to the video call screen if limit is okay
                      channelName = userCallResponse.agoraData.channelName;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoCallScreen(
                            name: 'ID ${idcontroller.text}',
                            userId: idcontroller.text, isUser: true,
                            // uid: userCallResponse.agoraData.uid,
                            // token: userCallResponse.agoraData.token,
                            // channelName: userCallResponse.agoraData.channelName,
                          ),
                        ),
                      );
                    } else {
                      // Handle other limit conditions here
                    }
                  } else {
                    // Handle API call failure
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Failed To Initiate Call. Please Try Again.'),
                      ),
                    );
                  }
                },
                color: AppColor.green,
                textColor: AppColor.blackColor,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TopCallBar extends StatefulWidget {
  const TopCallBar({
    super.key,
  });

  @override
  State<TopCallBar> createState() => _TopCallBarState();
}

class _TopCallBarState extends State<TopCallBar> {
  User? user;

  @override
  void initState() {
    user = UserData().user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: AppColor.yellow,
            size: 30,
          ),
        ),
        const CustomText(
          text: 'Call to other user',
          fontSize: 24,
          color: AppColor.white,
        ),
        CallTimeCard(
          hint: 'Time has left on tariff',
          time: '${user?.remainingMinutes}',
        ),
      ],
    );
  }
}

class CallTimeCard extends StatelessWidget {
  const CallTimeCard({
    super.key,
    required this.hint,
    required this.time,
  });

  final String hint;
  final String time;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 16.0),
          alignment: Alignment.center,
          width: size.width * 0.2,
          height: size.height * 0.045,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            time, // call durations time
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: AppColor.red,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          hint, // call durations hints
          style: const TextStyle(
            fontSize: 12,
            color: AppColor.white,
          ),
        ),
      ],
    );
  }
}
