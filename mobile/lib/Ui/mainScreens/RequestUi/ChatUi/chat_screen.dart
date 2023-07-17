import 'package:ajuda/Ui/Utils/font_style.dart';
import 'package:ajuda/Ui/Utils/theme/appcolor.dart';
import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:ajuda/Ui/authScreens/auth_view_model.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/ChatUi/chat_view_model.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/ChatUi/widgets/message_receiver.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/ChatUi/widgets/message_sender.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/requestViewModel.dart';
import 'package:ajuda/data/local/shared_pref_helper.dart';
import 'package:ajuda/data/remote/model/chatModel/chat_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../Utils/base_screen.dart';
import '../../../Utils/commanWidget/commonText.dart';
import '../../../Utils/commanWidget/network_image.dart';
import '../../../Utils/commanWidget/textform_field.dart';
import '../../ProfileUi/widget/app_bar_widget.dart';

class ChatScreen extends StatefulWidget {
  static const String route = "ChatScreen";

  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    withViewModel<ChatViewModel>(context, (viewModel) {
      final requestViewModel = context.read<RequestViewModel>();
      final authViewModel = context.read<AuthViewModel>();
      viewModel.userImage = authViewModel.userModel!.image;

      final data = SharedPrefHelper.userType == '1'
          ? requestViewModel.upcomingListData[requestViewModel.comAndUpIndex]
          : requestViewModel
              .upcomingListData[requestViewModel.comAndUpIndex].task;
      final userId = SharedPrefHelper.userType == '1'
          ? data.volunteer!.id
          : data.requester!.id;
      viewModel.initChat(userId);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    // withViewModel<RequestViewModel>(context, (viewModel) {
    //   viewModel.listScrollController.dispose();
    // });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestViewModel>();
    final data = SharedPrefHelper.userType == '1'
        ? provider.upcomingListData[provider.comAndUpIndex]
        : provider.upcomingListData[provider.comAndUpIndex].task;
    final userId = SharedPrefHelper.userType == '1'
        ? data.volunteer!.id
        : data.requester!.id;

    return BaseScreen<RequestViewModel>(
      color: AppColors.white,
      appBar: const CommonAppBar(
        title: '',
        color: AppColors.trans,
      ),
      child: Padding(
        // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        // physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(top: 0, right: 0, left: 0, bottom: 0),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                          left: 34.0, right: 15.0, top: 0.0, bottom: 27.0),
                      width: 85,
                      height: 85,
                      // color: AppColors.madison,
                      child: Stack(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              height: 85,
                              width: 85,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(80.0),
                                child: MyNetworkImage.circular(
                                    url: SharedPrefHelper.userType == '1'
                                        ? data.volunteer!.image ?? ''
                                        : data.requester!.image ?? ''),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: AppColors.madison,
                                // shape: BoxShape.circle,
                                borderRadius: BorderRadius.circular(35),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.white, //color of shadow
                                    spreadRadius: 2, //spread radius
                                    blurRadius: 2, // blur radius
                                    offset: Offset(
                                        0, 2), // changes position of shadow
                                    //second parameter is top to down
                                  ),
                                ],
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  data.taskType!.title == 'company'
                                      ? 'assets/icon/keepCompany.svg'
                                      : data.taskType!.title == 'pharmacy'
                                          ? 'assets/icon/pharmacies.svg'
                                          : data.taskType!.title == 'shopping'
                                              ? 'assets/icon/cart.svg'
                                              : data.taskType!.title == 'tours'
                                                  ? 'assets/icon/map.svg'
                                                  : 'assets/icon/file.svg',
                                  width: 20,
                                  height: 20,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CommonText(
                          text: provider.capitalize(
                              SharedPrefHelper.userType == '1'
                                  ? data.volunteer?.name ?? ''
                                  : data.requester?.name ?? ''),
                          style: Poppins.bold(AppColors.madison).s16,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                        CommonText(
                          text: provider.capitalize(data.taskType!.title),
                          style: Poppins.medium(AppColors.mako).s12,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3.0, top: 1),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icon/date.svg',
                                width: 11,
                                height: 11.42,
                                color: AppColors.mako,
                              ),
                              const SizedBox(
                                width: 7.0,
                              ),
                              CommonText(
                                text: DateFormat('MMM dd, yyyy')
                                    .format(DateTime.parse(data.date!))
                                    .toString(),
                                style: Poppins.semiBold(AppColors.mako).s12,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icon/time.svg',
                              width: 11,
                              height: 11.42,
                              color: AppColors.mako,
                            ),
                            const SizedBox(
                              width: 7.0,
                            ),
                            CommonText(
                              text: data.timeFrom != null
                                  ? '${DateFormat('hh:mm').format(DateFormat('hh:mm').parse(data.timeFrom!).toUtc())} • ${DateFormat('hh:mm').format(DateFormat('hh:mm').parse(data.timeTo!).toUtc())}'
                                  : 'any'.tr(),
                              style: Poppins.semiBold(AppColors.mako).s12,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 85,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        SharedPrefHelper.userType == '1'
                            ? data.volunteer.phoneNumber != null
                                ? provider
                                    .makePhoneCall(data.volunteer.phoneNumber)
                                : ''
                            : data.requester.phoneNumber != null
                                ? provider
                                    .makePhoneCall(data.requester.phoneNumber)
                                : '';
                      },
                      child: Container(
                        height: 48.0,
                        width: 48.0,
                        margin: const EdgeInsets.only(right: 19.0),
                        decoration: BoxDecoration(
                          color: AppColors.atlantis,
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icon/request-call.svg',
                            color: AppColors.white,
                            height: 20,
                            width: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ), // List of messages
            buildListMessage2(SharedPrefHelper.userType == '1'
                ? data.volunteer!.image ?? ''
                : data.requester!.image ?? ''),
            // Input content
            buildInput(context),
          ],
        ),
      ),
    );
  }

  Widget buildInput(BuildContext ctx) {
    final chatViewModel = context.watch<ChatViewModel>();
    return Container(
      width: double.infinity,
      height: 90.0,
      decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black, //color of shadow
              spreadRadius: 0.01, //spread radius
              blurRadius: 20, // blur radius
              offset: Offset(-2, -2), // changes position of shadow
              //second parameter is top to down
            ),
          ],
          border: Border(
            top: BorderSide(color: AppColors.baliHai, width: 0.5),
          ),
          color: Colors.white),
      child: Row(
        children: <Widget>[
          // Edit text
          Flexible(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 19.0, bottom: 19.0, right: 17.0, left: 17.0),
              child: TextFormField_Common(
                textEditingController: _controller,
                borderRadius: 14,
                contentPadding: 16,
                textStyle: Poppins.semiBold(AppColors.mako).s15,
                onChanged: (String? value) {
                  context.read<RequestViewModel>().chatText = value;
                },
                errorText: context.select<RequestViewModel, String?>(
                  (RequestViewModel state) => state.chatTextError,
                ),
                hintText: 'request.typeMessage'.tr(),
                textInputType: TextInputType.text,
                maxLines: 1,
                obscureText: false,
                textColor: AppColors.mako,
                textStyleHint:
                    Poppins.medium(AppColors.mako.withOpacity(0.7)).s15,
              ),
            ),
          ),
          //Sized box

          if (chatViewModel.sending)
            const Center(
              child: CircularProgressIndicator(),
            )
          else
            InkWell(
              onTap: () async {
                if (_controller.text.isEmpty) return;
                await chatViewModel.sendMessage(_controller.text);
                _controller.clear();
              },
              child: SvgPicture.asset(
                'assets/icon/send_message.svg',
                height: 50,
                width: 50,
              ),
            ),
          const SizedBox(width: 18.0)
        ],
      ),
    );
  }

  Widget noData() {
    return Center(
      child: CommonText(
          text: 'request.startChat'.tr(),
          style: Poppins.semiBold(AppColors.mako).s16,
          maxLines: 1,
          textAlign: TextAlign.center),
    );
  }

  Widget buildListMessage2(String profileImageUrl) {
    final vm = context.read<ChatViewModel>();
    return Expanded(
      child: ColoredBox(
        color: AppColors.porcelain,
        child: StreamBuilder<List<ChatMessage>>(
            stream: vm.messageStream.stream,
            builder: (context, snap) {
              if (snap.hasData) {
                return ListView.builder(
                    itemCount: snap.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      final data = snap.data![index];
                      final isFromMe = data.from == SharedPrefHelper.userId;
                      if (isFromMe) {
                        return MessageSender(
                          message: data,
                          profileImageUrl: vm.userImage!,
                          showProfileImage:
                              showProfileImage(index, snap.data ?? []) ||
                                  showSentDate(index, snap.data ?? []),
                          showSentTime: showSentTime(index, snap.data ?? []),
                          showSentDate: showSentDate(index, snap.data ?? []),
                        );
                      } else {
                        return MessageReceiver(
                          message: data,
                          profileImageUrl: profileImageUrl,
                          showProfileImage:
                              showProfileImage(index, snap.data ?? []) ||
                                  showSentDate(index, snap.data ?? []),
                          showSentTime: showSentTime(index, snap.data ?? []),
                          showSentDate: showSentDate(index, snap.data ?? []),
                        );
                      }
                    });
              } else {
                return noData();
              }
            }),
      ),
    );
  }

  bool showProfileImage(int currentIndex, List<ChatMessage> messages) {
    if (currentIndex == 0) return true;
    final currentMessage = messages[currentIndex];
    final lastMessage = messages[currentIndex - 1];
    final isCurrentFromMe = currentMessage.from == SharedPrefHelper.userId;
    final isLastFromMe = lastMessage.from == SharedPrefHelper.userId;
    final bothFromSameUser = isCurrentFromMe == isLastFromMe;
    return !bothFromSameUser;
  }

  bool showSentTime(int currentIndex, List<ChatMessage> messages) {
    //we have to show time on the last message in the list
    if (currentIndex == (messages.length - 1)) return true;
    final currentMessage = messages[currentIndex];
    final nextMessage = messages[currentIndex + 1];
    final isCurrentFromMe = currentMessage.from == SharedPrefHelper.userId;
    final isLastFromMe = nextMessage.from == SharedPrefHelper.userId;
    final bothFromSameUser = isCurrentFromMe == isLastFromMe;
    return !bothFromSameUser;
  }

  bool showSentDate(int currentIndex, List<ChatMessage> messages) {
    //we have to show time on the last message in the list
    if (currentIndex == 0) return true;
    final currentMessageDate = DateTime.fromMillisecondsSinceEpoch(
            messages[currentIndex].timestamp ?? 0)
        .toLocal();
    final prevMessageDate = DateTime.fromMillisecondsSinceEpoch(
            messages[currentIndex - 1].timestamp ?? 0)
        .toLocal();
    return !(currentMessageDate.day == prevMessageDate.day &&
        currentMessageDate.month == prevMessageDate.month &&
        currentMessageDate.year == prevMessageDate.year);
  }
}
