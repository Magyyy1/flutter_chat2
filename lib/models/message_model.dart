class MessageModel {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
  });

  factory MessageModel.fromRecord(
    dynamic record,
  ) {
    dynamic sender;

    try {
      sender =
          record.expand['sender'];
    } catch (_) {}

    return MessageModel(
      id: record.id,
      text:
          (record.data['text'] ?? '')
              .toString(),
      senderId:
          (record.data['sender'] ?? '')
              .toString(),
      senderName:
          sender != null
              ? (sender.data['name'] ??
                      sender.data['email'] ??
                      'Пользователь')
                  .toString()
              : 'Пользователь',
      createdAt: DateTime.tryParse(
            record.created.toString(),
          ) ??
          DateTime.now(),
    );
  }
}