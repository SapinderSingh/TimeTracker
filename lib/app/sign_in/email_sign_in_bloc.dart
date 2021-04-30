import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:time_tracker/app/sign_in/email_sign_in_model.dart';
import 'package:time_tracker/services/auth.dart';

class EmailSignInBloc {
  final AuthBase auth;
  final _modelController = StreamController<EmailSignInModel>();

  EmailSignInBloc({
    @required this.auth,
  });
  Stream<EmailSignInModel> get modelStream => _modelController.stream;
  EmailSignInModel _model = EmailSignInModel();

  void dispose() {
    _modelController.close();
  }

  Future<void> submit() async {
    updateWith(submitted: true, isLoading: true);
    try {
      if (_model.formType == EmailSignInFormType.SignIn) {
        await auth.signInWithEmailAndPassword(
          email: _model.email,
          password: _model.password,
        );
      } else {
        await auth.createUserWithEmailAndPassword(
          email: _model.email,
          password: _model.password,
        );
      }
    } catch (error) {
      updateWith(isLoading: false);
      rethrow;
    }
  }

  void toggleFormType() {
    final formType = _model.formType == EmailSignInFormType.SignIn
        ? EmailSignInFormType.Register
        : EmailSignInFormType.SignIn;
    updateWith(
      email: '',
      password: '',
      isLoading: false,
      submitted: false,
      formType: formType,
    );
  }

  void updateEmail({String email}) => updateWith(email: email);

  void updatePassword({String password}) => updateWith(password: password);

  void updateWith({
    String email,
    String password,
    EmailSignInFormType formType,
    bool isLoading,
    bool submitted,
  }) {
    _model = _model.copyWith(
      email: email,
      formType: formType,
      isLoading: isLoading,
      password: password,
      submitted: submitted,
    );
    _modelController.sink.add(_model);
  }
}
