import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:time_tracker/services/auth.dart';

class SignInManager {
  final AuthBase auth;
  SignInManager({
    @required this.auth,
    @required this.isLoading,
  });

  final ValueNotifier<bool> isLoading;

  Future<User> _signIn(Future<User> Function() signInMethod) async {
    try {
      isLoading.value = true;
      return await signInMethod();
    } catch (error) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<User> signInAnonymously() async =>
      await _signIn(auth.signInAnonymously);

  Future<User> signInWithGoogle() async => await _signIn(auth.signInWithGoogle);
}