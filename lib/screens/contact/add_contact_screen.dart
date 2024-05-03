import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'package:soylephone_user/screens/welcome_screen/welcome_screen.dart';
import 'package:soylephone_user/utils/app_colors.dart';
import '../auth/register_screen.dart';
import 'contact_service.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({Key? key}) : super(key: key);

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  List<Contact>? contacts = [];
  String countryCode = "";

  bool _isLoading = true;

  @override
  void initState() {
    getContacts();
    super.initState();
  }

  Future<void> getContacts() async {
    contacts = await ContactService.getContacts();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dynamic args = ModalRoute.of(context)!.settings.arguments;
    final selectedRole = args as String;

    return Scaffold(
      backgroundColor: AppColor.darkBlueColor1,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top
            Padding(
              padding: EdgeInsets.only(top: 5),
              child: CustomText(
                text: 'Add allowed contacts, according to the personal file'.tr,
                fontSize: 22,
                color: AppColor.white,
              ),
            ),
            // Body
            _isLoading
                ? Center(
                    child: const CircularProgressIndicator(
                      color: AppColor.white,
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: contacts!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: buildContactRow(contacts![index], index + 1),
                        );
                      },
                    ),
                  ),

            // Input
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    // Add Expanded widget here
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 24, left: 4.0, right: 4),
                      child: IntlPhoneField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColor.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColor.yellow,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 16,
                          ),
                        ),
                        initialCountryCode: 'KZ',
                        onChanged: (phone) {
                          countryCode = phone.countryCode;
                        },
                      ),
                    ),
                  ),
                  CustomTextField(
                    controller: _nameController,
                    hint: 'Name Surname'.tr,
                    keyboardType: TextInputType.name,
                    color: AppColor.white,
                    width: 0.30,
                    inputFormatters: [],
                  ),
                  TextButton(
                    onPressed: () {
                      addContact(selectedRole);
                    },
                    child: CustomText(
                      text: 'Add'.tr,
                      fontSize: 16,
                      color: AppColor.yellow,
                    ),
                  ),
                ],
              ),
            ),

            // Save Contacts Button
            FloatingButton(
              role: selectedRole,
            )
          ],
        ),
      ),
    );
  }

  Future<void> addContact(String role) async {
    var contact;
    Map<String, String?>? confirmationData = await showDialog(
      context: context,
      builder: (BuildContext context) {
        String? code;
        String? name;
        String? middlename;
        String? surname;
        return AlertDialog(
          backgroundColor: AppColor.yellow,
          title: Text('Enter Profile Details'.tr),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    name = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Name'.tr,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  onChanged: (value) {
                    middlename = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'MiddleName'.tr,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  onChanged: (value) {
                    surname = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'SurName'.tr,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  onChanged: (value) {
                    code = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Code'.tr,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  AppColor.red,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: CustomText(
                text: 'Cancel'.tr,
                fontSize: 18,
                color: AppColor.white,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                print(middlename);
                print(surname);
                Navigator.of(context).pop({'code': code, 'name': name});
              },
              child: CustomText(
                text: 'Confirm'.tr,
                fontSize: 18,
                color: AppColor.blackColor,
              ),
            ),
          ],
        );
      },
    );
    setState(
      () {
        final name = _nameController.text;
        final phone = countryCode + _phoneController.text
          ..trim();
        _isLoading = true;
        contact = Contact(
          name: name,
          phone: phone.replaceAll('+', ''),
          unread: 0,
          id: '',
        );
        _phoneController.clear();
        _nameController.clear();
      },
    );
    await ContactService.addContact(
        context, contact, confirmationData!['code']!);
    getContacts();
  }

  Widget buildContactRow(Contact contact, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomText(
            text: '$index',
            fontSize: 18,
            color: AppColor.white,
          ),
          CustomField(
            value: contact.phone,
            Boxsize: 0.4,
          ),
          CustomField(
            value: contact.name,
            Boxsize: 0.35,
          ),
          IconButton.outlined(
            color: AppColor.red,
            onPressed: () {
              _showDeleteDialog(contact);
            },
            icon: Icon(Icons.delete),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Contact contact) {
    TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: SingleChildScrollView(
            child: AlertDialog(
              backgroundColor: AppColor.darkBlueColor1,
              title: CustomText(
                text: 'Are you sure to delete contact'.tr + ' ${contact.id}',
                fontSize: 24,
                color: AppColor.white, 
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: codeController,
                    hint: 'Code'.tr,
                    color: AppColor.white,
                    width: 0.4,
                    keyboardType: TextInputType.visiblePassword,
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
                          String code = codeController.text;
                          await ContactService.deleteContact(
                              contact.id, code, context);
                          getContacts();
                          Navigator.of(context).pop();
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

class FloatingButton extends StatelessWidget {
  const FloatingButton({
    super.key,
    required this.role,
  });
  final String role;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.topEnd,
      margin: const EdgeInsets.only(bottom: 10, right: 10),
      child: CustomButton(
        text: role == 'Login' ? 'To main'.tr : 'Continue'.tr,
        onPressed: () async {
          if (role == 'Login') {
            Navigator.pushNamed(context, '/home');
          } else {
            Navigator.pushNamed(context, '/confirm');
          }
        },
        color: AppColor.yellow,
        textColor: AppColor.blackColor,
      ),
    );
  }
}

class CustomField extends StatelessWidget {
  const CustomField({
    Key? key,
    required this.value,
    required this.Boxsize,
  }) : super(key: key);

  final String value;
  final double Boxsize;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      alignment: Alignment.center,
      width: size.width * Boxsize,
      height: size.height * 0.07,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
