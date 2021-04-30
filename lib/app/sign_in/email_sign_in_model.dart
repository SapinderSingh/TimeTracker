import 'package:time_tracker/app/sign_in/validators.dart';

enum EmailSignInFormType {
  SignIn,
  Register,
}

class EmailSignInModel with EmailAndPasswordValidators {
  final String email, password;
  final EmailSignInFormType formType;
  final bool isLoading, submitted;

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

  EmailSignInModel({
    this.email = '',
    this.password = '',
    this.formType = EmailSignInFormType.SignIn,
    this.isLoading = false,
    this.submitted = false,
  });

  EmailSignInModel copyWith({
    String email,
    String password,
    EmailSignInFormType formType,
    bool isLoading,
    bool submitted,
  }) {
    return EmailSignInModel(
      email: email ?? this.email,
      password: password ?? this.password,
      formType: formType ?? this.formType,
      isLoading: isLoading ?? this.isLoading,
      submitted: submitted ?? this.submitted,
    );
  }
}
