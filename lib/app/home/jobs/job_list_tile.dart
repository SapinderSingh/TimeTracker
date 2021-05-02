import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:time_tracker/app/home/models/job.dart';

class JobListTile extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;

  const JobListTile({
    @required this.job,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(job.name),
      trailing: Icon(
        Icons.chevron_right,
      ),
    );
  }
}
