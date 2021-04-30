import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/app/sign_in/email_sign_in_page.dart';
import 'package:time_tracker/app/sign_in/sign_in_manager.dart';
import 'package:time_tracker/app/sign_in/sign_in_button.dart';
import 'package:time_tracker/app/sign_in/social_sign_in_button.dart';
import 'package:time_tracker/common_widgets/show_exception_alert_dialog.dart';
import 'package:time_tracker/services/auth.dart';

class SignInPage extends StatelessWidget {
  final SignInManager manager;
  final bool isLoading;

  const SignInPage({@required this.manager, @required this.isLoading,});

  static Widget create({@required BuildContext context}) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      create: (_) => ValueNotifier<bool>(false),
      child: Consumer<ValueNotifier<bool>>(
        builder: (_, isLoading, __) => Provider<SignInManager>(
          create: (_) => SignInManager(
            auth: auth,
            isLoading: isLoading,
          ),
          child: Consumer<SignInManager>(
            builder: (_, manager, __) => SignInPage(
              isLoading: isLoading.value,
              manager: manager,
            ),
          ),
        ),
      ),
    );
  }

  void _showSignInError({BuildContext context, Exception exception}) {
    if (exception is FirebaseException &&
        exception.code == 'ERROR_ABORTED_BY_USER') {
      return;
    }

    showExceptionAlertDialog(
      context,
      title: 'Sign In Failed',
      exception: exception,
    );
  }

  Future<void> _signInAnonymously({BuildContext context}) async {
    try {
      await manager.signInAnonymously();
    } on Exception catch (error) {
      _showSignInError(exception: error);
    }
  }

  Future<void> _signInWithGoogle({BuildContext context}) async {
    try {
      await manager.signInWithGoogle();
    } on Exception catch (error) {
      _showSignInError(exception: error);
    }
  }

  void _signInWithEmail({BuildContext context}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EmailSignInPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Time Tracker'),
        centerTitle: true,
        elevation: 2.0,
      ),
      body: _buildContent(
        context: context,
      ),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildContent({BuildContext context}) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            child: _buildHeader(),
            height: 50,
          ),
          SizedBox(height: 48.0),
          SocialSignInButton(
            assetName: 'images/google-logo.png',
            text: 'Sign in with Google',
            textColor: Colors.black87,
            color: Colors.white,
            onPressed: isLoading
                ? null
                : () => _signInWithGoogle(
                      context: context,
                    ),
          ),
          SizedBox(height: 8.0),
          SocialSignInButton(
            assetName: 'images/facebook-logo.png',
            text: 'Sign in with Facebook',
            textColor: Colors.white,
            color: Color(0xFF334D92),
            onPressed: isLoading ? null : () {},
          ),
          SizedBox(height: 8.0),
          SignInButton(
            text: 'Sign in with email',
            textColor: Colors.white,
            color: Colors.teal[700],
            onPressed:
                isLoading ? null : () => _signInWithEmail(context: context),
          ),
          SizedBox(height: 8.0),
          Text(
            'or',
            style: TextStyle(fontSize: 14.0, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.0),
          SignInButton(
            text: 'Go anonymous',
            textColor: Colors.black,
            color: Colors.lime[300],
            onPressed:
                isLoading ? null : () => _signInAnonymously(context: context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Text(
            'Sign in',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.w600,
            ),
          );
  }
}
