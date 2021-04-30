import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/app/sign_in/email_sign_in_bloc.dart';
import 'package:time_tracker/app/sign_in/email_sign_in_model.dart';
import 'package:time_tracker/common_widgets/form_submit_button.dart';
import 'package:time_tracker/common_widgets/show_exception_alert_dialog.dart';
import 'package:time_tracker/services/auth.dart';

class EmailSignInFormBlocBased extends StatefulWidget {
  final EmailSignInBloc bloc;

  EmailSignInFormBlocBased({
    Key key,
    @required this.bloc,
  }) : super(key: key);

  static Widget create({BuildContext context}) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return Provider<EmailSignInBloc>(
      create: (_) => EmailSignInBloc(auth: auth),
      child: Consumer<EmailSignInBloc>(
        builder: (_, bloc, __) => EmailSignInFormBlocBased(bloc: bloc),
      ),
      dispose: (_, bloc) => bloc.dispose(),
    );
  }

  @override
  _EmailSignInFormBlocBasedState createState() =>
      _EmailSignInFormBlocBasedState();
}

class _EmailSignInFormBlocBasedState extends State<EmailSignInFormBlocBased> {
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
      await widget.bloc.submit();
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

  List<Widget> _buildChildren({@required EmailSignInModel model}) => [
        _buildEmailTextField(model: model),
        SizedBox(
          height: 8,
        ),
        _buildPasswordTextField(model: model),
        SizedBox(
          height: 8,
        ),
        FormSubmitButton(
          text: model.primaryButtonText,
          onPressed: model.canSubmit ? _submit : null,
        ),
        SizedBox(
          height: 8,
        ),
        TextButton(
          onPressed: !model.isLoading ? () => _toggleFormType() : null,
          child: Text(model.secondaryButtonText),
        ),
      ];

  TextField _buildPasswordTextField({@required EmailSignInModel model}) {
    return TextField(
      onChanged: (password) => widget.bloc.updatePassword(password: password),
      focusNode: _passwordFocusNode,
      textInputAction: TextInputAction.done,
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
        enabled: !model.isLoading,
        errorText: model.passwordErrorText,
        labelText: 'Password',
      ),
    );
  }

  void _emailEditingComplete({@required EmailSignInModel model}) {
    final newFocus = model.emailValidator.isValid(model.email)
        ? _passwordFocusNode
        : _emailFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  TextField _buildEmailTextField({@required EmailSignInModel model}) {
    return TextField(
      focusNode: _emailFocusNode,
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onEditingComplete: () => _emailEditingComplete(model: model),
      onChanged: (email) => widget.bloc.updateEmail(email: email),
      decoration: InputDecoration(
        enabled: !model.isLoading,
        labelText: 'Email',
        hintText: 'test@test.com',
        errorText: model.emailErrorText,
      ),
    );
  }

  void _toggleFormType() {
    widget.bloc.toggleFormType();
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EmailSignInModel>(
      stream: widget.bloc.modelStream,
      initialData: EmailSignInModel(),
      builder: (_, snapshot) {
        final EmailSignInModel model = snapshot.data;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: _buildChildren(model: model),
          ),
        );
      },
    );
  }
}
