
import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../chat/chat_screen.dart';
import '../chat/chat_service.dart';
import '../home/home_screen.dart';
import 'favorite_service.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Message>? _favoriteMessages;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteMessages();
  }

  Future<void> _fetchFavoriteMessages() async {
    try {
      final messages = await FavoriteService.getFavoriteMessages();
      if (messages != null && messages.isNotEmpty) {
        setState(() {
          _favoriteMessages = messages;
        });
      } else {
        // Handle the case where no favorite messages are available
        setState(() {
          _favoriteMessages = [];
        });
      }
    } catch (e) {
      print('Error fetching favorite messages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.darkBlueColor1,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TopHomeMenu(),
            const SizedBox(height: 20),
            Expanded(
              child: _favoriteMessages != null
                  ? ListView.builder(
                      itemCount: _favoriteMessages!.length,
                      itemBuilder: (context, index) {
                        final message = _favoriteMessages![index];
                        return MessageCard(message: message);
                      },
                    )
                  : Center(child: const CircularProgressIndicator(color: AppColor.white,)),
            ),
          ],
        ),
      ),
    );
  }
}
