import 'package:ajuda/Ui/Utils/commanWidget/network_image.dart';
import 'package:ajuda/Ui/Utils/font_style.dart';
import 'package:ajuda/Ui/Utils/theme/appcolor.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/ChatUi/widgets/message_sender.dart';
import 'package:ajuda/data/remote/model/chatModel/chat_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class MessageReceiver extends StatelessWidget {
  const MessageReceiver(
      {super.key,
      required this.message,
      required this.profileImageUrl,
      required this.showProfileImage,
      required this.showSentTime,
      required this.showSentDate});

  final ChatMessage message;
  final String profileImageUrl;
  final bool showProfileImage;
  final bool showSentTime;
  final bool showSentDate;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 5),
          if (showSentDate) SentDate(timeStamp: message.timestamp ?? 0),
          Row(
            children: [
              const SizedBox(width: 10),
              if (showProfileImage)
                ProfileImageChat(profileUrl: profileImageUrl)
              else
                const SizedBox(width: 40),
              Expanded(
                child: MessageContainer(
                  message: message.text ?? '',
                  isFromMe: false,
                ),
              ),
              const SizedBox(width: 50)
            ],
          ),
          if (showSentTime)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 50, bottom: 10),
                child: SentTime(timeStamp: message.timestamp ?? 0),
              ),
            )
        ],
      ),
    );
  }
}
