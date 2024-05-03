import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soylephone_user/main.dart';
import 'package:soylephone_user/screens/auth/auth_service.dart';
import 'package:soylephone_user/utils/app_colors.dart';

import 'package:record_mp3/record_mp3.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:soylephone_user/utils/app_utils.dart';

import '../auth/register_screen.dart';
import '../call/call_service.dart';
import '../call/video_call_screen.dart';
import '../contact/contact_service.dart';
import '../favorite/favorite_service.dart';
import '../welcome_screen/welcome_screen.dart';
import 'chat_service.dart';
import 'image_screen.dart';
import 'video_screen.dart';

enum MessageType { Text, Video, Image, CallEnd, Audio }

class ChatScreen extends StatefulWidget {
  final int chatId;
  final String chatName;
  const ChatScreen({super.key, required this.chatId, required this.chatName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? _path;
  bool _isRecording = false;
  Duration _recordDuration = Duration.zero;
  late Timer _timer = Timer(Duration.zero, () {});
  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    try {
      final messages = await MessageService.getMessages(widget.chatId);
      setState(() {
        _messages = messages;
      });
      print(_messages);
    } catch (e) {
      print('No fetching messages'.tr);
      // Handle different error scenarios here
      if (e.toString().contains('Unauthorized')) {
        // Handle 401 error (token)
        AppUtils.showSnackBar(context, e.toString());
      } else if (e.toString().contains('Visitor not registered'.tr)) {
        // Handle 404 error (visitor not registered)
        AppUtils.showSnackBar(context, 'Visitor not registered'.tr);
      } else {
        // Handle other errors (e.g., server error)
        AppUtils.showSnackBar(context, 'No fetching messages'.tr);
      }
    }
  }

  Future<void> sendMessages() async {
    String filePath = _path!;

    try {
      String respone = await MessageService.sendMessage(
        contactId: widget.chatId,
        file: filePath,
      );
      if (respone.contains('Failed')) {
        AppUtils.showSnackBar(context, respone);
      }
    } catch (e) {
      print('Error sending message with attachment: $e');
    }
  }

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future<void> startRecording() async {
    final directory = await getTemporaryDirectory();
    _path = '${directory.path}/audio_recording.mp3';
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      RecordMp3.instance.start(_path!, (type) {});
      setState(() {
        _isRecording = true;
      });
      _startTimer();
    }
  }

  Future<void> stopRecording() async {
    final path = RecordMp3.instance.stop();
    print(path);

    setState(() {
      _isRecording = false;
      _stopTimer();
      _recordDuration = Duration.zero;
    });
    print(_path);
    await sendMessages();
    await fetchMessages();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _recordDuration = _recordDuration + const Duration(seconds: 1);
        if (_recordDuration.inSeconds >= 120) {
          // Automatically stop recording after 2 minutes (120 seconds)
          stopRecording();
        }
      });
    });
  }

  void _stopTimer() {
    _timer.cancel();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColor.darkBlueColor1,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // top chat menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    ChatIconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/home');
                      },
                      color: AppColor.white,
                      icon: Icons.arrow_back,
                    ),
                    CustomText(
                      text: widget.chatName,
                      fontSize: 18,
                      color: AppColor.white,
                    ),
                    IconButton(
                      iconSize: 18.0,
                      color: AppColor.green,
                      onPressed: () {
                        _showEditDialog();
                      },
                      icon: Icon(Icons.edit),
                    ),
                  ],
                ),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColor.white,
                      child: CustomText(
                        text: '${UserData().user?.remainingMinutes}',
                        color: AppColor.blackColor,
                        fontSize: 18,
                      ),
                    ),
                    VideoChatButton(
                      chatId: widget.chatId.toString(),
                      chatName: widget.chatName,
                    ),
                    ChatIconButton(
                      onPressed: _isRecording ? stopRecording : startRecording,
                      color: AppColor.white,
                      icon: _isRecording ? Icons.mic_off : Icons.mic,
                    ),
                  ],
                ),
              ],
            ),
            // middle
            Expanded(
              child: ListView.builder(
                reverse: true, // Display messages in reverse order
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final bool showDateChip = index == 0 ||
                      _messages[index].sendTime.day !=
                          _messages[index - 1].sendTime.day;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showDateChip)
                        Center(
                          child: DateChip(date: message.sendTime),
                        ),
                      MessageCard(message: message),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      //recording button
      floatingActionButton: _isRecording
          ? Container(
              alignment: Alignment.center,
              width: size.width * 0.6,
              height: size.height * 0.20 / 2,
              decoration: BoxDecoration(
                color: AppColor.yellow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text:
                          'Recording... ${_recordDuration.inMinutes}:${(_recordDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                      fontSize: 18,
                      color: AppColor.blackColor,
                    ),
                    ChatIconButton(
                      onPressed: () async {
                        stopRecording();
                      },
                      color: AppColor.darkBlueColor1,
                      icon: Icons.send,
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  void _showEditDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: SingleChildScrollView(
            child: AlertDialog(
              backgroundColor: AppColor.darkBlueColor1,
              title: CustomText(
                text: 'Edit Contact'.tr + ' ${widget.chatId}',
                fontSize: 24,
                color: AppColor.white,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: nameController,
                    hint: 'Name'.tr,
                    color: AppColor.white,
                    width: 0.4,
                    keyboardType: TextInputType.name,
                    inputFormatters: [],
                  ),
                  const Divider(height: 10, color: Colors.transparent),
                  CustomTextField(
                    controller: codeController,
                    hint: 'Code'.tr,
                    color: AppColor.white,
                    width: 0.4,
                    keyboardType: TextInputType.name,
                    inputFormatters: [],
                  ),
                  const Divider(height: 10, color: Colors.transparent),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: CustomText(
                          text: 'Cancel'.tr,
                          fontSize: 18,
                          color: AppColor.blackColor,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          String name = nameController.text;
                          String code = codeController.text;
                          await ContactService.changeContact(
                              widget.chatId, code, name, context);
                          Navigator.of(context).pop();
                          Navigator.pushNamed(context, '/home');
                        },
                        child: CustomText(
                          text: 'Submit'.tr,
                          fontSize: 18,
                          color: AppColor.blackColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class VideoChatButton extends StatelessWidget {
  const VideoChatButton({
    Key? key,
    required this.chatId,
    required this.chatName,
  }) : super(key: key);
  
  final String chatId;
  final String chatName;

  @override
  Widget build(BuildContext context) {
    return ChatIconButton(
      onPressed: () async {
        try {
          final response = await CallService.initiateVideoCall(int.parse(chatId));

          channelName = response.agoraData.channelName;
          token = response.agoraData.token;
          print("checked");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoCallScreen(
                name: chatName,
                userId: chatId,
                isUser: true,
              ),
            ),
          );
        } catch (e) {
          // Handle exceptions
          print('Error: $e');
          // Show a snackbar
        }
      },
      color: AppColor.white,
      icon: Icons.videocam,
    );
  }
}

class DateChip extends StatelessWidget {
  final DateTime date;

  const DateChip({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        DateFormat('yyyy-MM-dd')
            .format(date), // Customize the date format as needed
        style: const TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class MessageCard extends StatefulWidget {
  final Message message;

  const MessageCard({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  _MessageCardState createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  late final AudioPlayer _audioPlayer;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: widget.message.sender.senderType == 'visitor'
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => _handleAttachmentTap(widget.message.attachment),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
            decoration: BoxDecoration(
              color: widget.message.sender.senderType == 'visitor'
                  ? AppColor.grey
                  : AppColor.yellow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMessageContent(),
                const SizedBox(height: 4.0),
                widget.message.attachment != null
                    ? widget.message.attachment!.endsWith('.mp3')
                        ? const SizedBox()
                        : TimeStamp(
                            time: widget.message.sendTime,
                          )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: _toggleFavorite,
          icon: Icon(
            widget.message.isFavorite ? Icons.star : Icons.star_border,
            color: widget.message.isFavorite ? AppColor.yellow : AppColor.white,
          ),
        ),
      ],
    );
  }

  void _toggleFavorite() {
    setState(() {
      if (widget.message.isFavorite) {
        try {
          FavoriteService.removeFromFavorites(widget.message.id);
          widget.message.isFavorite = false;
        } catch (e) {
          print('Error removing from favorites: $e');
        }
      } else {
        try {
          FavoriteService.addToFavorites(widget.message.id);
          widget.message.isFavorite = true;
        } catch (e) {
          print('Error adding to favorites: $e');
        }
      }
    });
  }

  Widget _buildMessageContent() {
    if (widget.message.attachment != null) {
      if (widget.message.attachment!.endsWith('.mp3')) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: isPlaying
                  ? const Icon(
                      Icons.stop,
                      color: AppColor.blackColor,
                      size: 35,
                    )
                  : const Icon(
                      Icons.play_arrow,
                      color: AppColor.blackColor,
                      size: 35,
                    ),
              onPressed: () {
                setState(() {
                  isPlaying = !isPlaying;
                });
                if (_audioPlayer.playing) {
                  _audioPlayer.pause();
                } else {
                  _playAudio(widget.message.attachment!);
                }
              },
            ),
            StreamBuilder<Duration?>(
              stream: _audioPlayer.durationStream,
              builder: (context, snapshot) {
                final duration = snapshot.data ?? Duration.zero;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    StreamBuilder<Duration>(
                      stream: _audioPlayer.positionStream,
                      builder: (context, snapshot) {
                        final position = snapshot.data ?? Duration.zero;
                        return Slider(
                          activeColor: AppColor.blackColor,
                          value: position.inSeconds.toDouble(),
                          max: duration.inSeconds.toDouble(),
                          min: 0,
                          onChanged: (value) {
                            _audioPlayer.seek(Duration(seconds: value.toInt()));
                          },
                        );
                      },
                    ),
                    isPlaying
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              StreamBuilder<Duration>(
                                stream: _audioPlayer.positionStream,
                                builder: (context, snapshot) {
                                  final position =
                                      snapshot.data ?? Duration.zero;
                                  return CustomText(
                                    text:
                                        '${position.inSeconds}/${duration.inSeconds} sec',
                                    fontSize: 12,
                                    color: AppColor.blackColor,
                                  );
                                },
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ],
                );
              },
            ),
          ],
        );
      } else if (widget.message.attachment!.endsWith('.mp4')) {
        return const Text(
          'Video Message',
          style: TextStyle(fontSize: 16),
        );
      } else if (widget.message.attachment!.endsWith('.jpg') ||
          widget.message.attachment!.endsWith('.png')) {
        return Image.network(
          'https://soylephone.webtm.ru/${widget.message.attachment}',
          width: 200,
        );
      }
    } else if (widget.message.message != null) {
      return Text(
        widget.message.message!,
        style: const TextStyle(fontSize: 16),
      );
    }
    return const SizedBox(); // Return an empty SizedBox for unknown types
  }

  void _handleAttachmentTap(String? attachment) {
    if (attachment != null) {
      if (attachment.endsWith('.mp3')) {
        _playAudio(attachment);
      } else if (attachment.endsWith('.mp4')) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoScreen(videoUrl: attachment),
          ),
        );
      } else if (attachment.endsWith('.jpg') || attachment.endsWith('.png')) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageScreen(imageUrl: attachment),
          ),
        );
      }
    }
  }

  Future<void> _playAudio(String audioUrl) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setUrl('https://soylephone.webtm.ru/$audioUrl');
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }
}

class TimeStamp extends StatelessWidget {
  final DateTime time;

  const TimeStamp({Key? key, required this.time}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format the DateTime object into a string representation
    String formattedTime = DateFormat('HH:mm').format(time);

    return Text(
      formattedTime,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 12.0,
      ),
    );
  }
}

class ChatIconButton extends StatelessWidget {
  const ChatIconButton({
    super.key,
    required this.onPressed,
    required this.color,
    required this.icon,
  });
  final Function() onPressed;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: color,
        size: 35,
      ),
    );
  }
}
