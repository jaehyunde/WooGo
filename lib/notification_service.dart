// lib/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // 싱글톤 패턴
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notiPlugin =
  FlutterLocalNotificationsPlugin();

  // 1. 초기화 (앱 켤 때 실행)
  Future<void> init() async {
    tz_data.initializeTimeZones(); // 시간대 데이터 로딩

    // 안드로이드 설정
    const AndroidInitializationSettings androidSetting =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 설정 (권한 요청 포함)
    const DarwinInitializationSettings iosSetting = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSetting,
      iOS: iosSetting,
    );

    // ✅ v21+: initialize는 named parameter(settings:) 사용
    await _notiPlugin.initialize(
      settings: initSettings,
      // 필요하면 아래 콜백을 활성화해서 탭 이벤트 처리 가능
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // TODO: 알림 탭 처리 (payload 등)
      },
      // 백그라운드 탭까지 처리하려면 별도 @pragma 엔트리포인트 함수가 필요함.
      // onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  // 2. 알림 예약 함수
  Future<void> scheduleNotification({
    required String itemId,
    required String itemName,
    required DateTime expiryDate,
  }) async {
    // 유통기한 하루 전
    final scheduledDay = expiryDate.subtract(const Duration(days: 1));
    final now = DateTime.now();

    // 이미 지난 날짜면 예약 안 함
    if (scheduledDay.isBefore(now)) return;

    // 알림 ID 생성
    final int notificationId = itemId.hashCode;

    // ✅ "오전 9시"로 고정 (로컬 타임존 기준)
    final tz.TZDateTime scheduledAt9am = tz.TZDateTime(
      tz.local,
      scheduledDay.year,
      scheduledDay.month,
      scheduledDay.day,
      9, // 오전 9시
      0,
      0,
    );

    final tz.TZDateTime tzNow = tz.TZDateTime.now(tz.local);

    if (scheduledAt9am.isBefore(now)) {
      // 예약하려는 9시가 이미 지나버린 과거라면?
      // 쿨하게 알림을 포기하고 함수를 종료(return)해서 에러를 막습니다.
      print("⏰ 이미 지나간 시간이라 $itemName 알림을 예약하지 않습니다.");
      return;
    }

    await _notiPlugin.zonedSchedule(
      // ✅ v21+: 전부 named parameter
      id: notificationId,
      title: '유통기한 임박! 🚨',
      body: '$itemName의 유통기한이 하루 남았습니다. 빨리 드세요!',
      scheduledDate: scheduledAt9am,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'expiry_channel',
          '유통기한 알림',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      // ❌ v21 흐름에서는 uiLocalNotificationDateInterpretation가 제거/불필요한 방향
      // (iOS 10 이하 대상 옵션이라 최신 Flutter/iOS 타겟에선 의미가 거의 없음)
    );

    // ignore: avoid_print
    print("🔔 알림 예약 완료: $itemName (${scheduledAt9am.toString()})");
  }

  // 3. 알림 취소 함수
  Future<void> cancelNotification(String itemId) async {
    final int notificationId = itemId.hashCode;

    // ✅ v21+: cancel도 named parameter(id:)
    await _notiPlugin.cancel(id: notificationId);

    // ignore: avoid_print
    print("🔕 알림 취소됨: ID $itemId");
  }

  Future<void> cancelAllNotifications() async {
    await _notiPlugin.cancelAll();

    // ignore: avoid_print
    print("🔕 모든 알림이 초기화되었습니다.");
  }

  // 리스트를 받아서 한꺼번에 알림 예약
  Future<void> syncNotifications(List<dynamic> items) async {
    await cancelAllNotifications();

    for (var item in items) {
      // 이미 지났거나, 소비/버림 상태인건 패스
      if (item.status != 'normal') continue;

      await scheduleNotification(
        itemId: item.id!,
        itemName: item.name,
        expiryDate: item.expiryDate,
      );
    }

    // ignore: avoid_print
    print("🔄 총 ${items.length}개의 아이템에 대해 알림 동기화 완료!");
  }
}