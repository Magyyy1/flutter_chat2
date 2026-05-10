import 'package:flutter/material.dart';

import '../models/dialog_model.dart';

class ChatTile extends StatelessWidget {
  const ChatTile({
    super.key,
    required this.dialog,
    required this.onTap,
  });

  final DialogModel dialog;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,

      leading: CircleAvatar(
        child: Text(
          dialog.otherUserName
              .substring(0, 1)
              .toUpperCase(),
        ),
      ),

      title: Text(
        dialog.otherUserName,
      ),

      subtitle: Text(
        dialog.lastMessage.isEmpty
            ? 'Нет сообщений'
            : dialog.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}