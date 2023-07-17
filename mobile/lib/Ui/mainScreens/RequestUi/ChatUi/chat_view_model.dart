import 'dart:async';
import 'dart:convert';

import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:ajuda/data/remote/model/chatModel/chat_model.dart';
import 'package:ajuda/data/repo/chat_repo.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatViewModel extends ViewModel {
  final messageStream = StreamController<List<ChatMessage>>();
  final messageList = <ChatMessage>[];
  late String _chatToken;
  late String _otherUser;
  late WebSocketChannel channel;
  late StreamSubscription sub;
  String? _userImage;

  String? get userImage => _userImage;

  set userImage(String? value) {
    _userImage = value;
    notifyListeners();
  }

  bool _sending = false;

  bool get sending => _sending;

  set sending(bool value) {
    _sending = value;
    notifyListeners();
  }

  void initChat(String withUser) {
    _otherUser = withUser;
    callApi(() async {
      //adding all previous messages in the chat
      final pastMessages = await ChatRepo.listAllMessages(withUser);
      addMessages(pastMessages ?? []);
      //getting chat token for initializing ws
      final token = await ChatRepo.getChatToken(withUser);
      if (token == null) {
        snackBarText = "Something Went Wrong";
        onError?.call();
        return;
      }
      _chatToken = token;
      initWS();
    });
  }

  Future<void> sendMessage(String message) async {
    try {
      sending = true;
      final chatMessage = await ChatRepo.sendMessage(message, _otherUser);
      if (chatMessage == null) {
        onError?.call();
        return;
      }
    } catch (th, stack) {
      print(th);
      print(stack);
    } finally {
      sending = false;
    }
  }

  void initWS() {
    try {
      channel = WebSocketChannel.connect(
        Uri.parse(
          'wss://api.ajudamais.bymobinteg.com/api/chat/ws?token=$_chatToken',
        ),
      );

      print('channel successfully created');
      print(channel.protocol);
      sub = channel.stream.listen((event) {
        print('received events from ws');
        addMessages([ChatMessage.fromJson(jsonDecode(event))]);
      });
    } catch (th) {
      print('error in ws');
      print(th);
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    messageStream.close();
    super.dispose();
  }

  void addMessages(List<ChatMessage> messages) {
    messageList.addAll(messages);
    final m = [...messageList];
    //sorting the messages based on their timestamps
    m.sort((a, b) {
      final at = a.timestamp ?? 0;
      final bt = b.timestamp ?? 0;
      return at - bt;
    });
    messageStream.add(m);
  }
}
