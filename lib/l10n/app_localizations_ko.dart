// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String daysExpired(int days) {
    return '$days일 지남';
  }

  @override
  String get today => '오늘까지';

  @override
  String daysLeft(int days) {
    return '$days일 남음';
  }

  @override
  String get storageFridge => '냉장';

  @override
  String get storageFreezer => '냉동';

  @override
  String get storagePantry => '펜트리';

  @override
  String get ateOne => '1개를 먹었습니다';

  @override
  String get discardedOne => ' 1개를 버렸습니다';

  @override
  String get undoDiscardFromHistory => '버림 취소는 버린내역에서 복구해주세요';

  @override
  String get undo => '실행취소';

  @override
  String get toggleFavorite => '즐겨찾기 설정/해제';

  @override
  String get selectQuantityAndDate => '수량과 날짜를 선택해주세요';

  @override
  String get days => '일수';

  @override
  String get day => '일';

  @override
  String get editCurrentItemDateOnly => '현재 아이템 날짜만 수정';

  @override
  String get expiryUpdated => '유통기한 수정 완료!';

  @override
  String get addAsNewExpiryItem => '새 유통기한 항목으로 추가';

  @override
  String addedAsNewExpiryItem(Object count) {
    return '$count개가 새 유통기한으로 추가되었습니다.';
  }

  @override
  String get add => '추가';

  @override
  String addedItems(String itemname, int count) {
    return '$itemname $count개를 추가했습니다.';
  }

  @override
  String get discard => '버림';

  @override
  String discardedItems(String itemname, int count) {
    return '$itemname $count개를 버렸습니다.';
  }

  @override
  String get eat => '먹음';

  @override
  String ateItems(String itemname, int count) {
    return '$itemname $count개를 먹었습니다.';
  }

  @override
  String get fill => '채우기';

  @override
  String get howMuchToFill => '얼마나 채울까요?';

  @override
  String get expirationDate => '유통기한: ';

  @override
  String get cancel => '취소';

  @override
  String get putInFridge => '냉장고에 넣기';

  @override
  String filledItems(String itemname, int count) {
    return '$itemname $count개 채워졌습니다';
  }

  @override
  String needToBuy(Object count) {
    return '구매필요: $count개';
  }

  @override
  String get myFridge => '우리집 냉장고';

  @override
  String get manageFrequentItems => '자주 쓰는 항목 관리';

  @override
  String get discardHistory => '버린내역';

  @override
  String get manageCategories => '카테고리 관리';

  @override
  String get checkInviteCode => '초대 코드 확인';

  @override
  String get renameFridge => '냉장고 이름 변경';

  @override
  String get all => '전체';

  @override
  String get errorOccurred => '에러 발생';

  @override
  String get enterItemName => '재료 이름을 입력해주세요!';

  @override
  String get selectCategory => '카테고리를 선택해주세요!';

  @override
  String get familyInviteCode => '가족 초대 코드';

  @override
  String get added => '추가됨';

  @override
  String get alreadySaved => '이미 저장되었습니다';

  @override
  String get undoWithSpace => '실행 취소';

  @override
  String get fillFridgePlus => '냉장고 채우기 +';

  @override
  String get itemName => '아이템 이름';

  @override
  String get itemNameExample => '예: 사과, 두부';

  @override
  String get error => '에러';

  @override
  String get noCategories => '카테고리가 없습니다.';

  @override
  String get category => '카테고리';

  @override
  String get chooseCategory => '카테고리를 선택하세요';

  @override
  String get storageLocation => '보관위치';

  @override
  String get storageLocationOptions => '냉장, 냉동, 펜트리';

  @override
  String get quantity => '수량';

  @override
  String get expiryAutoCalculated => '유통기한 (자동 계산됨)';

  @override
  String get addToFavorites => '이 항목을 즐겨찾기에 추가';

  @override
  String get defaultExpiryDays => '기본 유통기한 (일)';

  @override
  String get addNewCategory => '새 카테고리 추가';

  @override
  String get nameExampleSnack => '이름 (예: 간식)';

  @override
  String get categoryAdded => '카테고리를 추가했습니다.';

  @override
  String get editCategory => '카테고리 수정';

  @override
  String get name => '이름';

  @override
  String get editComplete => '수정 완료';

  @override
  String get updated => '수정되었습니다.';

  @override
  String get fillDefaultCategories => '기본 카테고리 채우기';

  @override
  String get refresh => '새로고침!';

  @override
  String get addDefaultCategoriesHint => '상단 버튼을 눌러 기본 카테고리를 추가해보세요!';

  @override
  String defaultExpiryShort(Object days) {
    return '기본 유통기한 $days일';
  }

  @override
  String get categoryDeleted => '카테고리를 삭제했습니다.';

  @override
  String get favorites => '즐겨찾기';

  @override
  String get noFavoriteItems => '즐겨찾는 재료가 없습니다.';

  @override
  String get checkStarWhenAdding => '아이템 추가 시 별을 체크해보세요!';

  @override
  String get deleteFavorite => '즐겨찾기 삭제';

  @override
  String deleteFavoriteConfirm(Object item) {
    return '$item을(를) 자주 쓰는 목록에서 지우시겠습니까? (냉장고에 있는 아이템의 별표도 해제됩니다)';
  }

  @override
  String get delete => '삭제';

  @override
  String get deleted => '삭제되었습니다.';

  @override
  String get touchFridgeToOpen => '냉장고를 터치해서 열어보세요';

  @override
  String get expiringSoon => '유통기한 임박!';

  @override
  String get exitOptions => '나가기 옵션';

  @override
  String get loginFailed => '로그인에 실패했습니다';

  @override
  String get errorMessage => '오류가 발생했습니다.';

  @override
  String get enterCode => '코드를 입력해주세요';

  @override
  String get invalidCode => '올바르지 않은 코드입니다.';

  @override
  String get fridgeAdmin => '우리집 냉장고 관리자';

  @override
  String get createNewFridge => '새 냉장고 만들기';

  @override
  String get or => '또는';

  @override
  String get enterWithInviteCode => '초대 코드로 냉장고 열기';

  @override
  String get inviteCode6Digits => '초대 코드 6자리';

  @override
  String get inviteCodeExample => '예: abcdef';

  @override
  String get settingsAndExit => '설정 및 나가기';

  @override
  String get logout => '로그아웃';

  @override
  String get returnToHome => '초기화면으로 돌아갑니다';

  @override
  String get deleteFridge => '냉장고 삭제하기';

  @override
  String get allDataDeletedPermanently => '모든 데이터가 영구적으로 삭제됩니다.';

  @override
  String get confirmDelete => '정말 삭제하시겠습니까?';

  @override
  String get deleteFridgeWarning => '냉장고 정보가 모두 사라지며 복구할 수 없습니다.';

  @override
  String get deleteAndExit => '삭제 및 나가기';

  @override
  String get fridgeDeleted => '냉장고가 삭제되었습니다.';

  @override
  String get languageSettings => '언어 설정';

  @override
  String get enterNewName => '새로운 이름을 입력하세요';

  @override
  String get change => '변경';

  @override
  String get editItemInfo => '아이템 정보 수정';

  @override
  String get successInfoEdit => '정보가 성공적으로 수정되었습니다';

  @override
  String get save => '저장';

  @override
  String left(String itemname, int count) {
    return '$itemname $count개 남음';
  }

  @override
  String total(int count) {
    return '전체 ($count개)';
  }

  @override
  String get shareCode => '이 코드를 가족과 공유하세요';

  @override
  String get close => '닫기';

  @override
  String itemfill(String itemname) {
    return '$itemname 채우기';
  }

  @override
  String daycount(int count) {
    return '$count days';
  }

  @override
  String get allEat => '전체 먹음';

  @override
  String markAllAsEatenDescription(int quantity) {
    return '$quantity개를 모두 먹은 것으로 처리합니다.';
  }

  @override
  String markAllAsDiscardedDescription(int quantity) {
    return '$quantity개를 모두 버린 것으로 처리합니다.';
  }

  @override
  String get markAllAsEaten => '전체 먹음';

  @override
  String get markAllAsDiscarded => '전체 버림';

  @override
  String get deleteCompletelyFromFridge => '냉장고에서 완전 삭제';

  @override
  String get processCompleted => '처리가 완료되었습니다';

  @override
  String expiryUntil(String date) {
    return '$date 까지';
  }

  @override
  String categoryWithEmoji(String emoji, String category) {
    return '$emoji $category';
  }

  @override
  String get emptyState => '비어있어요!';

  @override
  String get expand => '펼쳐보기';

  @override
  String totalItemsSummary(int totalQty, int typeCount) {
    return '총 $totalQty개 (기한 $typeCount종류)';
  }

  @override
  String addedWithNewExpiry(String itemName, int count) {
    return '$itemName $count개가 새 유통기한으로 추가되었습니다! 🎉';
  }

  @override
  String itemWithQuantity(String itemName, int quantity) {
    return '$itemName ($quantity개)';
  }

  @override
  String quantities(int qty) {
    return '$qty 개';
  }

  @override
  String get put => '넣기';

  @override
  String get permanentDelete => '영구 삭제';

  @override
  String confirmDeleteSelected(int count) {
    return '선택한 $count개를 완전히 삭제하시겠습니까?\n이 작업은 복구할 수 없습니다.';
  }

  @override
  String get emptyTrash => '휴지통 비우기';

  @override
  String confirmEmptyTrash(int count) {
    return '휴지통에 있는 모든 항목($count개)을 영구 삭제하시겠습니까?';
  }

  @override
  String get emptyAll => '전체 비우기';

  @override
  String get trashCleaned => '휴지통을 깔끔하게 비웠습니다 ✨';

  @override
  String selectedCount(int count) {
    return '$count개 선택됨';
  }

  @override
  String get trashTitle => '휴지통 🗑️';

  @override
  String get restoreSelected => '선택 항목 복구';

  @override
  String get deleteSelectedPermanently => '선택 항목 영구 삭제';

  @override
  String get trashEmpty => '휴지통이 비어있습니다.';

  @override
  String discardedItemInfo(int quantity, String date) {
    return '버린 개수: $quantity개  |  유통기한: $date';
  }

  @override
  String get whatToDoWithItem => '이 아이템을 어떻게 할까요?';

  @override
  String get restore => '복구';

  @override
  String get restoredToFridge => '냉장고로 복구되었습니다 ♻️';

  @override
  String restoreCompleted(int count) {
    return '$count개 복구 완료! 냉장고를 확인하세요 ♻️';
  }

  @override
  String permanentDeleteCompleted(int count) {
    return '$count개가 영구 삭제되었습니다 🗑️';
  }

  @override
  String get permanentDeleted => '영구 삭제되었습니다.';

  @override
  String countItems(int count) {
    return '$count개';
  }
}
