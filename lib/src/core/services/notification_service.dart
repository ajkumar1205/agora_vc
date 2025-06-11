import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:agora_vc/src/domain/models/incoming_call_model.dart';
import 'package:agora_vc/src/domain/models/user/user_model.dart';
import 'package:agora_vc/src/core/services/navigation_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final NavigationService _navigationService = NavigationService();

  static const String _callChannelId = 'video_call_channel';
  static const String _callChannelName = 'Video Calls';
  static const String _callChannelDescription =
      'Notifications for incoming video calls';

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Request permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ FCM permissions granted');
    } else {
      debugPrint('❌ FCM permissions denied');
      return;
    }

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    debugPrint('📱 FCM Token: $token');

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle initial message if app was launched from notification
    RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    _isInitialized = true;
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _callChannelId,
      _callChannelName,
      description: _callChannelDescription,
      importance: Importance.max,
      showBadge: true,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📨 Foreground message received: ${message.messageId}');

    if (message.data['type'] == 'incoming_call') {
      // Show local notification with call actions
      await _showCallNotification(message);
    }
  }

  Future<void> _handleNotificationTap(RemoteMessage message) async {
    debugPrint('👆 Notification tapped: ${message.messageId}');

    if (message.data['type'] == 'incoming_call') {
      // Navigate to video call screen or handle call acceptance
      await _handleCallFromNotification(message.data);
    }
  }

  void _onNotificationResponse(NotificationResponse response) async {
    debugPrint('🔔 Notification response: ${response.actionId}');

    if (response.payload != null) {
      Map<String, dynamic> data = jsonDecode(response.payload!);

      switch (response.actionId) {
        case 'accept_call':
          await _acceptCallFromNotification(data);
          break;
        case 'decline_call':
          await _declineCallFromNotification(data);
          break;
        default:
          // Notification tapped (no action button)
          await _handleCallFromNotification(data);
          break;
      }
    }
  }

  Future<void> _showCallNotification(RemoteMessage message) async {
    final data = message.data;
    final callerName = data['caller_name'] ?? 'Unknown';
    final callerId = data['caller_id'] ?? '';
    final channelName = data['channel_name'] ?? '';

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _callChannelId,
          _callChannelName,
          channelDescription: _callChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.call,
          fullScreenIntent: true,
          autoCancel: false,
          ongoing: true,
          showWhen: true,
          usesChronometer: true,
          chronometerCountDown: false,
          actions: [
            AndroidNotificationAction(
              'decline_call',
              'Decline',
              icon: DrawableResourceAndroidBitmap('@drawable/ic_call_end'),
              cancelNotification: true,
            ),
            AndroidNotificationAction(
              'accept_call',
              'Accept',
              icon: DrawableResourceAndroidBitmap('@drawable/ic_call'),
              cancelNotification: true,
            ),
          ],
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'CALL_CATEGORY',
      interruptionLevel: InterruptionLevel.critical,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      callerId.hashCode,
      'Incoming Video Call',
      '$callerName is calling...',
      notificationDetails,
      payload: jsonEncode(data),
    );
  }

  Future<void> _acceptCallFromNotification(Map<String, dynamic> data) async {
    debugPrint('✅ Accepting call from notification');

    // Cancel the notification
    await _localNotifications.cancel(data['caller_id'].hashCode);

    // Create incoming call model
    UserModel caller = UserModel(
      uid: data['caller_id'],
      name: data['caller_name'],
      email: '',
    );

    IncomingCallModel incomingCall = IncomingCallModel(
      caller: caller,
      channelName: data['channel_name'],
    );

    // Send acceptance through FCM
    await _sendCallResponse(data['caller_id'], data['channel_name'], true);

    // Launch app and navigate to call screen
    await _launchApp({'action': 'accept_call', 'incoming_call': incomingCall});
  }

  Future<void> _declineCallFromNotification(Map<String, dynamic> data) async {
    debugPrint('❌ Declining call from notification');

    // Cancel the notification
    await _localNotifications.cancel(data['caller_id'].hashCode);

    // Send decline response through FCM
    await _sendCallResponse(data['caller_id'], data['channel_name'], false);
  }

  Future<void> _handleCallFromNotification(Map<String, dynamic> data) async {
    debugPrint('📱 Handling call from notification tap');

    // Cancel the notification
    await _localNotifications.cancel(data['caller_id'].hashCode);

    // Create incoming call model
    UserModel caller = UserModel(
      uid: data['caller_id'],
      name: data['caller_name'],
      email: '',
    );

    IncomingCallModel incomingCall = IncomingCallModel(
      caller: caller,
      channelName: data['channel_name'],
    );

    // Launch app and show incoming call dialog
    await _launchApp({
      'action': 'show_incoming_call',
      'incoming_call': incomingCall,
    });
  }

  Future<void> _sendCallResponse(
    String callerId,
    String channelName,
    bool accepted,
  ) async {
    debugPrint(
      '📤 Sending call response: ${accepted ? 'accepted' : 'declined'}',
    );

    // Send FCM message to caller
    final responseData = {
      'type': accepted ? 'call_accepted' : 'call_declined',
      'target_id': callerId,
      'channel_name': channelName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    // TODO: Send this through your backend/FCM service
    // For now, we'll use the signaling service
    await _sendFCMResponse(responseData);
  }

  Future<void> _sendFCMResponse(Map<String, dynamic> data) async {
    // This should be implemented to send FCM message to the caller
    // You can use your backend service or Firebase Functions
    debugPrint('📡 Sending FCM response: $data');
  }

  Future<void> _launchApp(Map<String, dynamic> data) async {
    debugPrint('🚀 Launching app with data: $data');
    await _navigationService.handleNotificationNavigation(data);
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  Future<void> cancelCallNotification(String callerId) async {
    await _localNotifications.cancel(callerId.hashCode);
  }

  void dispose() {
    // Clean up if needed
  }
}

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔔 Background message received: ${message.messageId}');

  if (message.data['type'] == 'incoming_call') {
    // Show local notification for incoming call
    final notificationService = NotificationService();
    await notificationService._showCallNotification(message);
  }
}
