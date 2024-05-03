import 'package:flutter/material.dart';
import 'package:soylephone_user/utils/app_colors.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key, required this.imageUrl});
  final String imageUrl;

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.darkBlueColor1,
      body: SafeArea(
        child: Center(
          child: Image.network(
            'https://soylephone.webtm.ru/${widget.imageUrl}',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
