import 'package:ajuda/Ui/Utils/commanWidget/network_image.dart';
import 'package:ajuda/Ui/Utils/font_style.dart';
import 'package:ajuda/Ui/Utils/theme/appcolor.dart';
import 'package:ajuda/data/remote/model/chatModel/chat_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class MessageSender extends StatelessWidget {
  const MessageSender(
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
              const SizedBox(width: 50),
              Expanded(
                  child: MessageContainer(
                message: message.text ?? '',
                isFromMe: true,
              )),
              if (showProfileImage)
                ProfileImageChat(profileUrl: profileImageUrl)
              else
                const SizedBox(width: 40),
              const SizedBox(width: 10),
            ],
          ),
          if (showSentTime)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 50),
                child: SentTime(timeStamp: message.timestamp ?? 0),
              ),
            )
        ],
      ),
    );
  }
}

class ProfileImageChat extends StatelessWidget {
  const ProfileImageChat({super.key, required this.profileUrl});

  final String profileUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: SizedBox(
          width: 25,
          height: 25,
          child: MyNetworkImage.circular(url: profileUrl),
        ),
      ),
    );
  }
}

class MessageContainer extends StatelessWidget {
  const MessageContainer(
      {super.key, required this.message, required this.isFromMe});

  final String message;
  final bool isFromMe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(
          color: AppColors.silver,
        ),
      ),
      child: Text(
        message,
        style: Poppins.medium(AppColors.black).s15,
        textAlign: isFromMe ? TextAlign.end : TextAlign.start,
      ),
    );
  }
}

class SentDate extends StatelessWidget {
  const SentDate({super.key, required this.timeStamp});

  final int timeStamp;

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat("EEE, MMM. yy")
        .format(DateTime.fromMillisecondsSinceEpoch(timeStamp).toLocal());
    return Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: AppColors.silver,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          formattedDate,
          style: Poppins.medium(AppColors.black).s12,
        ));
  }
}

class SentTime extends StatelessWidget {
  const SentTime({super.key, required this.timeStamp});

  final int timeStamp;

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat("hh:mm a")
        .format(DateTime.fromMillisecondsSinceEpoch(timeStamp).toLocal());
    return Text(
      formattedDate,
      style: Poppins.medium(AppColors.baliHai).s12,
    );
  }
}
