import 'package:flutter/material.dart';

import '../models/message_model.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  final MessageModel message;

  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 8,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        constraints: const BoxConstraints(
          maxWidth: 280,
        ),
        decoration: BoxDecoration(
          color: isMine
              ? Colors.blue
              : Colors.grey.shade200,
          borderRadius:
              BorderRadius.circular(14),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isMine
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
    );
  }
}