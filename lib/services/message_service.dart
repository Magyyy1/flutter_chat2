import 'package:pocketbase/pocketbase.dart';

import '../models/message_model.dart';
import 'pocketbase_service.dart';

class MessageService {
  final PocketBase _pb =
      PocketBaseService.instance.client;

  Future<List<MessageModel>> getMessages(
  String dialogId,
) async {
  try {
    final records = await _pb
        .collection('messages')
        .getFullList(
          expand: 'sender',
          sort: 'created',
        );

    print(records.first.data);

    final filtered = records.where((record) {
      final dialog =
          record.data['dialog'];

      print(dialog);

      if (dialog == null) {
        return false;
      }

      return dialog
          .toString()
          .contains(dialogId);
    }).toList();

    print(filtered.length);

    return filtered
        .map(
          (e) => MessageModel.fromRecord(e),
        )
        .toList();
  } catch (e) {
    print(e);
    return [];
  }
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

  void subscribe(
  String dialogId,
  Function(MessageModel) onNewMessage,
) {
  _pb.collection('messages').subscribe('*', (e) async {
    final record = e.record;

    if (record == null) return;

    if (record.data['dialog'] == dialogId) {
      final fullRecord = await _pb
          .collection('messages')
          .getOne(
            record.id,
            expand: 'sender',
          );

      onNewMessage(
        MessageModel.fromRecord(fullRecord),
      );
    }
  });
}

  void unsubscribe() {
    _pb.collection('messages').unsubscribe('*');
  }
}