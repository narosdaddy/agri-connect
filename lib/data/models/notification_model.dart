import '../../domain/entities/notification.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required String id,
    required String message,
    required bool lue,
  }) : super(id: id, message: message, lue: lue);

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as String,
        message: json['message'] as String,
        lue: json['lue'] as bool,
      );

  Map<String, dynamic> toJson() => {'id': id, 'message': message, 'lue': lue};
}
