import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soylephone_user/screens/contact/contact_service.dart';
import 'package:soylephone_user/screens/welcome_screen/welcome_screen.dart';
import 'package:soylephone_user/utils/app_colors.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../chat/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Contact>? contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    contacts = await ContactService.getContacts();
    print(contacts);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.darkBlueColor1,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Top home menu
            const TopHomeMenu(),
            // Display contacts
            _isLoading
                ? const CircularProgressIndicator(
                    color: AppColor.white,
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: contacts!.length,
                      itemBuilder: (context, index) {
                        return CustomDisplay(
                            contact: contacts![index], index: index);
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class CustomDisplay extends StatelessWidget {
  const CustomDisplay({
    super.key,
    required this.index,
    required this.contact,
  });

  final Contact contact;
  final int index;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom:16.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColor.darkBlueColor1,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                fontSize: 18,
                color: AppColor.white,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
          CustomDisplayField(
            // name of contact
            value: contact.name,
            id: contact.id,
            unread: contact.unread,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    chatId: int.parse(contact.id),
                    chatName: contact.name,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class TopHomeMenu extends StatelessWidget {
  const TopHomeMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const CustomText(
              text: 'SÖILEPHONE',
              fontSize: 32,
              color: AppColor.white,
            ),
            // logout account
            TextButton.icon(
              label: CustomText(
                  text: 'Logout'.tr, fontSize: 16, color: AppColor.white),
              onPressed: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                prefs.remove('token');
                prefs.remove('langauge');
                Navigator.pushReplacementNamed(context, '/');
              },
              icon: const Icon(
                Icons.logout,
                color: AppColor.white,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomTextIconButton(
              onTap: () {
                Navigator.pushNamed(context, '/addContact', arguments: 'Login');
              },
              text: 'Add Contact'.tr,
              icon: Icons.add,
              color: AppColor.white,
              bgcolor: true,
            ),
            CustomTextIconButton(
              onTap: () {
                Navigator.pushNamed(context, '/favorie');
              },
              text: 'Favorites'.tr,
              icon: Icons.star,
              color: AppColor.yellow,
              bgcolor: false,
            ),
            // call to the other user
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/callUsers');
              },
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(AppColor.yellow),
              ).merge(ElevatedButton.styleFrom(
                minimumSize: Size(size.width * 0.01, size.height * 0.04),
              )),
              icon: const Icon(
                Icons.videocam,
                size: 20,
                color: AppColor.blackColor,
              ),
              label: Text(
                'Call other'.tr,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColor.blackColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CustomTextIconButton extends StatelessWidget {
  const CustomTextIconButton({
    super.key,
    required this.onTap,
    required this.text,
    required this.icon,
    required this.color,
    required this.bgcolor,
  });
  final Function() onTap;
  final String text;
  final IconData icon;
  final Color color;
  final bool bgcolor;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      onLongPress: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: bgcolor ? AppColor.green : Colors.transparent,
            radius: 11,
            child: Icon(
              icon,
              size: 22,
              color: color,
            ),
          ),
          SizedBox(
            width: size.width * 0.01,
          ),
          CustomText(
            text: text,
            fontSize: 18,
            color: AppColor.white,
          ),
        ],
      ),
    );
  }
}

class CustomDisplayField extends StatefulWidget {
  const CustomDisplayField({
    Key? key,
    required this.value,
    required this.id,
    required this.onTap,
    required this.unread,
  }) : super(key: key);

  final String value;
  final String id;
  final int unread;
  final Function() onTap;

  @override
  State<CustomDisplayField> createState() => _CustomDisplayFieldState();
}

class _CustomDisplayFieldState extends State<CustomDisplayField> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal:8.0),
        width: size.width * 0.85,
        height: size.height * 0.1,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                widget.value,
                style: const TextStyle(
                  color: AppColor.blackColor,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
            CircleAvatar(
              backgroundColor: Colors.green,
              child: CustomText(
                text: '${widget.unread}',
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
