import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:worth_network/core/navigator/app_pages.dart';
import 'package:worth_network/core/repo/action_repo.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications like validation requests and confirmations.',
    importance: Importance.high,
    playSound: true,
  );

  bool _initialized = false;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot>? _firestoreNotificationsSubscription;
  DateTime? _serviceInitTime;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _serviceInitTime = DateTime.now();

    // 1. Set background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Request permissions (iOS & Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: false,
    );

    print('User notification permission status: ${settings.authorizationStatus}');

    // 3. Initialize Local Notifications for Foreground Banners
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
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
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final Map<String, dynamic> data = jsonDecode(response.payload!);
            _handleNotificationNavigation(data);
          } catch (e) {
            print('Error parsing notification payload: $e');
          }
        }
      },
    );

    // Create channel on Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Set foreground presentation options for iOS
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 4. Listen for FCM Token & update in Firestore on login
    _setupAuthAndFirestoreListeners();

    _fcm.onTokenRefresh.listen((token) {
      _saveTokenToFirestore(token);
    });

    // 5. Handle Foreground FCM Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // 6. Handle Notification Tap when App is in Background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened from background: ${message.data}');
      _handleNotificationNavigation(message.data);
    });

    // 7. Handle Notification Tap when App was Terminated
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      print('Notification opened from terminated state: ${initialMessage.data}');
      _handleNotificationNavigation(initialMessage.data);
    }
  }

  /// Setup real-time listeners for auth state changes and in-app notifications
  void _setupAuthAndFirestoreListeners() {
    _authSubscription?.cancel();
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        updateFcmToken();
        _startFirestoreNotificationListener(user.uid);
      } else {
        _firestoreNotificationsSubscription?.cancel();
      }
    });

    // If user is already logged in on launch
    if (_auth.currentUser != null) {
      updateFcmToken();
      _startFirestoreNotificationListener(_auth.currentUser!.uid);
    }
  }

  /// Real-time stream of notifications from Firestore to trigger local in-app push banners
  void _startFirestoreNotificationListener(String uid) {
    _firestoreNotificationsSubscription?.cancel();
    _firestoreNotificationsSubscription = _firestore
        .collection('notifications')
        .where('targetUserId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            final Timestamp? createdAt = data['createdAt'] as Timestamp?;
            // Show banner if notification was created after service startup (or within last 10s)
            final isRecent = createdAt == null ||
                (_serviceInitTime != null &&
                    createdAt.toDate().isAfter(_serviceInitTime!.subtract(const Duration(seconds: 10))));

            if (isRecent) {
              final title = data['title'] as String? ?? 'Worth Network';
              final body = data['body'] as String? ?? data['description'] as String? ?? '';
              final Map<String, dynamic> notificationPayload = {
                ...data,
                'docId': change.doc.id,
                'id': change.doc.id,
              };
              _showFirestoreLocalBanner(
                id: change.doc.id.hashCode,
                title: title,
                body: body,
                payload: notificationPayload,
              );
            }
          }
        }
      }
    }, onError: (e) {
      print('Error in Firestore notifications listener: $e');
    });
  }

  /// Convert non-encodable objects like Timestamp to JSON encodable primitives
  Map<String, dynamic> _cleanPayloadForJson(Map<String, dynamic> raw) {
    final Map<String, dynamic> cleaned = {};
    raw.forEach((key, value) {
      if (value is Timestamp) {
        cleaned[key] = value.toDate().toIso8601String();
      } else if (value is DateTime) {
        cleaned[key] = value.toIso8601String();
      } else if (value is Map) {
        cleaned[key] = _cleanPayloadForJson(Map<String, dynamic>.from(value));
      } else if (value is String || value is num || value is bool || value == null) {
        cleaned[key] = value;
      } else {
        cleaned[key] = value.toString();
      }
    });
    return cleaned;
  }

  /// Show heads-up local banner for real-time Firestore notifications
  Future<void> _showFirestoreLocalBanner({
    required int id,
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    await _localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(_cleanPayloadForJson(payload)),
    );
  }

  /// Fetch and update current FCM token for logged-in user
  Future<void> updateFcmToken() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        String? apnsToken = await _fcm.getAPNSToken();
        if (apnsToken == null) {
          print('APNs token not available yet (e.g. running on iOS Simulator). FCM token will be saved automatically when APNs resolves on a physical device.');
          return;
        }
      }
      String? token = await _fcm.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  /// Save FCM token to user document in Firestore
  Future<void> _saveTokenToFirestore(String token) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore.collection('users').doc(uid).set({
        'fcmToken': token,
        'fcmTokens': FieldValue.arrayUnion([token]),
        'platform': defaultTargetPlatform.name,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('Updated FCM token in Firestore for user $uid');
    } catch (e) {
      print('Error saving FCM token to Firestore: $e');
    }
  }

  /// Show heads-up banner when notification arrives in foreground
  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    String title = notification?.title ?? message.data['title'] ?? 'Worth Network Notification';
    String body = notification?.body ?? message.data['body'] ?? '';

    _localNotifications.show(
      notification.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: android?.smallIcon ?? '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// Handle navigation on notification tap
  void _handleNotificationNavigation(Map<String, dynamic> data) async {
    final docId = (data['docId'] ?? data['id']) as String?;
    final actionId = data['actionId'] as String?;
    final type = data['type'] as String?;

    // Automatically mark notification as read in Firestore when tapped
    if (docId != null && docId.isNotEmpty) {
      try {
        final actionRepo = ActionRepository();
        await actionRepo.toggleNotificationReadStatus(docId, false);
      } catch (e) {
        print('Error marking tapped notification as read: $e');
      }
    }

    if (actionId == null || actionId.isEmpty) {
      Pages.appRouter.push('/notifications');
      return;
    }

    try {
      final actionRepo = ActionRepository();
      final action = await actionRepo.getActionStream(actionId).first;

      if (action != null) {
        if (type == 'validation_request' || type == 'validation_requested') {
          Pages.appRouter.push('/validation-request', extra: action);
        } else {
          Pages.appRouter.push('/action-details', extra: action);
        }
      } else {
        Pages.appRouter.push('/notifications');
      }
    } catch (e) {
      print('Error handling notification tap navigation: $e');
      Pages.appRouter.push('/notifications');
    }
  }

  /// Send FCM Notification & Store Firestore Notification Entry
  Future<void> sendNotification({
    required String targetUserId,
    required String title,
    required String body,
    required String type,
    required String actionId,
    Map<String, dynamic>? extraData,
  }) async {
    final senderUser = _auth.currentUser;
    final senderUid = senderUser?.uid ?? '';

    // 1. Store in Firestore notifications collection (Real-time in-app feed)
    try {
      await _firestore.collection('notifications').add({
        'targetUserId': targetUserId,
        'requesterId': senderUid,
        'type': type,
        'title': title,
        'description': body,
        'body': body,
        'actionId': actionId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        if (extraData != null) ...extraData,
      });
      print('Saved notification entry in Firestore for user $targetUserId');
    } catch (e) {
      print('Error writing notification document: $e');
    }

    // 2. Fetch target user's FCM token from Firestore
    try {
      final userDoc = await _firestore.collection('users').doc(targetUserId).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data() ?? {};
      final fcmToken = userData['fcmToken'] as String?;

      if (fcmToken != null && fcmToken.isNotEmpty) {
        print('FCM notification prepared for target token: $fcmToken');
      }
    } catch (e) {
      print('Error fetching user FCM token for notification: $e');
    }
  }
}
