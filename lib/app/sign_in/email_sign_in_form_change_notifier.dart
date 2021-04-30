import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/app/sign_in/email_sign_in_change_model.dart';
import 'package:time_tracker/common_widgets/form_submit_button.dart';
import 'package:time_tracker/common_widgets/show_exception_alert_dialog.dart';
import 'package:time_tracker/services/auth.dart';

class EmailSignInFormChangeNotifier extends StatefulWidget {
  final EmailSignInChangeModel model;

  EmailSignInFormChangeNotifier({
    Key key,
    @required this.model,
  }) : super(key: key);

  static Widget create({BuildContext context}) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return ChangeNotifierProvider<EmailSignInChangeModel>(
      create: (_) => EmailSignInChangeModel(auth: auth),
      child: Consumer<EmailSignInChangeModel>(
        builder: (_, model, __) => EmailSignInFormChangeNotifier(model: model),
      ),
    );
  }

  @override
  _EmailSignInFormChangeNotifierState createState() =>
      _EmailSignInFormChangeNotifierState();
}

class _EmailSignInFormChangeNotifierState
    extends State<EmailSignInFormChangeNotifier> {
  final FocusNode _emailFocusNode = FocusNode(),
      _passwordFocusNode = FocusNode();

  final TextEditingController _emailController = TextEditingController(),
      _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    try {
      await widget.model.submit();
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      if (Platform.isIOS) {
        print('Show IOS dialog');
      } else {
        showExceptionAlertDialog(
          context,
          title: 'Sign In Failed',
          exception: error,
        );
      }
    }
  }

  List<Widget> _buildChildren() => [
        _buildEmailTextField(),
        SizedBox(
          height: 8,
        ),
        _buildPasswordTextField(),
        SizedBox(
          height: 8,
        ),
        FormSubmitButton(
          text: widget.model.primaryButtonText,
          onPressed: widget.model.canSubmit ? _submit : null,
        ),
        SizedBox(
          height: 8,
        ),
        TextButton(
          onPressed: !widget.model.isLoading ? () => _toggleFormType() : null,
          child: Text(widget.model.secondaryButtonText),
        ),
      ];

  TextField _buildPasswordTextField() {
    return TextField(
      onChanged: (password) => widget.model.updatePassword(password: password),
      focusNode: _passwordFocusNode,
      textInputAction: TextInputAction.done,
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
        enabled: !widget.model.isLoading,
        errorText: widget.model.passwordErrorText,
        labelText: 'Password',
      ),
    );
  }

  void _emailEditingComplete() {
    final newFocus = widget.model.emailValidator.isValid(widget.model.email)
        ? _passwordFocusNode
        : _emailFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  TextField _buildEmailTextField() {
    return TextField(
      focusNode: _emailFocusNode,
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onEditingComplete: () => _emailEditingComplete(),
      onChanged: (email) => widget.model.updateEmail(email: email),
      decoration: InputDecoration(
        enabled: !widget.model.isLoading,
        labelText: 'Email',
        hintText: 'test@test.com',
        errorText: widget.model.emailErrorText,
      ),
    );
  }

  void _toggleFormType() {
    widget.model.toggleFormType();
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: _buildChildren(),
      ),
    );
  }
}
