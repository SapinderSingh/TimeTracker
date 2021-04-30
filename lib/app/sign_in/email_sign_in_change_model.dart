import 'package:flutter/foundation.dart';
import 'package:time_tracker/app/sign_in/email_sign_in_model.dart';
import 'package:time_tracker/app/sign_in/validators.dart';
import 'package:time_tracker/services/auth.dart';

class EmailSignInChangeModel with EmailAndPasswordValidators, ChangeNotifier {
  String email, password;
  EmailSignInFormType formType;
  bool isLoading, submitted;
  final AuthBase auth;

  String get primaryButtonText =>
      formType == EmailSignInFormType.SignIn ? 'Sign In' : 'Create An Account';

  String get secondaryButtonText => formType == EmailSignInFormType.SignIn
      ? 'Need an account? Register'
      : 'Have an account? Sign In';

  bool get canSubmit =>
      emailValidator.isValid(email) &&
      passwordValidator.isValid(password) &&
      !isLoading;

  String get passwordErrorText {
    bool showErrorText = submitted && !passwordValidator.isValid(password);
    return showErrorText ? invalidPasswordErrorText : null;
  }

  String get emailErrorText {
    bool showErrorText = submitted && !emailValidator.isValid(email);
    return showErrorText ? invalidEmailErrorText : null;
  }

  EmailSignInChangeModel({
    this.email = '',
    this.password = '',
    this.formType = EmailSignInFormType.SignIn,
    this.isLoading = false,
    this.submitted = false,
    @required this.auth,
  });

  void toggleFormType() {
    final formType = this.formType == EmailSignInFormType.SignIn
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

  Future<void> submit() async {
    updateWith(submitted: true, isLoading: true);
    try {
      if (formType == EmailSignInFormType.SignIn) {
        await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
    } catch (error) {
      updateWith(isLoading: false);
      rethrow;
    }
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
    this.email = email ?? this.email;
    this.password = password ?? this.password;
    this.formType = formType ?? this.formType;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = submitted ?? this.submitted;
    notifyListeners();
  }
}
