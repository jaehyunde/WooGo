import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'item_model.dart';
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FridgeService {
  static final FridgeService _instance = FridgeService._internal();

  factory FridgeService() => _instance;

  FridgeService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String? currentHouseholdId;

  Future<String?> loadSavedHouseholdId() async {
    final prefs = await SharedPreferences.getInstance();
    currentHouseholdId = prefs.getString('last_household_id');
    print("📂 저장된 ID 로드: $currentHouseholdId");
    return currentHouseholdId;
  }

// setHouseholdId도 비동기로 업그레이드합니다.
  Future<void> setHouseholdId(String id) async {
    currentHouseholdId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_household_id', id);
  }

  // 2. 기기에 저장된 ID 불러오기
  Future<String?> loadSavedId() async {
    final prefs = await SharedPreferences.getInstance();
    currentHouseholdId = prefs.getString('last_household_id');
    print("📂 로드된 ID: $currentHouseholdId");
    return currentHouseholdId;
  }

  // 3. 로그아웃/삭제 시 저장된 ID 삭제
  Future<void> clearSavedId() async {
    currentHouseholdId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_household_id');
  }

  Stream<String> getFridgeNameStream() {
    if (currentHouseholdId == null) return Stream.value("우리집 냉장고");
    return _db
        .collection('households')
        .doc(currentHouseholdId)
        .snapshots()
        .map((snapshot) {
      return snapshot.data()?['name'] ?? "우리집 냉장고";
    });
  }

  void logout() {
    currentHouseholdId = null;
  }
  // 초기 기본 카테고리 세팅
  Future<void> initializeDefaultCategories() async {
    if (currentHouseholdId == null) return;

    // 1. 현재 DB에 있는 카테고리 이름들을 먼저 가져옵니다.
    var snapshot = await _db.collection('households').doc(currentHouseholdId).collection('categories').get();

    // DB에 있는 이름들만 뽑아서 리스트로 만듭니다. (예: ['육류', '유제품'])
    List<String> existingNames = snapshot.docs.map((doc) => doc['name'] as String).toList();

    // 2. 우리가 원하는 완벽한 기본 리스트 (과일 포함!)
    Map<String, int> defaults = {
      '빵':7,
      '육류': 4,
      '유제품': 7,
      '채소': 5,
      '과일': 7,
      '해산물':3,
      '즉석': 180,
      '음료': 180,
      '기타': 14,
    };

    // 3. 하나씩 비교해서 "없는 것만" 추가합니다.
    defaults.forEach((name, days) async {
      if (!existingNames.contains(name)) { // DB에 이름이 없다면?
        await addCategory(name, days);     // 추가해라!
      }
    });
  }
  // 카테고리 수정기능
  Future<void> updateCategory(String docId, String newName, int newDays) async {
    if (currentHouseholdId == null) return;

    await _db
        .collection('households')
        .doc(currentHouseholdId)
        .collection('categories')
        .doc(docId) // 수정할 문서 ID
        .update({
      'name': newName,
      'defaultDays': newDays,
    });
  }

  // 1. 즐겨찾기 목록 가져오기
  Stream<QuerySnapshot> getFavoritesStream() {
    if (currentHouseholdId == null) return Stream.empty();
    return _db
        .collection('households')
        .doc(currentHouseholdId)
        .collection('favorites')
        .orderBy('name')
        .snapshots();
  }

  // 2. 즐겨찾기 추가
  Future<void> addFavorite(String name, String category) async {
    if (currentHouseholdId == null) return;
    await _db
        .collection('households')
        .doc(currentHouseholdId)
        .collection('favorites')
        .add({
      'name': name,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 즐겨찾기 삭제
  Future<void> deleteFavorite(String docId) async {
    if (currentHouseholdId == null) return;
    await _db
        .collection('households')
        .doc(currentHouseholdId)
        .collection('favorites')
        .doc(docId)
        .delete();
  }

  Future<void> deleteHousehold() async {
    if (currentHouseholdId == null) return;
    final String householdIdToDelete = currentHouseholdId!;

    try {
      User? user = FirebaseAuth.instance.currentUser;
      final String? uid = user?.uid;

      // 1. [Firestore] 유저 문서 "전체" 삭제 ✅
      // 필드만 지우는 것이 아니라 문서 자체를 날려버립니다.
      if (uid != null) {
        print("유저 문서 삭제 시도: $uid");
        await _db.collection('users').doc(uid).delete();
      }

      // 2. 하위 컬렉션 삭제 (아이템 및 카테고리)
      // (기존에 작성하신 루프 코드를 여기에 유지하세요)
      var itemsSnapshot = await _db.collection('households').doc(householdIdToDelete).collection('items').get();
      for (var doc in itemsSnapshot.docs) {
        await doc.reference.delete();
      }

      var catSnapshot = await _db.collection('households').doc(householdIdToDelete).collection('categories').get();
      for (var doc in catSnapshot.docs) {
        await doc.reference.delete();
      }

      // 3. 냉장고 본체 문서 삭제
      await _db.collection('households').doc(householdIdToDelete).delete();

      // 4. 로컬 저장소(SharedPreferences) ID 삭제
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('householdId');

      // 5. ★ 마지막에 로그아웃 ★ ✅
      // 모든 DB 삭제 작업이 끝난 후 로그아웃을 해야 권한(Permission) 에러가 나지 않습니다.
      await FirebaseAuth.instance.signOut();

      currentHouseholdId = null;
      print("✅ 유저 데이터 및 냉장고 데이터 완전 삭제 완료");

    } catch (e) {
      print("❌ 삭제 중 오류 발생: $e");
      rethrow;
    }
  }

  // 냉장고 이름 수정하기
  Future<void> updateFridgeName(String newName) async {
    if (currentHouseholdId == null) return;
    await _db
        .collection('households')
        .doc(currentHouseholdId)
        .update({'name': newName});
  }

  // --- 아이템 관련 기능 ---
  Stream<List<FridgeItem>> getFridgeItems() {
    // 현재 ID가 잘 살아있는지 확인
    print("📢 데이터 요청 시작! 현재 Household ID: $currentHouseholdId");

    if (currentHouseholdId == null) {
      print("⚠️ ID가 없어서 빈 리스트를 반환합니다.");
      return Stream.value([]);
    }

    return _db
        .collection('households')
        .doc(currentHouseholdId)
        .collection('items')
        .where('status', isEqualTo: 'normal') // 이 조건이 핵심
        .orderBy('expiryDate')
        .snapshots()
        .map((snapshot) {
      // 2. 데이터가 몇 개나 왔는지 확인
      print("✅ 데이터 도착! 문서 개수: ${snapshot.docs.length}개");

      if (snapshot.docs.isEmpty) {
        print("❓ 데이터가 0개입니다. (조건에 맞는게 없거나 컬렉션이 비었음)");
      }

      return snapshot.docs.map((doc) {
        // 3. 가져온 데이터 내용 살짝 엿보기
        final data = doc.data();
        print("  - 아이템: ${data['name']}, 상태: ${data['status']}");
        return FridgeItem.fromSnapshot(doc);
      }).toList();
    });
    if (currentHouseholdId == null) return Stream.value([]);
    return _db
        .collection('households')
        .doc(currentHouseholdId)
        .collection('items')
        .where('status', isEqualTo: 'normal')
        .orderBy('expiryDate')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => FridgeItem.fromSnapshot(doc)).toList());
  }

  // 2. [쓰레기통용] 버린 아이템만 가져오기
  Stream<List<FridgeItem>> getTrashItems() {
    if (currentHouseholdId == null) return Stream.value([]);
    return _db
        .collection('households')
        .doc(currentHouseholdId)
        .collection('items')
        .where('status', isEqualTo: 'trash') // ★ 버린 것만 가져옴
        .orderBy('updatedAt', descending: true) // 최근에 버린 순서
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => FridgeItem.fromSnapshot(doc)).toList());
  }

  // ★ 아이템 유통기한 수정 함수
  // fridge_service.dart

  Future<void> updateItemExpiryDate(String itemId, DateTime newDate) async {
    if (currentHouseholdId == null) return;

    // ★ [핵심 수정] 시간 정보를 자정(00:00:00)으로 초기화하여 저장
    DateTime normalizedDate = DateTime(newDate.year, newDate.month, newDate.day);

    await _db
        .collection('households')
        .doc(currentHouseholdId)
        .collection('items')
        .doc(itemId)
        .update({
      'expiryDate': Timestamp.fromDate(normalizedDate), // 00:00:00으로 저장됨
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 3. 아이템 상태 변경 (먹음/버림 처리)
  Future<void> updateItemStatus(String itemId, String newStatus) async {
    if (currentHouseholdId == null) return;
    await _db
        .collection('households')
        .doc(currentHouseholdId)
        .collection('items')
        .doc(itemId)
        .update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(), // 언제 처리했는지 기록
    });
  }

  // 4. 수량 변경
  Future<void> updateItemQuantity(String itemId, int newQuantity) async {
    if (currentHouseholdId == null) return;
    await _db
        .collection('households')
        .doc(currentHouseholdId)
        .collection('items')
        .doc(itemId)
        .update({'quantity': newQuantity});
  }

  // 5. 완전히 삭제 (쓰레기통 비우기 등)
  Future<void> deleteItemPermanently(String itemId) async {
    if (currentHouseholdId == null) return;
    await _db.collection('households').doc(currentHouseholdId).collection(
        'items').doc(itemId).delete();
  }

  Future<void> addItem(FridgeItem item) async {
    if (currentHouseholdId == null) return;

    // 1. 이름, 카테고리, 상태가 같은 아이템을 찾되,
    // ★ [수정] 보관 장소(storageLocation)까지 완벽히 일치하는지 확인합니다.
    final query = await _db
        .collection('households')
        .doc(currentHouseholdId)
        .collection('items')
        .where('name', isEqualTo: item.name)
        .where('category', isEqualTo: item.category)
        .where('storageLocation', isEqualTo: item.storageLocation) // ★ 장소 조건 추가
        .where('status', isEqualTo: 'normal')
        .get();

    DocumentSnapshot? duplicateDoc;

    // 2. 찾아온 목록 중에서 '유통기한'까지 똑같은 게 있는지 확인합니다.
    for (var doc in query.docs) {
      DateTime dbDate = (doc['expiryDate'] as Timestamp).toDate();
      if (_isSameDay(dbDate, item.expiryDate)) {
        duplicateDoc = doc;
        break;
      }
    }

    // 3. 이름, 카테고리, 장소, 날짜가 모두 같다면 수량 합치기
    if (duplicateDoc != null) {
      int currentQty = duplicateDoc['quantity'];
      await _db
          .collection('households')
          .doc(currentHouseholdId)
          .collection('items')
          .doc(duplicateDoc.id)
          .update({
        'quantity': currentQty + item.quantity,
      });

      print("♻️ 기존 아이템(동일 장소)과 합쳤습니다: ${item.name}");
    }
    // 4. 하나라도 다르면(장소가 다르거나 날짜가 다르면) 별개의 아이템으로 생성
    else {
      await _db
          .collection('households')
          .doc(currentHouseholdId)
          .collection('items')
          .add(item.toMap());

      print("✨ 새 장소 혹은 새 날짜의 아이템을 생성했습니다: ${item.name}");
    }
  }

  // [보조 함수] 두 날짜가 같은 날인지 확인 (시간 무시)
  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  Future<void> deleteItem(String itemId) async {
    if (currentHouseholdId == null) return;
    await _db.collection('households').doc(currentHouseholdId).collection(
        'items').doc(itemId).delete();
  }

  Future<String> getInviteCode() async {
    if (currentHouseholdId == null) return "Error";
    var doc = await _db.collection('households').doc(currentHouseholdId).get();
    return doc.data()?['inviteCode'] ?? "No Code";
  }

  // --- [신규] 카테고리 관련 기능 ---

  // 1. 카테고리 목록 불러오기 (실시간)
  Stream<QuerySnapshot> getCategoriesStream() {
    if (currentHouseholdId == null) return Stream.empty();
    return _db
        .collection('households')
        .doc(currentHouseholdId)
        .collection('categories')
        .orderBy('order') // 순서대로 정렬 (옵션)
        .snapshots();
  }
  // 1-1. 카테고리 이름 목록만 한 번에 불러오기 (정보 수정 팝업용)
  Future<List<String>> getCategoryNames() async {
    if (currentHouseholdId == null) return [];

    try {
      var snapshot = await _db
          .collection('households')
          .doc(currentHouseholdId)
          .collection('categories')
          .orderBy('order')
          .get();

      // 문서들 안에서 'name' 필드만 쏙쏙 뽑아서 String 리스트로 만듭니다.
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      print("카테고리 목록 불러오기 실패: $e");
      return [];
    }
  }

  // 2. 카테고리 추가
  Future<void> addCategory(String name, int defaultDays) async {
    if (currentHouseholdId == null) return;
    await _db.collection('households').doc(currentHouseholdId).collection(
        'categories').add({
      'name': name,
      'defaultDays': defaultDays,
      'order': DateTime
          .now()
          .millisecondsSinceEpoch, // 간단하게 등록순 정렬
    });
  }

  // 3. 카테고리 삭제
  Future<void> deleteCategory(String docId) async {
    if (currentHouseholdId == null) return;
    await _db.collection('households').doc(currentHouseholdId).collection(
        'categories').doc(docId).delete();
  }

  // lib/fridge_service.dart 내부의 함수 교체

  // 4. 초기 기본 카테고리 세팅 (스마트 업데이트 버전)
  // lib/fridge_service.dart 내부의 함수 교체
  // lib/fridge_service.dart

  // ★ [수정됨] N개를 버리는 함수 (쓰레기통 통합 로직 포함)
  // ★ [완벽 수정됨] N개를 버리는 함수 (단순 상태 변경으로 휴지통 이동)
  Future<void> discardItems(FridgeItem item, int count) async {
    if (currentHouseholdId == null) return;

    if (item.quantity <= count) {
      // 1. 선택한 개수가 남은 개수와 같거나 많으면 -> 아이템 전체를 휴지통으로 던집니다!
      await _db
          .collection('households')
          .doc(currentHouseholdId)
          .collection('items')
          .doc(item.id)
          .update({
        'status': 'trash', // ★ 핵심: 상태를 'trash'로 변경하여 냉장고에서 안 보이게 함
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // 2. 일부분만 버렸을 경우 -> 현재 수량은 빼고, 버린 만큼 새로 휴지통(trash)용 기록을 복사해서 남깁니다.
      await updateItemQuantity(item.id!, item.quantity - count);

      await _db
          .collection('households')
          .doc(currentHouseholdId)
          .collection('items')
          .add({
        'name': item.name,
        'category': item.category,
        'storageLocation': item.storageLocation,
        'quantity': count, // 버린 개수만큼만 기록
        'purchaseDate': Timestamp.fromDate(item.purchaseDate),
        'expiryDate': Timestamp.fromDate(item.expiryDate),
        'status': 'trash', // ★ 새로 만들어진 조각을 휴지통으로 보냄
        'isFavorite': false, // 휴지통에 있는 건 즐겨찾기 해제
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ★ [신규] N개를 먹는 함수
  Future<void> consumeItems(FridgeItem item, int count) async {
    if (currentHouseholdId == null) return;

    if (item.quantity <= count) {
      // 다 먹었을 때
      if (item.isFavorite) {
        // 경우 A: 즐겨찾기 아이템 -> 개수만 0으로 만듦 (삭제 X)
        await updateItemQuantity(item.id!, 0);
      } else {
        // 경우 B: 일반 아이템 -> 상태를 'consumed'로 변경 (목록에서 사라짐)
        await updateItemStatus(item.id!, 'consumed');
      }
    } else {
      // 일부만 먹었을 때 -> 수량 차감
      await updateItemQuantity(item.id!, item.quantity - count);
    }
  }

  // ★ [신규] 즐겨찾기 상태 토글 (켜기/끄기)
  Future<void> toggleItemFavorite(String itemId, bool currentStatus) async {
    if (currentHouseholdId == null) return;
    await _db
        .collection('households')
        .doc(currentHouseholdId)
        .collection('items')
        .doc(itemId)
        .update({'isFavorite': !currentStatus});
  }

  // ★ [신규] 즐겨찾기 화면에서 바로 재고 채우기
  Future<void> restockFromFavorite(String name, String category, int qty, DateTime expiry) async {
    if (currentHouseholdId == null) return;

    // 1. 이미 홈 화면에 있는 아이템인지 확인 (이름, 카테고리, 상태가 normal인 것)
    final query = await _db
        .collection('households')
        .doc(currentHouseholdId)
        .collection('items')
        .where('name', isEqualTo: name)
        .where('category', isEqualTo: category)
        .where('status', isEqualTo: 'normal')
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      // 2-A. 이미 있다 -> 그 아이템의 수량 늘리고 유통기한 업데이트
      var doc = query.docs.first;
      int currentQty = doc['quantity'];
      await doc.reference.update({
        'quantity': currentQty + qty,
        'expiryDate': Timestamp.fromDate(expiry),
        'isFavorite': true, // 즐겨찾기에서 채웠으니 자동으로 고정
      });
    } else {
      // 2-B. 없다 -> 새로 생성 (isFavorite: true)
      await _db.collection('households').doc(currentHouseholdId).collection('items').add({
        'name': name,
        'category': category,
        'storageLocation': '냉장', // 기본값
        'quantity': qty,
        'purchaseDate': Timestamp.now(),
        'expiryDate': Timestamp.fromDate(expiry),
        'status': 'normal',
        'isFavorite': true, // 즐겨찾기 고정
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
  Future<void> syncFamilyNotifications() async {
    if (currentHouseholdId == null) return;

    print("📡 가족 데이터와 알림 동기화 중...");

    // 1. DB에서 'normal' 상태인 아이템만 모두 가져오기
    final snapshot = await _db
        .collection('households')
        .doc(currentHouseholdId)
        .collection('items')
        .where('status', isEqualTo: 'normal')
        .get();

    // 2. FridgeItem 객체 리스트로 변환
    List<FridgeItem> items = snapshot.docs
        .map((doc) => FridgeItem.fromSnapshot(doc))
        .toList();

    // 3. 알림 서비스에 전달해서 내 폰에 예약 걸기 (import 필요)
    // (상단에 import 'notification_service.dart'; 가 없으면 추가해주세요)
    await NotificationService().syncNotifications(items);
  }
  Future<void> removeFavorite(String docId, String itemName) async {
    if (currentHouseholdId == null) return;

    // 1. 즐겨찾기 목록(템플릿)에서 삭제
    await _db
        .collection('households')
        .doc(currentHouseholdId)
        .collection('favorites')
        .doc(docId)
        .delete();

    // 2. [신규] 현재 냉장고에 있는 같은 이름의 아이템들도 '즐겨찾기 해제' 처리
    final itemSnapshot = await _db
        .collection('households')
        .doc(currentHouseholdId)
        .collection('items')
        .where('name', isEqualTo: itemName) // 이름이 같은 것 찾기
        .get();

    for (var doc in itemSnapshot.docs) {
      // 별표 끄기 (isFavorite: false)
      await doc.reference.update({'isFavorite': false});
    }

    print("🗑️ 즐겨찾기 삭제 및 동기화 완료: $itemName");
  }
  Future<void> deleteMultipleItems(List<String> docIds) async {
    if (currentHouseholdId == null) return;

    // Batch: 여러 작업을 한 번의 요청으로 처리 (성능 최적화)
    WriteBatch batch = _db.batch();

    for (String id in docIds) {
      DocumentReference ref = _db
          .collection('households')
          .doc(currentHouseholdId)
          .collection('items')
          .doc(id);
      batch.delete(ref);
    }

    await batch.commit();
    print("🗑️ ${docIds.length}개 아이템 영구 삭제 완료");
  }

  // ★ [신규] 여러 아이템 일괄 복구 (Trash -> Normal)
  Future<void> restoreMultipleItems(List<String> docIds) async {
    if (currentHouseholdId == null) return;

    WriteBatch batch = _db.batch();

    for (String id in docIds) {
      DocumentReference ref = _db
          .collection('households')
          .doc(currentHouseholdId)
          .collection('items')
          .doc(id);
      batch.update(ref, {'status': 'normal'});
    }

    await batch.commit();
    print("♻️ ${docIds.length}개 아이템 복구 완료");
  }

  // 아이템의 속성(이름, 장소, 카테고리) 일괄 수정
  // 아이템의 속성(이름, 장소, 카테고리) 일괄 수정 및 자동 병합
  Future<void> updateItemProperties(String itemId, {
    required String newName,
    required String newLocation,
    required String newCategory,
  }) async {
    try {
      if (currentHouseholdId == null) return;

      // 1. 이사 갈 곳(새 속성)에 똑같은 아이템이 이미 존재하는지 DB에서 검색합니다.
      final query = await _db
          .collection('households')
          .doc(currentHouseholdId)
          .collection('items')
          .where('name', isEqualTo: newName.trim()) // 혹시 모를 공백 제거
          .where('category', isEqualTo: newCategory)
          .where('storageLocation', isEqualTo: newLocation)
          .where('status', isEqualTo: 'normal')
          .get();

      bool? targetFavoriteStatus;

      // 2. 검색된 아이템 중 '나 자신'을 제외한 진짜 기존 거주자(?)가 있다면 상태를 확인합니다.
      for (var doc in query.docs) {
        if (doc.id != itemId) {
          targetFavoriteStatus = doc['isFavorite'] as bool?;
          break; // 하나라도 찾으면 그 녀석의 즐겨찾기 상태를 복사합니다.
        }
      }

      // 3. 기본적으로 업데이트할 정보 꾸러미
      Map<String, dynamic> updateData = {
        'name': newName.trim(),
        'storageLocation': newLocation,
        'category': newCategory,
      };

      // ★ [핵심 병합 로직] 목적지에 기존 아이템이 있다면, 즐겨찾기 상태를 똑같이 강제 적용합니다!
      if (targetFavoriteStatus != null) {
        updateData['isFavorite'] = targetFavoriteStatus;
      }

      // 4. DB에 최종 업데이트 진행
      await _db
          .collection('households')
          .doc(currentHouseholdId)
          .collection('items')
          .doc(itemId)
          .update(updateData);

      print("✅ [정보 수정 완료] $newName 업데이트 성공 (자동 병합 적용)!");

    } catch (e) {
      print("🚨 [정보 수정 실패] 에러 원인: $e");
    }
  }
  // ★ [완벽 수정됨] 휴지통(TrashScreen)에서 버린 내역 불러오기
  Stream<QuerySnapshot> getTrashedItemsStream() {
    if (currentHouseholdId == null) {
      return Stream.empty();
    }
    return _db
        .collection('households')
        .doc(currentHouseholdId)
        .collection('items')
        .where('status', isEqualTo: 'trash') // ★ 여기서 'discarded'가 아닌 'trash'를 찾아야 합니다!
    // .orderBy('updatedAt', descending: true) // (선택) 최신순 정렬 주석 해제 시 Firestore 인덱스 설정이 필요할 수 있습니다.
        .snapshots();
  }
}