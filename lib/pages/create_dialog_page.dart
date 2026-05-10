import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/dialog_service.dart';
import '../services/user_service.dart';

class CreateDialogPage extends StatefulWidget {
  const CreateDialogPage({super.key});

  @override
  State<CreateDialogPage> createState() =>
      _CreateDialogPageState();
}

class _CreateDialogPageState
    extends State<CreateDialogPage> {
  final UserService _userService =
      UserService();

  final DialogService _dialogService =
      DialogService();

  final TextEditingController
      _searchController =
      TextEditingController();

  List<AppUser> _users = [];

  bool _isLoading = false;

  Future<void> _search() async {
    final auth = context.read<AuthController>();

    final currentUserId =
        auth.currentUserId;

    if (currentUserId == null) return;

    setState(() {
      _isLoading = true;
    });

    final users =
        await _userService.searchUsers(
      _searchController.text.trim(),
      currentUserId,
    );

    if (!mounted) return;

    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  Future<void> _createDialog(
    AppUser user,
  ) async {
    final auth = context.read<AuthController>();

    final currentUserId =
        auth.currentUserId;

    if (currentUserId == null) return;

    await _dialogService.createDialog(
      currentUserId: currentUserId,
      otherUserId: user.id,
    );

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Новый диалог'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller:
                  _searchController,
              decoration:
                  InputDecoration(
                hintText:
                    'Поиск пользователя',
                suffixIcon: IconButton(
                  onPressed: _search,
                  icon:
                      const Icon(Icons.search),
                ),
              ),
              onSubmitted: (_) =>
                  _search(),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      itemCount:
                          _users.length,
                      itemBuilder:
                          (context, i) {
                        final user =
                            _users[i];

                        return ListTile(
                          onTap: () =>
                              _createDialog(
                            user,
                          ),

                          leading:
                              CircleAvatar(
                            child: Text(
                              user.name
                                  .substring(
                                      0,
                                      1)
                                  .toUpperCase(),
                            ),
                          ),

                          title:
                              Text(user.name),

                          subtitle:
                              Text(user.email),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}