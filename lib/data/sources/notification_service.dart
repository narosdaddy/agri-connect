import 'package:dio/dio.dart';
import '../models/notification_model.dart';

class NotificationService {
  final Dio dio;
  NotificationService(this.dio);

  Future<List<NotificationModel>> getNotifications() async {
    final response = await dio.get('/notifications/me');
    return (response.data as List)
        .map((json) => NotificationModel.fromJson(json))
        .toList();
  }

  Future<void> markAsRead(String id) async {
    await dio.post('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await dio.post('/notifications/read-all');
  }
}
