library e_notification_platform_fcm;

import 'dart:async';

import 'package:e_notification_platform_interface/e_notification_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<FirebaseApp> _onBackgroundMessage(RemoteMessage message) async {
  return Firebase.initializeApp();
}

class ENotificationPlatformFCM extends ENotificationPlatformInterface {
  StreamController<ENotificationMessage>
      _backgroundNotificationMessageController = StreamController();

  StreamController<ENotificationMessage> _notificationMessageController =
      StreamController();

  StreamController<ENotificationMessage> _notificationClickedController =
      StreamController();

  StreamController<String> _tokenController = StreamController();

  @override
  Stream<ENotificationMessage> get backgroundNotificationMessageStream =>
      _backgroundNotificationMessageController.stream;

  @override
  Stream<ENotificationMessage> get notificationMessageStream =>
      _notificationMessageController.stream;

  @override
  Stream<ENotificationMessage> get notificationClickedStream =>
      _notificationClickedController.stream;

  @override
  Stream<String> get tokenStream => _tokenController.stream;

  late String _deviceId;

  ENotificationMessage? toENotification(RemoteMessage event) {
    RemoteNotification? notification = event.notification;
    if (notification == null) return null;
    return ENotificationMessage(
      id: "${event.messageId}",
      title: notification.title ?? '',
      message: notification.body ?? '',
      payload: event.data,
    );
  }

  @override
  Future<void> init(Map<String, dynamic> params) async {
    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      var message = toENotification(event);
      if (message == null) return;
      _notificationClickedController.sink.add(message);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      var message = toENotification(event);
      if (message == null) return;
      _notificationMessageController.sink.add(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((value) {
      if (value == null) return;
      var message = toENotification(value);
      if (message == null) return;
      _notificationMessageController.sink.add(message);
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

    FirebaseMessaging.instance.onTokenRefresh.listen((event) {
      _tokenController.sink.add(event);
    });

    _deviceId = await FirebaseMessaging.instance.getToken() ?? '';
    _tokenController.sink.add(_deviceId);
  }

  @override
  Future<void> close() async {
    _notificationClickedController.close();
    _backgroundNotificationMessageController.close();
    _notificationMessageController.close();
    _tokenController.close();
  }

  @override
  Future<String> getDeviceId() {
    return Future.value(_deviceId);
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
