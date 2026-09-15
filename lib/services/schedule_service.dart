import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bus_app/models/schedule_model.dart';

class ScheduleService {
  final _schedulesRef = FirebaseFirestore.instance.collection('schedules');

  Stream<List<ScheduleModel>> getSchedules() {
    return _schedulesRef.orderBy('time').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => ScheduleModel.fromMap(doc.id, doc.data()))
        .toList());
  }
}