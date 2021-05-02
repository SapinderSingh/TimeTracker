import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/app/home/models/job.dart';
import 'package:time_tracker/common_widgets/show_alert_dialog.dart';
import 'package:time_tracker/common_widgets/show_exception_alert_dialog.dart';
import 'package:time_tracker/services/database.dart';

class EditJobPage extends StatefulWidget {
  const EditJobPage({
    Key key,
    @required this.database,
    @required this.job,
  }) : super(key: key);

  static Future<void> show(BuildContext context, {Job job}) async {
    final database = Provider.of<Database>(
      context,
      listen: false,
    );
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditJobPage(
          database: database,
          job: job,
        ),
      ),
    );
  }

  final Database database;
  final Job job;

  @override
  _EditJobPageState createState() => _EditJobPageState();
}

class _EditJobPageState extends State<EditJobPage> {
  final _formKey = GlobalKey<FormState>();

  String _name;
  int _ratePerHour;

  @override
  void initState() {
    super.initState();
    if (widget.job != null) {
      _name = widget.job.name;
      _ratePerHour = widget.job.ratePerHour;
    }
  }

  Future<void> _submit() async {
    if (_validateAndSaveForm()) {
      try {
        final jobs = await widget.database.jobsStream().first;
        final allnames = jobs.map((job) => job.name).toList();
        if (widget.job != null) {
          allnames.remove(widget.job.name);
        }
        if (allnames.contains(_name)) {
          showAlertDialog(
            title: 'Name already used',
            content: 'Please use a different job name.',
            defaultActionText: 'Okay',
            context: context,
          );
        } else {
          final id = widget.job?.id ?? documentIdFromCurrentDate();
          final job = Job(
            name: _name,
            ratePerHour: _ratePerHour,
            id: id,
          );
          await widget.database.setJob(job: job);
          Navigator.of(context).pop();
        }
      } on FirebaseException catch (error) {
        showExceptionAlertDialog(
          context,
          title: 'Operation failed',
          exception: error,
        );
      }
    }
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 2,
        centerTitle: true,
        title: Text(
          widget.job == null ? 'New Job' : 'Edit job',
        ),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child:
              Padding(padding: const EdgeInsets.all(16.0), child: _buildForm()),
        ),
      ),
    );
  }

  Form _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildFormChildren(),
      ),
    );
  }

  List<Widget> _buildFormChildren() {
    return [
      TextFormField(
        initialValue: _name,
        decoration: InputDecoration(labelText: 'Job name'),
        textInputAction: TextInputAction.next,
        validator: (value) {
          return value.isNotEmpty ? null : 'Name can\'t be empty';
        },
        onSaved: (value) {
          _name = value;
        },
      ),
      TextFormField(
        initialValue: _ratePerHour != null ? '$_ratePerHour' : null,
        keyboardType: TextInputType.numberWithOptions(),
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(labelText: 'Rate Per Hour'),
        onSaved: (value) {
          _ratePerHour = int.tryParse(value) ?? 0;
        },
      ),
    ];
  }
}
