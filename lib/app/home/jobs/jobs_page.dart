import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/app/home/jobs/edit_job_page.dart';
import 'package:time_tracker/app/home/jobs/job_list_tile.dart';
import 'package:time_tracker/app/home/models/job.dart';
import 'package:time_tracker/common_widgets/show_alert_dialog.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildContent(context: context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => EditJobPage.show(context),
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

  Widget _buildContent({BuildContext context}) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<List<Job>>(
      stream: database.jobsStream(),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          final jobs = snapshot.data;
          final children = jobs
              .map(
                (job) => JobListTile(
                  job: job,
                  onTap: () => EditJobPage.show(
                    context,
                    job: job,
                  ),
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
    );
  }
}
