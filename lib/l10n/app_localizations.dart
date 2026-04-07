import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('ko')
  ];

  /// No description provided for @daysExpired.
  ///
  /// In ko, this message translates to:
  /// **'기한지남'**
  String daysExpired(int days);

  /// No description provided for @today.
  ///
  /// In ko, this message translates to:
  /// **'오늘까지'**
  String get today;

  /// No description provided for @daysLeft.
  ///
  /// In ko, this message translates to:
  /// **'{days}일'**
  String daysLeft(int days);

  /// No description provided for @storageFridge.
  ///
  /// In ko, this message translates to:
  /// **'냉장'**
  String get storageFridge;

  /// No description provided for @storageFreezer.
  ///
  /// In ko, this message translates to:
  /// **'냉동'**
  String get storageFreezer;

  /// No description provided for @storagePantry.
  ///
  /// In ko, this message translates to:
  /// **'펜트리'**
  String get storagePantry;

  /// No description provided for @ateOne.
  ///
  /// In ko, this message translates to:
  /// **'1개를 먹었습니다'**
  String get ateOne;

  /// No description provided for @discardedOne.
  ///
  /// In ko, this message translates to:
  /// **' 1개를 버렸습니다'**
  String get discardedOne;

  /// No description provided for @undoDiscardFromHistory.
  ///
  /// In ko, this message translates to:
  /// **'버림 취소는 버린내역에서 복구해주세요'**
  String get undoDiscardFromHistory;

  /// No description provided for @undo.
  ///
  /// In ko, this message translates to:
  /// **'실행취소'**
  String get undo;

  /// No description provided for @toggleFavorite.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기 설정/해제'**
  String get toggleFavorite;

  /// No description provided for @selectQuantityAndDate.
  ///
  /// In ko, this message translates to:
  /// **'수량과 날짜를 선택해주세요'**
  String get selectQuantityAndDate;

  /// No description provided for @days.
  ///
  /// In ko, this message translates to:
  /// **'일수'**
  String get days;

  /// No description provided for @day.
  ///
  /// In ko, this message translates to:
  /// **'일'**
  String get day;

  /// No description provided for @editCurrentItemDateOnly.
  ///
  /// In ko, this message translates to:
  /// **'현재 아이템 날짜만 수정'**
  String get editCurrentItemDateOnly;

  /// No description provided for @expiryUpdated.
  ///
  /// In ko, this message translates to:
  /// **'유통기한 수정 완료!'**
  String get expiryUpdated;

  /// No description provided for @addAsNewExpiryItem.
  ///
  /// In ko, this message translates to:
  /// **'새 유통기한 항목으로 추가'**
  String get addAsNewExpiryItem;

  /// No description provided for @addedAsNewExpiryItem.
  ///
  /// In ko, this message translates to:
  /// **'{count}개가 새 유통기한으로 추가되었습니다.'**
  String addedAsNewExpiryItem(Object count);

  /// No description provided for @add.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get add;

  /// No description provided for @addedItems.
  ///
  /// In ko, this message translates to:
  /// **'{itemname} {count}개를 추가했습니다.'**
  String addedItems(String itemname, int count);

  /// No description provided for @discard.
  ///
  /// In ko, this message translates to:
  /// **'버림'**
  String get discard;

  /// No description provided for @discardedItems.
  ///
  /// In ko, this message translates to:
  /// **'{itemname} {count}개를 버렸습니다.'**
  String discardedItems(String itemname, int count);

  /// No description provided for @eat.
  ///
  /// In ko, this message translates to:
  /// **'먹음'**
  String get eat;

  /// No description provided for @ateItems.
  ///
  /// In ko, this message translates to:
  /// **'{itemname} {count}개를 먹었습니다.'**
  String ateItems(String itemname, int count);

  /// No description provided for @fill.
  ///
  /// In ko, this message translates to:
  /// **'채우기'**
  String get fill;

  /// No description provided for @howMuchToFill.
  ///
  /// In ko, this message translates to:
  /// **'얼마나 채울까요?'**
  String get howMuchToFill;

  /// No description provided for @expirationDate.
  ///
  /// In ko, this message translates to:
  /// **'유통기한: '**
  String get expirationDate;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @putInFridge.
  ///
  /// In ko, this message translates to:
  /// **'냉장고에 넣기'**
  String get putInFridge;

  /// No description provided for @filledItems.
  ///
  /// In ko, this message translates to:
  /// **'{itemname} {count}개 채워졌습니다'**
  String filledItems(String itemname, int count);

  /// No description provided for @needToBuy.
  ///
  /// In ko, this message translates to:
  /// **'구매필요: {count}개'**
  String needToBuy(Object count);

  /// No description provided for @myFridge.
  ///
  /// In ko, this message translates to:
  /// **'우리집 냉장고'**
  String get myFridge;

  /// No description provided for @manageFrequentItems.
  ///
  /// In ko, this message translates to:
  /// **'자주 쓰는 항목 관리'**
  String get manageFrequentItems;

  /// No description provided for @discardHistory.
  ///
  /// In ko, this message translates to:
  /// **'버린내역'**
  String get discardHistory;

  /// No description provided for @manageCategories.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 관리'**
  String get manageCategories;

  /// No description provided for @checkInviteCode.
  ///
  /// In ko, this message translates to:
  /// **'초대 코드 확인'**
  String get checkInviteCode;

  /// No description provided for @renameFridge.
  ///
  /// In ko, this message translates to:
  /// **'냉장고 이름 변경'**
  String get renameFridge;

  /// No description provided for @all.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get all;

  /// No description provided for @errorOccurred.
  ///
  /// In ko, this message translates to:
  /// **'에러 발생'**
  String get errorOccurred;

  /// No description provided for @enterItemName.
  ///
  /// In ko, this message translates to:
  /// **'재료 이름을 입력해주세요!'**
  String get enterItemName;

  /// No description provided for @selectCategory.
  ///
  /// In ko, this message translates to:
  /// **'카테고리를 선택해주세요!'**
  String get selectCategory;

  /// No description provided for @familyInviteCode.
  ///
  /// In ko, this message translates to:
  /// **'가족 초대 코드'**
  String get familyInviteCode;

  /// No description provided for @added.
  ///
  /// In ko, this message translates to:
  /// **'추가됨'**
  String get added;

  /// No description provided for @alreadySaved.
  ///
  /// In ko, this message translates to:
  /// **'이미 저장되었습니다'**
  String get alreadySaved;

  /// No description provided for @undoWithSpace.
  ///
  /// In ko, this message translates to:
  /// **'실행 취소'**
  String get undoWithSpace;

  /// No description provided for @fillFridgePlus.
  ///
  /// In ko, this message translates to:
  /// **'냉장고 채우기'**
  String get fillFridgePlus;

  /// No description provided for @itemName.
  ///
  /// In ko, this message translates to:
  /// **'아이템 이름'**
  String get itemName;

  /// No description provided for @itemNameExample.
  ///
  /// In ko, this message translates to:
  /// **'예: 사과, 두부'**
  String get itemNameExample;

  /// No description provided for @error.
  ///
  /// In ko, this message translates to:
  /// **'에러'**
  String get error;

  /// No description provided for @noCategories.
  ///
  /// In ko, this message translates to:
  /// **'카테고리가 없습니다.'**
  String get noCategories;

  /// No description provided for @category.
  ///
  /// In ko, this message translates to:
  /// **'카테고리'**
  String get category;

  /// No description provided for @chooseCategory.
  ///
  /// In ko, this message translates to:
  /// **'카테고리를 선택하세요'**
  String get chooseCategory;

  /// No description provided for @storageLocation.
  ///
  /// In ko, this message translates to:
  /// **'보관위치'**
  String get storageLocation;

  /// No description provided for @storageLocationOptions.
  ///
  /// In ko, this message translates to:
  /// **'냉장, 냉동, 펜트리'**
  String get storageLocationOptions;

  /// No description provided for @quantity.
  ///
  /// In ko, this message translates to:
  /// **'수량'**
  String get quantity;

  /// No description provided for @expiryAutoCalculated.
  ///
  /// In ko, this message translates to:
  /// **'유통기한 (자동 계산됨)'**
  String get expiryAutoCalculated;

  /// No description provided for @addToFavorites.
  ///
  /// In ko, this message translates to:
  /// **'이 항목을 즐겨찾기에 추가'**
  String get addToFavorites;

  /// No description provided for @defaultExpiryDays.
  ///
  /// In ko, this message translates to:
  /// **'기본 유통기한 (일)'**
  String get defaultExpiryDays;

  /// No description provided for @addNewCategory.
  ///
  /// In ko, this message translates to:
  /// **'새 카테고리 추가'**
  String get addNewCategory;

  /// No description provided for @nameExampleSnack.
  ///
  /// In ko, this message translates to:
  /// **'이름 (예: 간식)'**
  String get nameExampleSnack;

  /// No description provided for @categoryAdded.
  ///
  /// In ko, this message translates to:
  /// **'카테고리를 추가했습니다.'**
  String get categoryAdded;

  /// No description provided for @editCategory.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 수정'**
  String get editCategory;

  /// No description provided for @name.
  ///
  /// In ko, this message translates to:
  /// **'이름'**
  String get name;

  /// No description provided for @editComplete.
  ///
  /// In ko, this message translates to:
  /// **'수정 완료'**
  String get editComplete;

  /// No description provided for @updated.
  ///
  /// In ko, this message translates to:
  /// **'수정되었습니다.'**
  String get updated;

  /// No description provided for @fillDefaultCategories.
  ///
  /// In ko, this message translates to:
  /// **'기본 카테고리 채우기'**
  String get fillDefaultCategories;

  /// No description provided for @refresh.
  ///
  /// In ko, this message translates to:
  /// **'새로고침!'**
  String get refresh;

  /// No description provided for @addDefaultCategoriesHint.
  ///
  /// In ko, this message translates to:
  /// **'상단 버튼을 눌러 기본 카테고리를 추가해보세요!'**
  String get addDefaultCategoriesHint;

  /// No description provided for @defaultExpiryShort.
  ///
  /// In ko, this message translates to:
  /// **'기본 유통기한 {days}일'**
  String defaultExpiryShort(Object days);

  /// No description provided for @categoryDeleted.
  ///
  /// In ko, this message translates to:
  /// **'카테고리를 삭제했습니다.'**
  String get categoryDeleted;

  /// 이름을 포함한 카테고리 삭제 메시지
  ///
  /// In ko, this message translates to:
  /// **'\'{categoryName}\' 카테고리를 삭제했습니다.'**
  String categoryDeletedWithName(String categoryName);

  /// No description provided for @favorites.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기'**
  String get favorites;

  /// No description provided for @noFavoriteItems.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾는 재료가 없습니다.'**
  String get noFavoriteItems;

  /// No description provided for @checkStarWhenAdding.
  ///
  /// In ko, this message translates to:
  /// **'아이템 추가 시 별을 체크해보세요!'**
  String get checkStarWhenAdding;

  /// No description provided for @deleteFavorite.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기 삭제'**
  String get deleteFavorite;

  /// 목록에서 삭제
  ///
  /// In ko, this message translates to:
  /// **'{item}을(를) 자주 쓰는 목록에서 지우시겠습니까? (냉장고에 있는 아이템의 별표도 해제됩니다)'**
  String deleteFavoriteConfirm(String item);

  /// No description provided for @delete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get delete;

  /// No description provided for @deleted.
  ///
  /// In ko, this message translates to:
  /// **'삭제되었습니다.'**
  String get deleted;

  /// No description provided for @touchFridgeToOpen.
  ///
  /// In ko, this message translates to:
  /// **'냉장고를 터치해서 열어보세요'**
  String get touchFridgeToOpen;

  /// No description provided for @expiringSoon.
  ///
  /// In ko, this message translates to:
  /// **'유통기한 임박!'**
  String get expiringSoon;

  /// No description provided for @exitOptions.
  ///
  /// In ko, this message translates to:
  /// **'나가기 옵션'**
  String get exitOptions;

  /// No description provided for @loginFailed.
  ///
  /// In ko, this message translates to:
  /// **'로그인에 실패했습니다'**
  String get loginFailed;

  /// No description provided for @errorMessage.
  ///
  /// In ko, this message translates to:
  /// **'오류가 발생했습니다.'**
  String get errorMessage;

  /// No description provided for @enterCode.
  ///
  /// In ko, this message translates to:
  /// **'코드를 입력해주세요'**
  String get enterCode;

  /// No description provided for @invalidCode.
  ///
  /// In ko, this message translates to:
  /// **'올바르지 않은 코드입니다.'**
  String get invalidCode;

  /// No description provided for @fridgeAdmin.
  ///
  /// In ko, this message translates to:
  /// **'우리집 냉장고 관리자'**
  String get fridgeAdmin;

  /// No description provided for @createNewFridge.
  ///
  /// In ko, this message translates to:
  /// **'새 냉장고 만들기'**
  String get createNewFridge;

  /// No description provided for @or.
  ///
  /// In ko, this message translates to:
  /// **'또는'**
  String get or;

  /// No description provided for @enterWithInviteCode.
  ///
  /// In ko, this message translates to:
  /// **'초대 코드로 냉장고 열기'**
  String get enterWithInviteCode;

  /// No description provided for @inviteCode6Digits.
  ///
  /// In ko, this message translates to:
  /// **'초대 코드 6자리'**
  String get inviteCode6Digits;

  /// No description provided for @inviteCodeExample.
  ///
  /// In ko, this message translates to:
  /// **'예: abcdef'**
  String get inviteCodeExample;

  /// No description provided for @settingsAndExit.
  ///
  /// In ko, this message translates to:
  /// **'설정 및 나가기'**
  String get settingsAndExit;

  /// No description provided for @logout.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get logout;

  /// No description provided for @returnToHome.
  ///
  /// In ko, this message translates to:
  /// **'초기화면으로 돌아갑니다'**
  String get returnToHome;

  /// No description provided for @deleteFridge.
  ///
  /// In ko, this message translates to:
  /// **'냉장고 삭제하기'**
  String get deleteFridge;

  /// No description provided for @allDataDeletedPermanently.
  ///
  /// In ko, this message translates to:
  /// **'모든 데이터가 영구적으로 삭제됩니다.'**
  String get allDataDeletedPermanently;

  /// No description provided for @confirmDelete.
  ///
  /// In ko, this message translates to:
  /// **'정말 삭제하시겠습니까?'**
  String get confirmDelete;

  /// No description provided for @deleteFridgeWarning.
  ///
  /// In ko, this message translates to:
  /// **'냉장고 정보가 모두 사라지며 복구할 수 없습니다.'**
  String get deleteFridgeWarning;

  /// No description provided for @deleteAndExit.
  ///
  /// In ko, this message translates to:
  /// **'삭제 및 나가기'**
  String get deleteAndExit;

  /// No description provided for @fridgeDeleted.
  ///
  /// In ko, this message translates to:
  /// **'냉장고가 삭제되었습니다.'**
  String get fridgeDeleted;

  /// No description provided for @languageSettings.
  ///
  /// In ko, this message translates to:
  /// **'언어 설정'**
  String get languageSettings;

  /// No description provided for @enterNewName.
  ///
  /// In ko, this message translates to:
  /// **'새로운 이름을 입력하세요'**
  String get enterNewName;

  /// No description provided for @change.
  ///
  /// In ko, this message translates to:
  /// **'변경'**
  String get change;

  /// No description provided for @editItemInfo.
  ///
  /// In ko, this message translates to:
  /// **'아이템 정보 수정'**
  String get editItemInfo;

  /// No description provided for @successInfoEdit.
  ///
  /// In ko, this message translates to:
  /// **'정보가 성공적으로 수정되었습니다'**
  String get successInfoEdit;

  /// No description provided for @save.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get save;

  /// No description provided for @left.
  ///
  /// In ko, this message translates to:
  /// **'{itemname} {count}개 남음'**
  String left(String itemname, int count);

  /// No description provided for @total.
  ///
  /// In ko, this message translates to:
  /// **'전체 ({count}개)'**
  String total(int count);

  /// No description provided for @shareCode.
  ///
  /// In ko, this message translates to:
  /// **'이 코드를 가족과 공유하세요'**
  String get shareCode;

  /// No description provided for @close.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get close;

  /// No description provided for @itemfill.
  ///
  /// In ko, this message translates to:
  /// **'{itemname} 채우기'**
  String itemfill(String itemname);

  /// No description provided for @daycount.
  ///
  /// In ko, this message translates to:
  /// **'{count} days'**
  String daycount(int count);

  /// No description provided for @allEat.
  ///
  /// In ko, this message translates to:
  /// **'전체 먹음'**
  String get allEat;

  /// No description provided for @markAllAsEatenDescription.
  ///
  /// In ko, this message translates to:
  /// **'{quantity}개를 모두 먹은 것으로 처리합니다.'**
  String markAllAsEatenDescription(int quantity);

  /// No description provided for @markAllAsDiscardedDescription.
  ///
  /// In ko, this message translates to:
  /// **'{quantity}개를 모두 버린 것으로 처리합니다.'**
  String markAllAsDiscardedDescription(int quantity);

  /// No description provided for @markAllAsEaten.
  ///
  /// In ko, this message translates to:
  /// **'전체 먹음'**
  String get markAllAsEaten;

  /// No description provided for @markAllAsDiscarded.
  ///
  /// In ko, this message translates to:
  /// **'전체 버림'**
  String get markAllAsDiscarded;

  /// No description provided for @deleteCompletelyFromFridge.
  ///
  /// In ko, this message translates to:
  /// **'냉장고에서 완전 삭제'**
  String get deleteCompletelyFromFridge;

  /// No description provided for @processCompleted.
  ///
  /// In ko, this message translates to:
  /// **'처리가 완료되었습니다'**
  String get processCompleted;

  /// No description provided for @expiryUntil.
  ///
  /// In ko, this message translates to:
  /// **'{date} 까지'**
  String expiryUntil(String date);

  /// No description provided for @categoryWithEmoji.
  ///
  /// In ko, this message translates to:
  /// **'{emoji} {category}'**
  String categoryWithEmoji(String emoji, String category);

  /// No description provided for @emptyState.
  ///
  /// In ko, this message translates to:
  /// **'비어있어요!'**
  String get emptyState;

  /// No description provided for @expand.
  ///
  /// In ko, this message translates to:
  /// **'펼쳐보기'**
  String get expand;

  /// No description provided for @totalItemsSummary.
  ///
  /// In ko, this message translates to:
  /// **'총 {totalQty}개 (기한 {typeCount}종류)'**
  String totalItemsSummary(int totalQty, int typeCount);

  /// No description provided for @addedWithNewExpiry.
  ///
  /// In ko, this message translates to:
  /// **'{itemName} {count}개가 새 유통기한으로 추가되었습니다! 🎉'**
  String addedWithNewExpiry(String itemName, int count);

  /// No description provided for @itemWithQuantity.
  ///
  /// In ko, this message translates to:
  /// **'{itemName} ({quantity}개)'**
  String itemWithQuantity(String itemName, int quantity);

  /// No description provided for @quantities.
  ///
  /// In ko, this message translates to:
  /// **'{qty} 개'**
  String quantities(int qty);

  /// No description provided for @put.
  ///
  /// In ko, this message translates to:
  /// **'넣기'**
  String get put;

  /// No description provided for @permanentDelete.
  ///
  /// In ko, this message translates to:
  /// **'영구 삭제'**
  String get permanentDelete;

  /// No description provided for @confirmDeleteSelected.
  ///
  /// In ko, this message translates to:
  /// **'선택한 {count}개를 완전히 삭제하시겠습니까?\n이 작업은 복구할 수 없습니다.'**
  String confirmDeleteSelected(int count);

  /// No description provided for @emptyTrash.
  ///
  /// In ko, this message translates to:
  /// **'휴지통 비우기'**
  String get emptyTrash;

  /// No description provided for @confirmEmptyTrash.
  ///
  /// In ko, this message translates to:
  /// **'휴지통에 있는 모든 항목({count}개)을 영구 삭제하시겠습니까?'**
  String confirmEmptyTrash(int count);

  /// No description provided for @emptyAll.
  ///
  /// In ko, this message translates to:
  /// **'전체 비우기'**
  String get emptyAll;

  /// No description provided for @trashCleaned.
  ///
  /// In ko, this message translates to:
  /// **'휴지통을 깔끔하게 비웠습니다 ✨'**
  String get trashCleaned;

  /// No description provided for @selectedCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 선택됨'**
  String selectedCount(int count);

  /// No description provided for @trashTitle.
  ///
  /// In ko, this message translates to:
  /// **'휴지통'**
  String get trashTitle;

  /// No description provided for @restoreSelected.
  ///
  /// In ko, this message translates to:
  /// **'선택 항목 복구'**
  String get restoreSelected;

  /// No description provided for @deleteSelectedPermanently.
  ///
  /// In ko, this message translates to:
  /// **'선택 항목 영구 삭제'**
  String get deleteSelectedPermanently;

  /// No description provided for @trashEmpty.
  ///
  /// In ko, this message translates to:
  /// **'휴지통이 비어있습니다.'**
  String get trashEmpty;

  /// No description provided for @discardedItemInfo.
  ///
  /// In ko, this message translates to:
  /// **'버린 개수: {quantity}개  |  유통기한: {date}'**
  String discardedItemInfo(int quantity, String date);

  /// No description provided for @whatToDoWithItem.
  ///
  /// In ko, this message translates to:
  /// **'이 아이템을 어떻게 할까요?'**
  String get whatToDoWithItem;

  /// No description provided for @restore.
  ///
  /// In ko, this message translates to:
  /// **'복구'**
  String get restore;

  /// No description provided for @restoredToFridge.
  ///
  /// In ko, this message translates to:
  /// **'냉장고로 복구되었습니다 ♻️'**
  String get restoredToFridge;

  /// No description provided for @restoreCompleted.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 복구 완료! 냉장고를 확인하세요 ♻️'**
  String restoreCompleted(int count);

  /// No description provided for @permanentDeleteCompleted.
  ///
  /// In ko, this message translates to:
  /// **'{count}개가 영구 삭제되었습니다 🗑️'**
  String permanentDeleteCompleted(int count);

  /// No description provided for @permanentDeleted.
  ///
  /// In ko, this message translates to:
  /// **'영구 삭제되었습니다.'**
  String get permanentDeleted;

  /// No description provided for @countItems.
  ///
  /// In ko, this message translates to:
  /// **'{count}개'**
  String countItems(int count);

  /// No description provided for @categoryMeat.
  ///
  /// In ko, this message translates to:
  /// **'육류'**
  String get categoryMeat;

  /// No description provided for @categoryVegetable.
  ///
  /// In ko, this message translates to:
  /// **'채소'**
  String get categoryVegetable;

  /// No description provided for @categoryFruit.
  ///
  /// In ko, this message translates to:
  /// **'과일'**
  String get categoryFruit;

  /// No description provided for @categoryDairy.
  ///
  /// In ko, this message translates to:
  /// **'유제품'**
  String get categoryDairy;

  /// No description provided for @categorySeafood.
  ///
  /// In ko, this message translates to:
  /// **'해산물'**
  String get categorySeafood;

  /// No description provided for @categoryBeverage.
  ///
  /// In ko, this message translates to:
  /// **'음료'**
  String get categoryBeverage;

  /// No description provided for @categoryBakery.
  ///
  /// In ko, this message translates to:
  /// **'빵'**
  String get categoryBakery;

  /// No description provided for @categorySauce.
  ///
  /// In ko, this message translates to:
  /// **'조미료/소스'**
  String get categorySauce;

  /// No description provided for @categoryFrozen.
  ///
  /// In ko, this message translates to:
  /// **'냉동식품'**
  String get categoryFrozen;

  /// No description provided for @categoryCanned.
  ///
  /// In ko, this message translates to:
  /// **'통조림'**
  String get categoryCanned;

  /// No description provided for @categoryInstant.
  ///
  /// In ko, this message translates to:
  /// **'즉석/밀키트'**
  String get categoryInstant;

  /// No description provided for @categoryNoodle.
  ///
  /// In ko, this message translates to:
  /// **'면/파스타'**
  String get categoryNoodle;

  /// No description provided for @categoryEtc.
  ///
  /// In ko, this message translates to:
  /// **'기타'**
  String get categoryEtc;

  /// No description provided for @categoryFish.
  ///
  /// In ko, this message translates to:
  /// **'생선'**
  String get categoryFish;

  /// No description provided for @confirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get confirm;

  /// No description provided for @enterFridgeName.
  ///
  /// In ko, this message translates to:
  /// **'냉장고 이름을 입력해주세요'**
  String get enterFridgeName;

  /// No description provided for @copiedToClipboard.
  ///
  /// In ko, this message translates to:
  /// **'코드가 복사 되었습니다.'**
  String get copiedToClipboard;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
