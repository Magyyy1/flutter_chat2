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
  }

  Future<void> _loadMessages() async {
    final messages =
    await _messageService
        .getMessages(
  widget.dialog.id,
);

    if (!mounted) return;

    setState(() {
      _messages = messages;
      _isLoading = false;
    });

    _scrollToBottom();
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

    await _messageService.sendMessage(
      dialogId: widget.dialog.id,
      senderId: currentUserId,
      text: text,
    );

    _messageController.clear();

    await _loadMessages();

    if (!mounted) return;

    setState(() {
      _isSending = false;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!_scrollController
          .hasClients) {
        return;
      }

      _scrollController.jumpTo(
        _scrollController
            .position.maxScrollExtent,
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
                : _messages.isEmpty
                    ? const Center(
                        child: Text(
                          'Сообщений пока нет',
                        ),
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