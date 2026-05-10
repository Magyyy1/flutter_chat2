import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dialog_model.dart';
import '../services/auth_service.dart';
import '../services/dialog_service.dart';
import '../widgets/chat_tile.dart';
import 'chat_page.dart';
import 'create_dialog_page.dart';
import 'profile_page.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() =>
      _ChatsPageState();
}

class _ChatsPageState
    extends State<ChatsPage> {
  final DialogService _dialogService =
      DialogService();

  List<DialogModel> _dialogs = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadDialogs();

    _subscribe();
  }
void subscribe;
void _subscribe() {
    final auth =
        context.read<AuthController>();

    final currentUserId =
        auth.currentUserId;

    if (currentUserId == null) {
      return;
    }

    _dialogService.subscribe(
      currentUserId: currentUserId,
      onCreate: (dialog) {
        if (!mounted) return;

        final exists = _dialogs.any(
          (e) => e.id == dialog.id,
        );

        if (exists) {
          setState(() {
            _dialogs = _dialogs.map((e) {
              if (e.id == dialog.id) {
                return dialog;
              }

              return e;
            }).toList();
          });

          return;
        }

        setState(() {
          _dialogs.insert(0, dialog);
        });
      },
    );
  }
  @override
  void dispose() {
    _dialogService.unsubscribe();

    super.dispose();
  }



  Future<void> _loadDialogs() async {
  try {
    final auth = context.read<AuthController>();
    final userId = auth.currentUserId;

    if (userId == null) return;

    final dialogs =
        await _dialogService.getDialogs(userId);

    if (!mounted) return;

    setState(() {
      _dialogs = dialogs;
      _isLoading = false;
    });
  } catch (e) {
    print(e);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Сообщения'),

        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const CreateDialogPage(),
                ),
              );

              _loadDialogs();
            },
            icon:
                const Icon(Icons.add),
          ),

          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const ProfilePage(),
                ),
              );
            },
            icon: const Icon(
              Icons.person,
            ),
          ),
        ],
      ),

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : _dialogs.isEmpty
              ? const Center(
                  child: Text(
                    'Диалогов пока нет',
                  ),
                )
              : RefreshIndicator(
                  onRefresh:
                      _loadDialogs,
                  child: ListView.builder(
                    itemCount:
                        _dialogs.length,
                    itemBuilder:
                        (context, index) {
                      final dialog =
                          _dialogs[index];

                      return ChatTile(
                        dialog: dialog,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ChatPage(
                                dialog:
                                    dialog,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}