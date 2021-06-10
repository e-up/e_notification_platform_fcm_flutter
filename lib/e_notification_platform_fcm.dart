library e_notification_platform_fcm;

import 'dart:async';

import 'package:e_notification_platform_interface/e_notification_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ENotificationPlatformFCM extends ENotificationPlatformInterface {
  StreamController<ENotificationMessage>
      _backgroundNotificationMessageController = StreamController();

  StreamController<ENotificationMessage> _notificationMessageController =
      StreamController();

  @override
  late Stream<ENotificationMessage> backgroundNotificationMessageStream;

  @override
  late Stream<ENotificationMessage> notificationMessageStream;

  late String _deviceId;

  @override
  Future<void> init(Map<String, dynamic> params) async {
    backgroundNotificationMessageStream =
        _backgroundNotificationMessageController.stream;
    notificationMessageStream = _notificationMessageController.stream;

    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage((message) async {
      RemoteNotification notification = message.notification!;
      _backgroundNotificationMessageController.sink.add(ENotificationMessage(
          id: message.messageId ?? '',
          title: notification.title ?? '',
          message: notification.body ?? ''));
      await Firebase.initializeApp();
    });

    await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        criticalAlert: true,
        carPlay: true,
        provisional: true,
        sound: true);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);

    _deviceId = await FirebaseMessaging.instance.getToken() ?? '';

    FirebaseMessaging.onMessage.listen((event) {
      RemoteNotification notification = event.notification!;
      _notificationMessageController.sink.add(ENotificationMessage(
          id: "${event.messageId}",
          title: notification.title ?? '',
          message: notification.body ?? ''));
    });
  }

  @override
  Future<void> close() async {
    _backgroundNotificationMessageController.close();
    _notificationMessageController.close();
  }

  @override
  Future<String> getDeviceId() {
    return Future.value(_deviceId);
  }

  @override
  Future<List<String>> getTags() {
    throw UnimplementedError();
  }

  @override
  Future<String> setTag(String tag) {
    throw UnimplementedError();
  }

  @override
  Future<void> subscribe(String topic) async {
    FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  @override
  Future<void> unsubscribe(String topic) {
    return FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
}
