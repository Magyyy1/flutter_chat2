import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import 'pocketbase_service.dart';

class AuthController extends ChangeNotifier {
  final PocketBase _pb = PocketBaseService.instance.client;

  PocketBase get pb => _pb;

  bool _isInitialized = false;
  bool _isLoading = false;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  RecordModel? get currentUser {
    final model = _pb.authStore.record;

    if (model is RecordModel) {
      return model;
    }

    return null;
  }

  String? get currentUserId => currentUser?.id;

  bool get isAuthenticated =>
      _pb.authStore.isValid && currentUser != null;

  Future<void> initialize() async {
    _isInitialized = true;
    notifyListeners();
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _pb.collection('users').authWithPassword(
            email,
            password,
          );

      return null;
    } on ClientException catch (e) {
      print(e.response);

      return e.response['message']?.toString() ??
          'Ошибка входа';
    } catch (e) {
      print(e);

      return 'Ошибка входа';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _pb.collection('users').create(
        body: {
          'name': name,
          'email': email,
          'password': password,
          'passwordConfirm': password,
          'emailVisibility': true,
        },
      );

      await _pb.collection('users').authWithPassword(
            email,
            password,
          );

      return null;
    } on ClientException catch (e) {
      print(e.response);

      return e.response['message']?.toString() ??
          'Ошибка регистрации';
    } catch (e) {
      print(e);

      return 'Ошибка регистрации';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _pb.authStore.clear();
    notifyListeners();
  }
}