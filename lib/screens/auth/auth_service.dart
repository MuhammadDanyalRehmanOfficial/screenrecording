import 'dart:convert';
import 'package:http/http.dart' as http;

import '../splash_screen.dart';

class User {
  final int id;
  final String idNumber;
  final String firstName;
  final String lastName;
  final String middleName;
  final Establishment establishment;
  final String token;
  final int remainingMinutes;

  User({
    required this.id,
    required this.idNumber,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.establishment,
    required this.token,
    required this.remainingMinutes,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      idNumber: json['id_number'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      middleName: json['middle_name'] ?? '',
      establishment: Establishment.fromJson(json['establishment']),
      token: json['token'],
      remainingMinutes: json['remaining_minutes'],
    );
  }
}

class Establishment {
  final int id;
  final String group;

  Establishment({required this.id, required this.group});

  factory Establishment.fromJson(Map<String, dynamic> json) {
    return Establishment(
      id: json['id'],
      group: json['group'],
    );
  }
}

class AuthService {
  static const String baseUrl = 'http://soylephone.webtm.ru';

  Future<void> updateFCMToken(String bearerToken, String fcmToken) async {
    final url = Uri.parse('$baseUrl/api/user/fcm-token');

    final headers = {
      'Authorization': 'Bearer $bearerToken',
    };

    final body = {
      'fcm_token': fcmToken,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      print('FCM token updated successfully');
    } else {
      print('Failed to update FCM token: ${response.statusCode}');
      // Handle error
    }
  }

  Future<User?> getUserData(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/user'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return User.fromJson(responseData);
    } else {
      return null;
    }
  }

  Future<User?> login(String idNumber, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/sign-in'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'id_number': idNumber,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return User.fromJson(responseData);
    } else {
      return null;
    }
  }

  Future<User?> register(String idNumber, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/sign-up'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'id_number': idNumber,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return User.fromJson(responseData);
    } else {
      return null;
    }
  }

  Future<void> logout() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/user/logout'),
      headers: {
        'Authorization': 'Bearer ${finaltoken ?? UserData().user?.token}'
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to logout');
    }
  }
}

class UserData {
  User? _user;

  static final UserData _instance = UserData._privateConstructor();

  UserData._privateConstructor();

  factory UserData() => _instance;

  User? get user => _user;

  void setUser(User user) {
    _user = user;
  }
}
