import 'package:flutter/foundation.dart';
import '../persistence/app_storage.dart';

enum ReportTargetType { post, reply }

class UserReport {
  final String id;
  final ReportTargetType targetType;
  final String targetId;
  final String reportedUserId;
  final String reason;
  final String? note;
  final int createdAtMs;

  const UserReport({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.reportedUserId,
    required this.reason,
    required this.createdAtMs,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'targetType': targetType.name,
        'targetId': targetId,
        'reportedUserId': reportedUserId,
        'reason': reason,
        'note': note,
        'createdAtMs': createdAtMs,
      };

  static UserReport fromJson(Map<String, dynamic> json) => UserReport(
        id: (json['id'] ?? '').toString(),
        targetType: ReportTargetType.values.firstWhere(
          (e) => e.name == (json['targetType'] ?? 'post'),
          orElse: () => ReportTargetType.post,
        ),
        targetId: (json['targetId'] ?? '').toString(),
        reportedUserId: (json['reportedUserId'] ?? '').toString(),
        reason: (json['reason'] ?? '').toString(),
        note: (json['note'] as String?)?.toString(),
        createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
      );
}

class ReportController extends ChangeNotifier {
  final AppStorage storage;

  late final List<UserReport> _reports;

  ReportController({required this.storage}) {
    _reports = storage.loadReportsRaw().map(UserReport.fromJson).toList();
  }

  List<UserReport> get reports => List.unmodifiable(_reports);

  Future<void> submit(UserReport report) async {
    _reports.add(report);
    await storage.saveReportsRaw(_reports.map((r) => r.toJson()).toList());
    notifyListeners();
  }

  Future<void> clear() async {
    _reports.clear();
    await storage.saveReportsRaw(const []);
    notifyListeners();
  }
}
