import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:soylephone_user/screens/auth/auth_service.dart';

import '../splash_screen.dart';

class MessageService {
  static const String baseUrl = 'http://soylephone.webtm.ru/api';

  static Future<String> sendMessage({
    required int contactId,
    required String file,
  }) async {
    try {
      // Create the request
      final url = '$baseUrl/contact/$contactId';
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Set authorization header
      request.headers['Authorization'] =
          'Bearer ${finaltoken ?? UserData().user?.token}';

      var attachment = File(file);

      // Read file as bytes
      List<int> bytes = attachment.readAsBytesSync();

      // Add file to the request
      final multipartFile = http.MultipartFile.fromBytes(
        'attachment',
        bytes,
        filename: attachment.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Send the request
      final response = await http.Response.fromStream(await request.send());

      // Check response status code
      if (response.statusCode == 200) {
        return 'Message sent successfully';
      } else {
        return 'Failed to send message: ${response.statusCode}';
        // Handle error based on response status code
      }
    } catch (e) {
      return 'Error sending message: $e';
      // Handle other exceptions
    }
  }

  static Future<List<Message>> getMessages(int chatId) async {
    final url = '$baseUrl/contact/$chatId?page=1';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${finaltoken ?? UserData().user?.token}'
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> messageList = jsonData['messages'];
        return messageList.map((json) => Message.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Token is invalid or expired');
      } else if (response.statusCode == 404) {
        throw Exception('Visitor not registered');
      } else {
        throw Exception('Failed to fetch messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  
}

class Message {
  final int id;
  final Sender sender;
  final String? message;
  final String? attachment;
  final int seen;
  final DateTime sendTime;
  bool isFavorite;

  Message({
    required this.id,
    required this.sender,
    this.message,
    this.attachment,
    required this.seen,
    required this.sendTime,
    required this.isFavorite,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      sender: Sender.fromJson(json['sender']),
      message: json['message'],
      attachment: json['attachment'],
      seen: json['seen'],
      sendTime: DateTime.parse(json['send_time']),
      isFavorite: json['is_favorite'],
    );
  }
}

class Sender {
  final int id;
  final String senderType;
  final String name;

  Sender({
    required this.id,
    required this.senderType,
    required this.name,
  });

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json['id'],
      senderType: json['sender_type'],
      name: json['name'],
    );
  }
}
