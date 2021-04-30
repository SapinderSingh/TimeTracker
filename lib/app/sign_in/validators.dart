abstract class StringValidator {
  bool isValid(String value);
}

class NonEmptyStringValidator implements StringValidator {
  @override
  bool isValid(String value) {
    return value.isNotEmpty;
  }
}

class EmailAndPasswordValidators {
  final StringValidator emailValidator = NonEmptyStringValidator(),
      passwordValidator = NonEmptyStringValidator();
  final invalidEmailErrorText = 'Email can\'t be empty';
  final invalidPasswordErrorText = 'Password can\'t be empty';
}
