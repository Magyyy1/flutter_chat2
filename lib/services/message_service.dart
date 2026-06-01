import 'package:pocketbase/pocketbase.dart';

import '../models/message_model.dart';
import 'pocketbase_service.dart';

class MessageService {
  final PocketBase _pb =
      PocketBaseService.instance.client;

  Future<List<MessageModel>> getMessages(
    String dialogId,
  ) async {
    final records = await _pb
        .collection('messages')
        .getFullList(
          sort: 'created',
          expand: 'sender',
        );

    final filtered = records.where((e) {
      return e.data['dialog']
              .toString() ==
          dialogId;
    }).toList();

    return filtered.map((e) {
      final senderList =
          e.expand['sender'];

      dynamic sender;

      if (senderList != null &&
          senderList.isNotEmpty) {
        sender = senderList.first;
      }

      return MessageModel(
        id: e.id,
        text:
            e.data['text']
                .toString(),
        senderId:
            e.data['sender']
                .toString(),
        senderName:
            sender != null
                ? (sender.data['name'] ??
                        sender.data['email'] ??
                        'Пользователь')
                    .toString()
                : 'Пользователь',
        createdAt:
            DateTime.tryParse(
                  e.created,
                ) ??
                DateTime.now(),
      );
    }).toList();
  }

  Future<void> sendMessage({
    required String dialogId,
    required String senderId,
    required String text,
  }) async {
    await _pb.collection('messages').create(
      body: {
        'dialog': dialogId,
        'sender': senderId,
        'text': text,
      },
    );

    await _pb.collection('dialogs').update(
      dialogId,
      body: {
        'last_message': text,
      },
    );
  }
}