import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dialog_model.dart';
import '../models/message_model.dart';
import '../services/auth_service.dart';
import '../services/message_service.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.dialog,
  });

  final DialogModel dialog;

  @override
  State<ChatPage> createState() =>
      _ChatPageState();
}

class _ChatPageState
    extends State<ChatPage> {
  final MessageService _messageService =
      MessageService();

  final TextEditingController
      _messageController =
      TextEditingController();

  final ScrollController
      _scrollController =
      ScrollController();

  List<MessageModel> _messages = [];

  bool _isLoading = true;

  bool _isSending = false;

  @override
  void initState() {
    super.initState();

    _loadMessages();

    _subscribe();
  }

  @override
  void dispose() {
    _messageService.unsubscribe();

    _messageController.dispose();

    _scrollController.dispose();

    super.dispose();
  }

  void _subscribe() {
  _messageService.subscribe(
    widget.dialog.id,
    (message) {
      if (!mounted) return;

      final exists = _messages.any(
        (m) => m.id == message.id,
      );

      if (exists) return;

      setState(() {
        _messages.add(message);
      });

      _scrollToBottom();
    },
  );
}

  Future<void> _loadMessages() async {
  try {
    final messages =
        await _messageService.getMessages(
      widget.dialog.id,
    );

    if (!mounted) return;

    setState(() {
      _messages = messages;
      _isLoading = false;
    });

    _scrollToBottom();
  } catch (e) {
    print(e);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }
}

  Future<void> _sendMessage() async {
    final auth =
        context.read<AuthController>();

    final currentUserId =
        auth.currentUserId;

    final text =
        _messageController.text.trim();

    if (currentUserId == null ||
        text.isEmpty ||
        _isSending) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await _messageService.sendMessage(
        dialogId: widget.dialog.id,
        senderId: currentUserId,
        text: text,
      );

      _messageController.clear();
    } 
    finally {
  if (mounted) {
    setState(() {
      _isSending = false;
    });
  }
}
  }

  void _scrollToBottom() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!_scrollController
          .hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController
            .position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 250,
        ),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        context
            .read<AuthController>()
            .currentUserId;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.dialog.otherUserName),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : ListView.builder(
                    controller:
                        _scrollController,
                    padding:
                        const EdgeInsets.all(
                      12,
                    ),
                    itemCount:
                        _messages.length,
                    itemBuilder:
                        (context, index) {
                      final message =
                          _messages[index];

                      return MessageBubble(
                        message: message,
                        isMine:
                            message.senderId ==
                                currentUserId,
                      );
                    },
                  ),
          ),

          Container(
            padding:
                const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:
                        _messageController,
                    decoration:
                        const InputDecoration(
                      hintText:
                          'Сообщение',
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  onPressed:
                      _isSending
                          ? null
                          : _sendMessage,
                  icon: const Icon(
                    Icons.send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}