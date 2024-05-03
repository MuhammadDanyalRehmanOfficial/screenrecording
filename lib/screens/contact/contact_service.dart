import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:soylephone_user/screens/auth/auth_service.dart';
import 'package:soylephone_user/screens/splash_screen.dart';
import 'package:soylephone_user/utils/app_utils.dart';

class Contact {
  final String id;
  final String phone;
  final String name;
  final int unread;

  Contact(
      {required this.id,
      required this.unread,
      required this.phone,
      required this.name});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'].toString(),
      name: json['name'],
      phone: json['phone'].toString(),
      unread: json['unread'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'unread': unread,
    };
  }
}

class ContactService {
  static const String baseUrl = 'http://soylephone.webtm.ru/api';

  static Future<void> addContact(
      BuildContext context, Contact contact, String code) async {
    final url = Uri.parse('$baseUrl/contacts/add');
    final Map<String, dynamic> body = {
      'contacts': [contact.toJson()],
      'code': code,
    };
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${finaltoken ?? UserData().user?.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      AppUtils.showSnackBar(context, 'Contact added successfully'.tr);
    } else if (response.statusCode == 401) {
      AppUtils.showSnackBar(context, 'Unauthorized (401)');
    } else if (response.statusCode == 400) {
      AppUtils.showSnackBar(context, 'Contact limit exceeded (400)');
    } else if (response.statusCode == 403) {
      AppUtils.showSnackBar(
          context, 'KUIS user, employee confirmation code required (403)');
    } else if (response.statusCode == 422) {
      AppUtils.showSnackBar(context, 'Invalid confirmation code (422)');
    } else if (response.statusCode == 500) {
      AppUtils.showSnackBar(context, 'Internal Server Error (500)');
    } else {
      AppUtils.showSnackBar(
          context, 'Failed to add contacts: ${response.statusCode}');
    }
  }

  static Future<List<Contact>?> getContacts() async {
    try {
      const url = '$baseUrl/contacts';
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Authorization': 'Bearer ${finaltoken ?? UserData().user?.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData =
            json.decode(response.body)['contacts'];
        final List<Contact> contacts =
            responseData.map((data) => Contact.fromJson(data)).toList();
        return contacts;
      } else {
        print('Failed to get contacts: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting contacts: $e');
      return null;
    }
  }

  static Future<void> changeContact(
      int visitorId, String code, String name, BuildContext context) async {
    final url = '$baseUrl/change/contact/for/visitor/$visitorId';
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${finaltoken ?? UserData().user?.token}',
      'code': code,
    };

    final body = jsonEncode({'name': name});

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        AppUtils.showSnackBar(context, 'Contact changed successfully'.tr);
      } else if (response.statusCode == 400) {
        AppUtils.showSnackBar(
            context, 'Failed to change contact: Empty field name (400)');
      } else if (response.statusCode == 401) {
        AppUtils.showSnackBar(
            context, 'Failed to change contact: Unauthorized (401)');
      } else if (response.statusCode == 403) {
        AppUtils.showSnackBar(
            context, 'Failed to change contact: Forbidden (403)');
      } else if (response.statusCode == 404) {
        AppUtils.showSnackBar(
            context, 'Failed to change contact: Visitor not found (404)');
      } else if (response.statusCode == 422) {
        AppUtils.showSnackBar(context,
            'Failed to change contact: Invalid confirmation code (422)');
      } else if (response.statusCode == 500) {
        AppUtils.showSnackBar(
            context, 'Failed to change contact: Internal Server Error (500)');
      } else {
        AppUtils.showSnackBar(
            context, 'Failed to change contact: ${response.statusCode}');
      }
    } catch (e) {
      print('Error changing contact: $e');
    }
  }

  static Future<void> deleteContact(
      String visitorId, String code, BuildContext context) async {
    final url = '$baseUrl/contact/$visitorId';
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${finaltoken ?? UserData().user?.token}',
      'code': code,
    };

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        AppUtils.showSnackBar(context, 'Contact delete successfully'.tr);
      } else if (response.statusCode == 401) {
        AppUtils.showSnackBar(
            context, 'Failed to delete contact: Unauthorized (401)');
      } else if (response.statusCode == 403) {
        AppUtils.showSnackBar(
            context, 'Failed to delete contact: Forbidden (403)');
      } else if (response.statusCode == 422) {
        AppUtils.showSnackBar(context,
            'Failed to delete contact: Invalid confirmation code (422)');
      } else if (response.statusCode == 500) {
        AppUtils.showSnackBar(
            context, 'Failed to delete contact: Internal Server Error (500)');
      } else {
        AppUtils.showSnackBar(
            context, 'Failed to delete contact: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting contact: $e');
    }
  }
}
