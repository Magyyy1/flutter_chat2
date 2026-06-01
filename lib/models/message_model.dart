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

 factory MessageModel.fromRecord(dynamic record) {
   dynamic sender;
   try {
     sender = record.expand['sender'];
   } catch (_) {}

   final name = sender?.data['name']?.toString() ?? '';
   final email = sender?.data['email']?.toString() ?? '';
   final fallbackName = name.isNotEmpty ? name : (email.isNotEmpty ? email : 'Неизвестный');

   return MessageModel(
     id: record.id,
     text: (record.data['text'] ?? '').toString(),
     senderId: (record.data['sender'] ?? '').toString(),
     senderName: fallbackName,
     createdAt: DateTime.tryParse(record.created.toString()) ?? DateTime.now(),
   );
 }
}