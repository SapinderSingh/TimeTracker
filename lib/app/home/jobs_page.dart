import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/app/home/models/job.dart';
import 'package:time_tracker/common_widgets/show_alert_dialog.dart';
import 'package:time_tracker/common_widgets/show_exception_alert_dialog.dart';
import 'package:time_tracker/services/auth.dart';
import 'package:time_tracker/services/database.dart';

class JobsPage extends StatelessWidget {
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

  Future<void> _createJob({BuildContext context}) async {
    try {
      final Database database = Provider.of<Database>(
        context,
        listen: false,
      );
      await database.createJob(
        job: Job(
          name: 'Playing',
          ratePerHour: 20,
        ),
      );
    } on FirebaseException catch (error) {
      showExceptionAlertDialog(
        context,
        title: 'Operation Failed',
        exception: error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildContents(context: context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createJob(
          context: context,
        ),
        child: Icon(
          Icons.add,
        ),
      ),
      appBar: AppBar(
        title: Text('Jobs'),
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

  Widget _buildContents({BuildContext context}) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<List<Job>>(
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          final jobs = snapshot.data;
          final children = jobs
              .map(
                (job) => Text(
                  job.name,
                ),
              )
              .toList();
          return ListView(
            children: children,
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error'),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
      stream: database.jobsStream(),
    );
  }
}
