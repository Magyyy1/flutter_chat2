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
  backgroundColor: const Color(0xFFF5F7FB),

  appBar: AppBar(
    elevation: 0,
    backgroundColor: const Color(0xFF3F7CFF),
    centerTitle: true,
    title: const Text(
      'Сообщения',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 28,
        color: Colors.white,
      ),
    ),
    actions: [
      IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CreateDialogPage(),
            ),
          );
        },
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
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
          color: Colors.white,
        ),
      ),
    ],
  ),

  body: Column(
    children: [
      Container(
        color: const Color(0xFF3F7CFF),
        padding: const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          18,
        ),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Поиск',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade500,
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.only(top: 12),
            ),
          ),
        ),
      ),

      Expanded(
        child: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : _dialogs.isEmpty
                ? const Center(
                    child: Text(
                      'Чатов пока нет',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.only(
                      top: 10,
                      bottom: 20,
                    ),
                    itemCount: _dialogs.length,
                    itemBuilder: (context, i) {
                      final dialog = _dialogs[i];

                      return ChatTile(
                        dialog: dialog,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ChatPage(
                                dialog: dialog,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
      ),
    ],
  ),
);
  }
}