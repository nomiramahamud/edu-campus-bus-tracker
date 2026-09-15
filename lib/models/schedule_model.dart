class ScheduleModel {
  final String scheduleId;
  final String time;
  final String endTime;
  final String routeId;
  final String routeName;
  final String busId;
  final String busName;
  final String status; // "onTime" | "delayed"
  final String period; // "morning" | "mid_morning" | "afternoon"

  ScheduleModel({
    required this.scheduleId,
    required this.time,
    required this.endTime,
    required this.routeId,
    required this.routeName,
    required this.busId,
    required this.busName,
    this.status = 'onTime',
    this.period = 'morning',
  });

  bool get isDelayed => status == 'delayed';

  factory ScheduleModel.fromMap(String id, Map<String, dynamic> map) {
    return ScheduleModel(
      scheduleId: id,
      time: map['time'] ?? '',
      endTime: map['endTime'] ?? '',
      routeId: map['routeId'] ?? '',
      routeName: map['routeName'] ?? '',
      busId: map['busId'] ?? '',
      busName: map['busName'] ?? '',
      status: map['status'] ?? 'onTime',
      period: map['period'] ?? 'morning',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'endTime': endTime,
      'routeId': routeId,
      'routeName': routeName,
      'busId': busId,
      'busName': busName,
      'status': status,
      'period': period,
    };
  }
}