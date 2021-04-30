import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/common_widgets/show_alert_dialog.dart';
import 'package:time_tracker/services/auth.dart';

class HomePage extends StatelessWidget {
  Future<void> _signOut({BuildContext context}) async {
    final auth = Provider.of<AuthBase>(
      context,
      listen: false,
    );
    try {
      await auth.signOut();
    } catch (error) {
      print(error.toString());
    }
  }

  Future<void> _confirmSignOut({BuildContext context}) async {
    final didRequestSignOut = await showAlertDialog(
      title: 'Log Out',
      content: 'Are you sure that you want to logout?',
      defaultActionText: 'Log Out',
      cancelActionText: 'Cancel',
      context: context,
    );

    if (didRequestSignOut) {
      _signOut(context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _confirmSignOut(context: context),
            child: Text(
              'Log Out',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
