import 'package:pocketbase/pocketbase.dart';

import '../models/app_user.dart';
import 'pocketbase_service.dart';

class UserService {
  final PocketBase _pb =
      PocketBaseService.instance.client;

  Future<List<AppUser>> searchUsers(
    String query,
    String currentUserId,
  ) async {
    final records =
        await _pb.collection('users').getFullList(
      filter:
          "name ~ '$query' && id != '$currentUserId'",
      sort: 'name',
    );

    return records
        .map(AppUser.fromRecord)
        .toList();
  }
}