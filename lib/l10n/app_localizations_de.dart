// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String daysExpired(int days) {
    return '$days Tage abgelaufen';
  }

  @override
  String get today => 'Heute';

  @override
  String daysLeft(int days) {
    return '$days Tage übrig';
  }

  @override
  String get storageFridge => 'Kühlschrank';

  @override
  String get storageFreezer => 'Gefrierschrank';

  @override
  String get storagePantry => 'Vorratskammer';

  @override
  String get ateOne => '1 Artikel gegessen';

  @override
  String get discardedOne => '1 Artikel entsorgt';

  @override
  String get undoDiscardFromHistory =>
      'Um das Entsorgen rückgängig zu machen, stelle es im Entsorgungsverlauf wieder her';

  @override
  String get undo => 'Rückgängig';

  @override
  String get toggleFavorite => 'Favorit setzen/entfernen';

  @override
  String get selectQuantityAndDate => 'Bitte Menge und Datum auswählen';

  @override
  String get days => 'Tage';

  @override
  String get day => 'Tag';

  @override
  String get editCurrentItemDateOnly => 'Nur das Datum bearbeiten';

  @override
  String get expiryUpdated => 'Ablaufdatum aktualisiert!';

  @override
  String get addAsNewExpiryItem => 'Neuen Artikel hinzufügen';

  @override
  String addedAsNewExpiryItem(Object count) {
    return '$count Artikel mit neuem Ablaufdatum hinzugefügt.';
  }

  @override
  String get add => 'Hinzufügen';

  @override
  String addedItems(String itemname, int count) {
    return '$count Artikel hinzugefügt.';
  }

  @override
  String get discard => 'Entsorgen';

  @override
  String discardedItems(String itemname, int count) {
    return '$itemname $count Artikel entsorgt.';
  }

  @override
  String get eat => 'Gegessen';

  @override
  String ateItems(String itemname, int count) {
    return '$itemname $count Artikel gegessen.';
  }

  @override
  String get fill => 'Auffüllen';

  @override
  String get howMuchToFill => 'Wie viele möchten Sie auffüllen?';

  @override
  String get expirationDate => 'Ablaufdatum: ';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get putInFridge => 'In den Kühlschrank legen';

  @override
  String filledItems(String itemname, int count) {
    return '$itemname $count Artikel aufgefüllt.';
  }

  @override
  String needToBuy(Object count) {
    return 'Zu kaufen: $count';
  }

  @override
  String get myFridge => 'Mein Kühlschrank';

  @override
  String get manageFrequentItems => 'Häufig verwendete Artikel verwalten';

  @override
  String get discardHistory => 'Entsorgungsverlauf';

  @override
  String get manageCategories => 'Kategorien verwalten';

  @override
  String get checkInviteCode => 'Einladungscode prüfen';

  @override
  String get renameFridge => 'Kühlschrank umbenennen';

  @override
  String get all => 'Alle';

  @override
  String get errorOccurred => 'Ein Fehler ist aufgetreten';

  @override
  String get enterItemName => 'Bitte einen Artikelnamen eingeben!';

  @override
  String get selectCategory => 'Bitte eine Kategorie auswählen!';

  @override
  String get familyInviteCode => 'Familien-Einladungscode';

  @override
  String get added => 'Hinzugefügt';

  @override
  String get alreadySaved => 'Bereits gespeichert';

  @override
  String get undoWithSpace => 'Rückgängig';

  @override
  String get fillFridgePlus => 'Kühlschrank auffüllen +';

  @override
  String get itemName => 'Artikelname';

  @override
  String get itemNameExample => 'z. B. Apfel, Tofu';

  @override
  String get error => 'Fehler';

  @override
  String get noCategories => 'Es gibt keine Kategorien.';

  @override
  String get category => 'Kategorie';

  @override
  String get chooseCategory => 'Kategorie auswählen';

  @override
  String get storageLocation => 'Lagerort';

  @override
  String get storageLocationOptions =>
      'Kühlschrank, Gefrierschrank, Vorratskammer';

  @override
  String get quantity => 'Menge';

  @override
  String get expiryAutoCalculated => 'Ablaufdatum (automatisch berechnet)';

  @override
  String get addToFavorites => 'Diesen Artikel zu Favoriten hinzufügen';

  @override
  String get defaultExpiryDays => 'Standardhaltbarkeit (Tage)';

  @override
  String get addNewCategory => 'Neue Kategorie hinzufügen';

  @override
  String get nameExampleSnack => 'Name (z. B. Snack)';

  @override
  String get categoryAdded => 'Kategorie hinzugefügt.';

  @override
  String get editCategory => 'Kategorie bearbeiten';

  @override
  String get name => 'Name';

  @override
  String get editComplete => 'Bearbeitung abgeschlossen';

  @override
  String get updated => 'Aktualisiert.';

  @override
  String get fillDefaultCategories => 'Standardkategorien hinzufügen';

  @override
  String get refresh => 'Aktualisieren!';

  @override
  String get addDefaultCategoriesHint =>
      'Drücke den oberen Button, um Standardkategorien hinzuzufügen!';

  @override
  String defaultExpiryShort(Object days) {
    return 'Standardhaltbarkeit: $days Tage';
  }

  @override
  String get categoryDeleted => 'Kategorie gelöscht.';

  @override
  String categoryDeletedWithName(String categoryName) {
    return 'Kategorie \'$categoryName\' wurde gelöscht.';
  }

  @override
  String get favorites => 'Favoriten';

  @override
  String get noFavoriteItems => 'Es gibt keine Favoriten.';

  @override
  String get checkStarWhenAdding =>
      'Versuche beim Hinzufügen eines Artikels den Stern zu markieren!';

  @override
  String get deleteFavorite => 'Favorit löschen';

  @override
  String deleteFavoriteConfirm(Object item) {
    return 'Möchten Sie $item aus der Liste der häufig verwendeten Artikel entfernen? (Der Stern bei Artikeln im Kühlschrank wird ebenfalls entfernt.)';
  }

  @override
  String get delete => 'Löschen';

  @override
  String get deleted => 'Gelöscht.';

  @override
  String get touchFridgeToOpen => 'Tippe auf den Kühlschrank, um ihn zu öffnen';

  @override
  String get expiringSoon => 'Bald ablaufend!';

  @override
  String get exitOptions => 'Beenden-Optionen';

  @override
  String get loginFailed => 'Anmeldung fehlgeschlagen';

  @override
  String get errorMessage => 'Ein Fehler ist aufgetreten.';

  @override
  String get enterCode => 'Bitte Code eingeben';

  @override
  String get invalidCode => 'Ungültiger Code.';

  @override
  String get fridgeAdmin => 'Kühlschrank-Administrator';

  @override
  String get createNewFridge => 'Neuen Kühlschrank erstellen';

  @override
  String get or => 'oder';

  @override
  String get enterWithInviteCode => 'Mit Einladungscode beitreten';

  @override
  String get inviteCode6Digits => '6-stelliger Einladungscode';

  @override
  String get inviteCodeExample => 'z. B. abcdef';

  @override
  String get settingsAndExit => 'Einstellungen und Beenden';

  @override
  String get logout => 'Abmelden';

  @override
  String get returnToHome => 'Sie kehren zum Startbildschirm zurück';

  @override
  String get deleteFridge => 'Kühlschrank löschen';

  @override
  String get allDataDeletedPermanently =>
      'Alle Daten werden dauerhaft gelöscht.';

  @override
  String get confirmDelete => 'Möchten Sie wirklich löschen?';

  @override
  String get deleteFridgeWarning =>
      'Alle Kühlschrankdaten werden gelöscht und können nicht wiederhergestellt werden.';

  @override
  String get deleteAndExit => 'Löschen und Beenden';

  @override
  String get fridgeDeleted => 'Der Kühlschrank wurde gelöscht.';

  @override
  String get languageSettings => 'Spracheinstellungen';

  @override
  String get enterNewName => 'Gib einen neuen Namen ein';

  @override
  String get change => 'Ändern';

  @override
  String get editItemInfo => 'Artikelinformationen bearbeiten';

  @override
  String get successInfoEdit => 'Informationen wurden erfolgreich aktualisiert';

  @override
  String get save => 'Speichern';

  @override
  String left(String itemname, int count) {
    return '$itemname $count stück übrig';
  }

  @override
  String total(int count) {
    return 'total ($count)';
  }

  @override
  String get shareCode => 'Teile diesen Code mit deiner Familie';

  @override
  String get close => 'Schließen';

  @override
  String itemfill(String itemname) {
    return '$itemname auffüllen';
  }

  @override
  String daycount(int count) {
    return '$count days';
  }

  @override
  String get allEat => 'aufessen';

  @override
  String markAllAsEatenDescription(int quantity) {
    return 'Alle $quantity Stück werden als gegessen markiert.';
  }

  @override
  String markAllAsDiscardedDescription(int quantity) {
    return 'Alle $quantity Stück werden als entsorgt markiert.';
  }

  @override
  String get markAllAsEaten => 'Alles essen';

  @override
  String get markAllAsDiscarded => 'Alles entsorgen';

  @override
  String get deleteCompletelyFromFridge =>
      'Vollständig aus dem Kühlschrank löschen';

  @override
  String get processCompleted => 'Vorgang abgeschlossen';

  @override
  String expiryUntil(String date) {
    return 'Bis $date';
  }

  @override
  String categoryWithEmoji(String emoji, String category) {
    return '$emoji $category';
  }

  @override
  String get emptyState => 'Es ist leer!';

  @override
  String get expand => 'Mehr anzeigen';

  @override
  String totalItemsSummary(int totalQty, int typeCount) {
    return 'Insg.$totalQty Stück ($typeCount Ablauf)';
  }

  @override
  String addedWithNewExpiry(String itemName, int count) {
    return '$count $itemName wurden mit neuem Ablaufdatum hinzugefügt! 🎉';
  }

  @override
  String itemWithQuantity(String itemName, int quantity) {
    return '$itemName ($quantity)';
  }

  @override
  String quantities(int qty) {
    return '$qty stück';
  }

  @override
  String get put => 'Hinzufügen';

  @override
  String get permanentDelete => 'Endgültig löschen';

  @override
  String confirmDeleteSelected(int count) {
    return 'Möchten Sie die ausgewählten $count Elemente endgültig löschen?\nDiese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String get emptyTrash => 'Papierkorb leeren';

  @override
  String confirmEmptyTrash(int count) {
    return 'Möchten Sie alle Elemente im Papierkorb ($count) endgültig löschen?';
  }

  @override
  String get emptyAll => 'Alles leeren';

  @override
  String get trashCleaned => 'Der Papierkorb wurde erfolgreich geleert ✨';

  @override
  String selectedCount(int count) {
    return '$count ausgewählt';
  }

  @override
  String get trashTitle => 'Papierkorb 🗑️';

  @override
  String get restoreSelected => 'Ausgewählte wiederherstellen';

  @override
  String get deleteSelectedPermanently => 'Ausgewählte endgültig löschen';

  @override
  String get trashEmpty => 'Der Papierkorb ist leer.';

  @override
  String discardedItemInfo(int quantity, String date) {
    return 'Entsorgt: $quantity  |  Ablaufdatum: $date';
  }

  @override
  String get whatToDoWithItem => 'Was möchten Sie mit diesem Artikel tun?';

  @override
  String get restore => 'Wiederherstellen';

  @override
  String get restoredToFridge => 'In den Kühlschrank wiederhergestellt ♻️';

  @override
  String restoreCompleted(int count) {
    return '$count Elemente wiederhergestellt! Schau in deinen Kühlschrank ♻️';
  }

  @override
  String permanentDeleteCompleted(int count) {
    return '$count Elemente endgültig gelöscht 🗑️';
  }

  @override
  String get permanentDeleted => 'Endgültig gelöscht.';

  @override
  String countItems(int count) {
    return '$count Stück';
  }

  @override
  String get categoryMeat => 'Fleisch';

  @override
  String get categoryVegetable => 'Gemüse';

  @override
  String get categoryFruit => 'Obst';

  @override
  String get categoryDairy => 'Milchprodukte';

  @override
  String get categorySeafood => 'Meeresfrüchte';

  @override
  String get categoryBeverage => 'Getränke';

  @override
  String get categoryBakery => 'Backwaren';

  @override
  String get categorySauce => 'Saucen & Gewürze';

  @override
  String get categoryFrozen => 'Tiefkühlkost';

  @override
  String get categoryCanned => 'Konserven';

  @override
  String get categoryInstant => 'Fertiggerichte';

  @override
  String get categoryNoodle => 'Nudeln & Pasta';

  @override
  String get categoryEtc => 'Sonstiges';

  @override
  String get categoryFish => 'Fisch';

  @override
  String get confirm => 'Bestädigen';

  @override
  String get enterFridgeName =>
      'Bitte geben Sie einen Namen für den Kühlschrank ein';
}
