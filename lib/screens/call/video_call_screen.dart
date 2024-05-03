import 'dart:async';
import 'dart:io';

import 'package:agora_uikit/agora_uikit.dart';
import 'package:ed_screen_recorder/ed_screen_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soylephone_user/main.dart';
import 'package:soylephone_user/utils/agora_utils.dart';
import 'package:soylephone_user/utils/app_utils.dart';

import '../../utils/app_colors.dart';
import '../welcome_screen/welcome_screen.dart';
import 'call_other_screen.dart';
import 'call_service.dart';

class VideoCallScreen extends StatefulWidget {
  final String name;
  final String userId;
  final bool isUser;
  const VideoCallScreen({
    Key? key,
    required this.name,
    required this.userId,
    required this.isUser,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late Timer _callDurationTimer;
  int _callDurationInSeconds = 0;

  bool recording = false;
  EdScreenRecorder? screenRecorder;

  late AgoraClient client = AgoraClient(
    agoraConnectionData: AgoraConnectionData(
      appId: AgoraUtils.appId,
      channelName: channelName,
      username: "user",
    ),
    agoraEventHandlers: AgoraRtcEventHandlers(
      onUserJoined: (connection, remoteUid, elapsed) {
        startCallDurationTimer();
      },
      onUserOffline: (connection, remoteUid, reason) {
        AppUtils.showSnackBar(context, 'Left the call!'.tr);
        if (_callDurationInSeconds > 0) {
          if (widget.userId.toString().length <= 2) {
            _callDurationTimer.cancel();
            widget.isUser
                ? callWithVisitor(widget.userId, _callDurationInSeconds)
                : null;
          } else if (widget.userId.toString().length == 13) {
            _callDurationTimer.cancel();
            widget.isUser
                ? callWithUsers(widget.userId, _callDurationInSeconds)
                : null;
          }
        }
      },
    ),
  );

  @override
  void initState() {
    super.initState();
    initAgora();
    screenRecorder = EdScreenRecorder();
  }

  void initAgora() async {
    await client.initialize();
  }

  Future<void> startRecord({required int width, required int height}) async {
    Directory? tempDir = await getDownloadsDirectory();
    String? tempPath = tempDir!.path;
    var startResponse = await screenRecorder?.startRecordScreen(
      fileName: widget.userId,
      dirPathToSave: tempPath,
      audioEnable: true,
      width: width,
      height: height,
    );
    setState(() {
      recording = startResponse!.isProgress;
      print("Start ");
    });

    // var status = await DeviceScreenRecorder.startRecordScreen(
    //     recordAudio: true, name: _idcontroller.text);
    // // var status = await ScreenRecorder.startRecordScreen(name: 'example');
    // setState(() {
    //   recording = status ?? false;
    // });
  }

  Future<void> stopRecord() async {
    var stopResponse = await screenRecorder?.stopRecord();
    setState(() {
      path = stopResponse!.file.path;
      recording = stopResponse.isProgress;
      print("Stop");
    });
    // var file = await DeviceScreenRecorder.stopRecordScreen();
    // setState(() {
    //   path = file ?? '';
    //   recording = false;
    // });
  }

  @override
  void dispose() {
    _callDurationTimer.cancel();
    super.dispose();
  }

  Future<void> callWithVisitor(String contactVisitorId, int quantity) async {
    widget.isUser ? await stopRecord() : null;
    await CallService.sendCallReportVisitor(
      contactVisitorId: contactVisitorId,
      quantity: quantity,
      videoFilePath: path,
    );
  }

  Future<void> callWithUsers(String contactUserId, int quantity) async {
    widget.isUser ? await stopRecord() : null;
    await CallService.sendCallReportUser(
      contactUserId: contactUserId,
      quantity: quantity,
      videoFilePath: path,
    );
    print("Check" + quantity.toString());
  }

  void startCallDurationTimer() {
    widget.isUser
        ? startRecord(
            width: context.size!.width.toInt(),
            height: context.size!.height.toInt(),
          )
        : null;
    _callDurationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _callDurationInSeconds++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.darkBlueColor1,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: AppColor.yellow,
            size: 40,
          ),
        ),
        title: CustomText(
          text: widget.name,
          fontSize: 18,
          color: AppColor.white,
        ),
        actions: [
          Row(
            children: [
              CallDurationTimeCard(
                hint: 'Call duration',
                time: formatCallDuration(_callDurationInSeconds),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            AgoraVideoViewer(
              client: client,
              layoutType: Layout.oneToOne,
              enableHostControls: true, // Add this to enable host controls
            ),
            AgoraVideoButtons(
              client: client,
              addScreenSharing: false, // Add this to enable screen sharing
            ),
          ],
        ),
      ),
    );
  }

  String formatCallDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class CallDurationTimeCard extends StatelessWidget {
  const CallDurationTimeCard({
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
