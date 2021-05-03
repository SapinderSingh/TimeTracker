import 'package:flutter/foundation.dart';
import 'package:time_tracker/app/home/models/job.dart';
import 'package:time_tracker/services/api_path.dart';
import 'package:time_tracker/services/firestore_service.dart';

abstract class Database {
  Future<void> setJob({Job job});
  Stream<List<Job>> jobsStream();
  Future<void> deleteJob(Job job);
}

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class FirestoreDatabase implements Database {
  FirestoreDatabase({
    @required this.uid,
  }) : assert(uid != null);

  final String uid;
  final _service = FirestoreService.instance;

  @override
  Future<void> setJob({Job job}) async => await _service.setData(
        path: ApiPath.job(
          uid: uid,
          jobId: job.id,
        ),
        data: job.toMap(),
      );

  @override
  Future<void> deleteJob(Job job) => _service.deleteData(
        path: ApiPath.job(
          uid: uid,
          jobId: job.id,
        ),
      );

  @override
  Stream<List<Job>> jobsStream() => _service.collectionStream(
        path: ApiPath.jobs(uid: uid),
        builder: (data, documentId) => Job.fromMap(data, documentId),
      );
}
