// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String daysExpired(int days) {
    return '$days days expired';
  }

  @override
  String get today => 'today';

  @override
  String daysLeft(int days) {
    return '$days days left';
  }

  @override
  String get storageFridge => 'Fridge';

  @override
  String get storageFreezer => 'Freezer';

  @override
  String get storagePantry => 'Pantry';

  @override
  String get ateOne => 'Ate 1 item';

  @override
  String get discardedOne => 'Discarded 1 item';

  @override
  String get undoDiscardFromHistory =>
      'To undo a discard, restore it from discard history';

  @override
  String get undo => 'Undo';

  @override
  String get toggleFavorite => 'Set/Unset favorite';

  @override
  String get selectQuantityAndDate => 'Please select quantity and date';

  @override
  String get days => 'Days';

  @override
  String get day => 'day';

  @override
  String get editCurrentItemDateOnly => 'Change expiration date only';

  @override
  String get expiryUpdated => 'Expiration date updated!';

  @override
  String get addAsNewExpiryItem => 'Add expiring item';

  @override
  String addedAsNewExpiryItem(Object count) {
    return '$count items added with a new expiration date.';
  }

  @override
  String get add => 'Add';

  @override
  String addedItems(String itemname, int count) {
    return '$count items added.';
  }

  @override
  String get discard => 'Discard';

  @override
  String discardedItems(String itemname, int count) {
    return '$itemname $count items discarded.';
  }

  @override
  String get eat => 'Eat';

  @override
  String ateItems(String itemname, int count) {
    return '$itemname $count items eaten.';
  }

  @override
  String get fill => 'Fill';

  @override
  String get howMuchToFill => 'How many would you like to fill?';

  @override
  String get expirationDate => 'Expiration date: ';

  @override
  String get cancel => 'Cancel';

  @override
  String get putInFridge => 'Put in fridge';

  @override
  String filledItems(String itemname, int count) {
    return '$itemname $count items filled.';
  }

  @override
  String needToBuy(Object count) {
    return 'Need to buy: $count';
  }

  @override
  String get myFridge => 'My Fridge';

  @override
  String get manageFrequentItems => 'Manage frequently used items';

  @override
  String get discardHistory => 'Discard history';

  @override
  String get manageCategories => 'Manage categories';

  @override
  String get checkInviteCode => 'Check invite code';

  @override
  String get renameFridge => 'Rename fridge';

  @override
  String get all => 'All';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get enterItemName => 'Please enter an item name!';

  @override
  String get selectCategory => 'Please select a category!';

  @override
  String get familyInviteCode => 'Family invite code';

  @override
  String get added => 'Added';

  @override
  String get alreadySaved => 'Already saved';

  @override
  String get undoWithSpace => 'Undo';

  @override
  String get fillFridgePlus => 'Fill fridge +';

  @override
  String get itemName => 'Item name';

  @override
  String get itemNameExample => 'e.g. apple, tofu';

  @override
  String get error => 'Error';

  @override
  String get noCategories => 'There are no categories.';

  @override
  String get category => 'Category';

  @override
  String get chooseCategory => 'Choose a category';

  @override
  String get storageLocation => 'Storage location';

  @override
  String get storageLocationOptions => 'Fridge, Freezer, Pantry';

  @override
  String get quantity => 'Quantity';

  @override
  String get expiryAutoCalculated =>
      'Expiration date (calculated automatically)';

  @override
  String get addToFavorites => 'Add this item to favorites';

  @override
  String get defaultExpiryDays => 'Default expiration period (days)';

  @override
  String get addNewCategory => 'Add new category';

  @override
  String get nameExampleSnack => 'Name (e.g. Snack)';

  @override
  String get categoryAdded => 'Category added.';

  @override
  String get editCategory => 'Edit category';

  @override
  String get name => 'Name';

  @override
  String get editComplete => 'Edit complete';

  @override
  String get updated => 'Updated.';

  @override
  String get fillDefaultCategories => 'Add default categories';

  @override
  String get refresh => 'Refresh!';

  @override
  String get addDefaultCategoriesHint =>
      'Press the top button to add default categories!';

  @override
  String defaultExpiryShort(Object days) {
    return 'Default expiration: $days days';
  }

  @override
  String get categoryDeleted => 'Category deleted.';

  @override
  String get favorites => 'Favorites';

  @override
  String get noFavoriteItems => 'There are no favorite items.';

  @override
  String get checkStarWhenAdding =>
      'Try checking the star when adding an item!';

  @override
  String get deleteFavorite => 'Delete favorite';

  @override
  String deleteFavoriteConfirm(Object item) {
    return 'Do you want to remove $item from the frequently used list? (The star on items in the fridge will also be removed.)';
  }

  @override
  String get delete => 'Delete';

  @override
  String get deleted => 'Deleted.';

  @override
  String get touchFridgeToOpen => 'Touch the fridge to open it';

  @override
  String get expiringSoon => 'Expiring soon!';

  @override
  String get exitOptions => 'Exit options';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get errorMessage => 'An error has occurred.';

  @override
  String get enterCode => 'Please enter the code';

  @override
  String get invalidCode => 'Invalid code.';

  @override
  String get fridgeAdmin => 'My Fridge Admin';

  @override
  String get createNewFridge => 'Create new fridge';

  @override
  String get or => 'or';

  @override
  String get enterWithInviteCode => 'Enter with invite code';

  @override
  String get inviteCode6Digits => '6-digit invite code';

  @override
  String get inviteCodeExample => 'e.g. abcdef';

  @override
  String get settingsAndExit => 'Settings and Exit';

  @override
  String get logout => 'Log out';

  @override
  String get returnToHome => 'You will return to the home screen';

  @override
  String get deleteFridge => 'Delete fridge';

  @override
  String get allDataDeletedPermanently =>
      'All data will be permanently deleted.';

  @override
  String get confirmDelete => 'Are you sure you want to delete it?';

  @override
  String get deleteFridgeWarning =>
      'All fridge information will be deleted and cannot be recovered.';

  @override
  String get deleteAndExit => 'Delete and Exit';

  @override
  String get fridgeDeleted => 'The fridge has been deleted.';

  @override
  String get languageSettings => 'Language Setting';

  @override
  String get enterNewName => 'Enter a new name';

  @override
  String get change => 'Change';

  @override
  String get editItemInfo => 'Edit item information';

  @override
  String get successInfoEdit => 'Information has been successfully updated';

  @override
  String get save => 'Save';

  @override
  String left(String itemname, int count) {
    return '$itemname $count left';
  }

  @override
  String total(int count) {
    return 'total ($count)';
  }

  @override
  String get shareCode => 'Share this code with your family';

  @override
  String get close => 'close';

  @override
  String itemfill(String itemname) {
    return '$itemname fill';
  }

  @override
  String daycount(int count) {
    return '$count days';
  }

  @override
  String get allEat => 'all eat';

  @override
  String markAllAsEatenDescription(int quantity) {
    return 'This will mark all $quantity items as eaten.';
  }

  @override
  String markAllAsDiscardedDescription(int quantity) {
    return 'This will mark all $quantity items as discarded.';
  }

  @override
  String get markAllAsEaten => 'Eat all';

  @override
  String get markAllAsDiscarded => 'Discard all';

  @override
  String get deleteCompletelyFromFridge => 'Delete completely from fridge';

  @override
  String get processCompleted => 'Processing completed';

  @override
  String expiryUntil(String date) {
    return 'Until $date';
  }

  @override
  String categoryWithEmoji(String emoji, String category) {
    return '$emoji $category';
  }

  @override
  String get emptyState => 'It\'s empty!';

  @override
  String get expand => 'Show more';

  @override
  String totalItemsSummary(int totalQty, int typeCount) {
    return '$totalQty items ($typeCount expiration)';
  }

  @override
  String addedWithNewExpiry(String itemName, int count) {
    return '$count $itemName items have been added with a new expiration date! 🎉';
  }

  @override
  String itemWithQuantity(String itemName, int quantity) {
    return '$itemName ($quantity)';
  }

  @override
  String quantities(int qty) {
    return '$qty items';
  }

  @override
  String get put => 'Add';

  @override
  String get permanentDelete => 'Delete permanently';

  @override
  String confirmDeleteSelected(int count) {
    return 'Do you want to permanently delete the selected $count items?\nThis action cannot be undone.';
  }

  @override
  String get emptyTrash => 'Empty trash';

  @override
  String confirmEmptyTrash(int count) {
    return 'Do you want to permanently delete all items in the trash ($count)?';
  }

  @override
  String get emptyAll => 'Empty all';

  @override
  String get trashCleaned => 'Trash has been cleaned up ✨';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get trashTitle => 'Trash 🗑️';

  @override
  String get restoreSelected => 'Restore selected';

  @override
  String get deleteSelectedPermanently => 'Delete selected permanently';

  @override
  String get trashEmpty => 'The trash is empty.';

  @override
  String discardedItemInfo(int quantity, String date) {
    return 'Discarded: $quantity  |  Expiration date: $date';
  }

  @override
  String get whatToDoWithItem => 'What would you like to do with this item?';

  @override
  String get restore => 'Restore';

  @override
  String get restoredToFridge => 'Restored to the fridge ♻️';

  @override
  String restoreCompleted(int count) {
    return '$count items restored! Check your fridge ♻️';
  }

  @override
  String permanentDeleteCompleted(int count) {
    return '$count items permanently deleted 🗑️';
  }

  @override
  String get permanentDeleted => 'Permanently deleted.';

  @override
  String countItems(int count) {
    return '$count items';
  }
}
