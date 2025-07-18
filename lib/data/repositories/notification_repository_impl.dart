import '../../domain/repositories/notification_repository.dart';
import '../../domain/entities/notification.dart';
import '../models/notification_model.dart';
import '../sources/notification_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationService service;
  NotificationRepositoryImpl(this.service);

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final models = await service.getNotifications();
    return models;
  }

  @override
  Future<void> markAsRead(String id) async {
    await service.markAsRead(id);
  }

  @override
  Future<void> markAllAsRead() async {
    await service.markAllAsRead();
  }
}
