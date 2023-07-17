import 'dart:convert';
import 'package:ajuda/Ui/Utils/response.dart';
import 'package:ajuda/data/remote/model/chatModel/chat_model.dart';
import 'package:ajuda/data/remote/networking.dart';
import 'package:ajuda/data/remote/url_constants.dart';

class ChatRepo {
  static Future<List<ChatMessage>?> listAllMessages(String withUser) async {
    ResponseBody responseBody = await Networking.get('${Endpoints.kChat}?limit=200&offset=0&withUser=$withUser');
    if(responseBody.code != 200){
      return null;
    }
    final array = jsonDecode(responseBody.data) as Iterable;
    final chats = array.map((e) {
      return ChatMessage.fromJson(e);
    });
    return chats.toList();
  }

  static Future<String?> getChatToken(String withUser) async {
    ResponseBody responseBody =
        await Networking.get('${Endpoints.kGetChatToken}?withUser=$withUser');
    if (responseBody.code == 200 || responseBody.code == 201) {
      final responseJson = jsonDecode(responseBody.data);
      return responseJson['value'];
    } else {
      return null;
    }
  }

  ///returns a chat message instance if sending the message was successful and null otherwise
  static Future<ChatMessage?> sendMessage(String message, String toUser) async {
    final requestBody = {
      "text": message,
      "toUser": toUser,
    };
    final responseBody = await Networking.post(
      Endpoints.kChat,
      jsonEncode(requestBody),
    );
    if (responseBody.code != 201) {
      return null;
    }
    return ChatMessage.fromJson(jsonDecode(responseBody.data));
  }
}
