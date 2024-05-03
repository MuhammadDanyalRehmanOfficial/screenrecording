import '../auth/auth_service.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../chat/chat_service.dart';
import '../splash_screen.dart';

class FavoriteService {
  static const String baseUrl = 'http://soylephone.webtm.ru/api';
  static Future<List<Message>?> getFavoriteMessages() async {
    final response = await http.get(
      Uri.parse('$baseUrl/contact/favorite'),
      headers: {
        'Authorization': 'Bearer ${finaltoken ?? UserData().user?.token}'
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final favoriteMessage = FavoriteMessage.fromJson(jsonData);
      return favoriteMessage.messages;
    } else {
      throw Exception('Failed to load favorite messages');
    }
  }

  static Future<void> addToFavorites(int messageId) async {
    final url = '$baseUrl/contact/favorite/$messageId';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${finaltoken ?? UserData().user?.token}'
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add message to favorites');
    }
  }

  static Future<void> removeFromFavorites(int messageId) async {
    final url = '$baseUrl/contact/favorite/$messageId';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${finaltoken ?? UserData().user?.token}'
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to remove message from favorites');
    }
  }
}

class FavoriteMessage {
  final List<Message>? messages;

  FavoriteMessage({this.messages});

  factory FavoriteMessage.fromJson(Map<String, dynamic> json) {
    return FavoriteMessage(
      messages:
          List<Message>.from(json['messages']?.map((x) => Message.fromJson(x))),
    );
  }
}
