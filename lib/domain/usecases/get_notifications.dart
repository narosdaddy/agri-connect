import '../repositories/notification_repository.dart';
import '../entities/notification.dart';

class GetNotifications {
  final NotificationRepository repository;
  const GetNotifications(this.repository);

  Future<List<NotificationEntity>> call() {
    return repository.getNotifications();
  }
}
