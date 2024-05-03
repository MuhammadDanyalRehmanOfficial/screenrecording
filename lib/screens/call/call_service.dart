import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../auth/auth_service.dart';
import '../splash_screen.dart';

class CallService {
  static const String baseUrl = 'http://soylephone.webtm.ru/api';

  static Future<CallResponse> initiateVideoCall(int visitorId) async {
    final url = '$baseUrl/call/with/visitor/$visitorId';
    print({finaltoken ?? UserData().user?.token});
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${finaltoken ?? UserData().user?.token}',
      },
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return CallResponse.fromJson(jsonData);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Token is invalid or expired');
    } else if (response.statusCode == 403) {
      throw Exception('Limit has been reached');
    } else if (response.statusCode == 404) {
      throw Exception('Visitor is not in contact or not registered');
    } else {
      throw Exception('Failed to initiate video call');
    }
  }

  static Future<CallResponse?> callWithUser(
      String fromIdNumber, String toIdNumber, String code) async {
    final response = await http.post(
      Uri.parse('$baseUrl/call/with/user'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${finaltoken ?? UserData().user?.token}',
      },
      body: jsonEncode(<String, String>{
        'from_id_number': fromIdNumber,
        'to_id_number': toIdNumber,
        'code': code,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return CallResponse.fromJson(responseData);
    } else {
      return null;
    }
  }

  static Future<void> sendCallReportVisitor({
    required String contactVisitorId,
    required int quantity,
    required String videoFilePath, // Change parameter name to videoFilePath
  }) async {
    // Open the video file from the device's storage
    File videoFile = File(videoFilePath);

    if (!videoFile.existsSync()) {
      throw Exception('Video file does not exist: $videoFilePath');
    }

    // Define the URL
    final url = Uri.parse('$baseUrl/call/record/with/visitor/$contactVisitorId');

    // Create a new multipart request
    var request = http.MultipartRequest('POST', url);

    // Add headers to the request
    request.headers['Authorization'] =
        'Bearer ${finaltoken ?? UserData().user?.token}';

    // Add fields to the request body
    request.fields['quantity'] = quantity.toString();

    // Create a MultipartFile from the video file
    var videoMultipartFile = await http.MultipartFile.fromPath(
      'record', // the field name for the video file
      videoFile.path, // the path of the video file
      filename: 'video1.mp4', // the file name
    );

    // Add the video file to the request
    request.files.add(videoMultipartFile);

    try {
      // Send the request
      print("Check");
      var response = await request.send();

      // Parse the response from the server
      var responseData = await http.Response.fromStream(response);
      // Check the response status code
      if (responseData.statusCode == 200) {
        var body = json.decode(responseData.body);
        print('Call report sent successfully: $body');
      } else if (responseData.statusCode == 401) {
        // Handle unauthorized error
        throw Exception('Unauthorized: Token is invalid');
      } else {
        throw Exception(
            'Failed to send call report with status code: ${responseData.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending call report: $e');
    }
  }

  static Future<void> sendCallReportUser({
    required String contactUserId,
    required int quantity,
    required String videoFilePath, // Change parameter name to videoFilePath
  }) async {
    // Open the video file from the device's storage
    File videoFile = File(videoFilePath);

    if (!videoFile.existsSync()) {
      throw Exception('Video file does not exist: $videoFilePath');
    }

    // Define the URL
    final url = Uri.parse('$baseUrl/call/record/with/user');

    // Create a new multipart request
    var request = http.MultipartRequest('POST', url);

    // Add headers to the request
    request.headers['Authorization'] =
        'Bearer ${finaltoken ?? UserData().user?.token}';

    // Add fields to the request body
    request.fields['quantity'] = quantity.toString();
    request.fields['id_number'] = contactUserId;

    // Create a MultipartFile from the video file
    var videoMultipartFile = await http.MultipartFile.fromPath(
      'record', // the field name for the video file
      videoFile.path, // the path of the video file
      filename: 'video1.mp4', // the file name
    );

    // Add the video file to the request
    request.files.add(videoMultipartFile);

    try {
      // Send the request
      print("Check");
      print(quantity);
      var response = await request.send();

      // Parse the response from the server
      var responseData = await http.Response.fromStream(response);
      // Check the response status code
      if (responseData.statusCode == 200) {
        var body = json.decode(responseData.body);
        print('Call report sent successfully: $body');
      } else if (responseData.statusCode == 401) {
        // Handle unauthorized error
        throw Exception('Unauthorized: Token is invalid');
      } else {
        throw Exception(
            'Failed to send call report with status code: ${responseData.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending call report: $e');
    }
  }
}

class CallResponse {
  final String limit;
  final AgoraData agoraData;

  CallResponse({required this.limit, required this.agoraData});

  factory CallResponse.fromJson(Map<String, dynamic> json) {
    return CallResponse(
      limit: json['limit'],
      agoraData: AgoraData.fromJson(json['agoraData']),
    );
  }
}

class AgoraData {
  final String token;
  final String channelName;
  final int uid;

  AgoraData(
      {required this.token, required this.channelName, required this.uid});

  factory AgoraData.fromJson(Map<String, dynamic> json) {
    return AgoraData(
      token: json['token'],
      channelName: json['channel_name'],
      uid: json['uid'],
    );
  }
}
