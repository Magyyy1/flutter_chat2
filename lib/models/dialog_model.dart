class DialogModel {
 final String id;
 final String otherUserId;
 final String otherUserName;
 final String lastMessage;
 final DateTime updatedAt;

 DialogModel({
   required this.id,
   required this.otherUserId,
   required this.otherUserName,
   required this.lastMessage,
   required this.updatedAt,
 });

 factory DialogModel.fromRecord(dynamic record, String currentUserId) {
   final users = List<String>.from(record.data['users'] ?? []);
   final otherUserId = users.firstWhere((id) => id != currentUserId, orElse: () => '');

   final expandedUsers = record.expand['users'];
   dynamic otherUser;

   if (expandedUsers != null && expandedUsers is List) {
     for (final user in expandedUsers) {
       if (user.id == otherUserId) {
         otherUser = user;
         break;
       }
     }
   }

   final name = otherUser?.data['name']?.toString() ?? '';
   final email = otherUser?.data['email']?.toString() ?? '';
   final fallbackName = name.isNotEmpty ? name : (email.isNotEmpty ? email : 'Неизвестный');

   return DialogModel(
     id: record.id,
     otherUserId: otherUserId,
     otherUserName: fallbackName,
     lastMessage: (record.data['last_message'] ?? '').toString(),
     updatedAt: DateTime.tryParse(record.updated) ?? DateTime.now(),
   );
 }
}
