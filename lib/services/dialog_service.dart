import 'package:pocketbase/pocketbase.dart';

import '../models/dialog_model.dart';
import 'pocketbase_service.dart';

class DialogService {
  final PocketBase _pb =
      PocketBaseService.instance.client;

  Future<List<DialogModel>> getDialogs(
  String currentUserId,
) async {
  final records = await _pb
      .collection('dialogs')
      .getFullList(
        expand: 'users',
        sort: '-updated',
      );

  final filtered = records.where((record) {
    final users =
        List<String>.from(record.data['users'] ?? []);

    return users.contains(currentUserId);
  }).toList();

  return filtered
      .map(
        (record) => DialogModel.fromRecord(
          record,
          currentUserId,
        ),
      )
      .toList();
}

  Future<void> createDialog({
    required String currentUserId,
    required String otherUserId,
  }) async {
    final existing =
        await _pb.collection('dialogs').getFullList(
      filter:
          "users ~ '$currentUserId' && users ~ '$otherUserId'",
    );

    if (existing.isNotEmpty) {
      return;
    }

    await _pb.collection('dialogs').create(
      body: {
        'users': [
          currentUserId,
          otherUserId,
        ],
        'last_message': '',
      },
    );
  }

  void subscribe({
    required String currentUserId,
    required Function(DialogModel dialog)
        onCreate,
  }) {
    _pb.collection('dialogs').subscribe(
      '*',
      (event) {
        final record = event.record;

        if (record == null) return;

        final users =
            List<String>.from(
          record.data['users'] ?? [],
        );

        if (!users.contains(currentUserId)) {
          return;
        }

        onCreate(
          DialogModel.fromRecord(
            record,
            currentUserId,
          ),
        );
      },
    );
  }

  void unsubscribe() {
    _pb.collection('dialogs').unsubscribe('*');
  }
}