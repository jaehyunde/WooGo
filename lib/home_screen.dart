// lib/home_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fridge_service.dart';
import 'item_model.dart';
import 'add_item_screen.dart';
import 'category_screen.dart';
import 'trash_screen.dart';
import 'favorite_screen.dart';
import 'notification_service.dart';
import 'l10n/app_localizations.dart';
import 'locale_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FridgeService _service = FridgeService();

  // 날짜 계산
  String _calculateDDay(DateTime expiry) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiryDay = DateTime(expiry.year, expiry.month, expiry.day);
    final difference = expiryDay.difference(today).inDays;

    if (difference < 0) return AppLocalizations.of(context)!.daysExpired(difference.abs()); //"${difference.abs()}일 지남";
    if (difference == 0) return AppLocalizations.of(context)!.today;
    return AppLocalizations.of(context)!.daysLeft(difference); //"$difference일 남음";
  }

  // 색상 계산
  Color _getUrgencyColor(DateTime expiry) {
    final daysLeft = expiry.difference(DateTime.now()).inDays;
    if (daysLeft < 0) return Colors.grey;
    if (daysLeft <= 3) return Colors.redAccent;
    if (daysLeft <= 7) return Colors.orange;
    return Colors.green;
  }

  // 보관 위치별 뱃지 색상 및 텍스트 색상
  Color _getLocationColor(String location) {
    switch (location) {
      case '냉장': return Colors.cyan[100]!; // 연한 파랑
      case '냉동': return Colors.blue[100]!; // 연한 하늘색
      case '펜트리': return Colors.orange[100]!; // 연한 주황
      default: return Colors.grey[200]!;
    }
  }

  Color _getLocationTextColor(String location) {
    switch (location) {
      case '냉장': return Colors.cyan[800]!;
      case '냉동': return Colors.blue[800]!;
      case '펜트리': return Colors.brown[600]!;
      default: return Colors.black54;
    }
  }

  // 카테고리 이모지
  Widget _getCategoryEmoji(String name) {
    String emoji = '🏷️';
    String lowerName = name.toLowerCase();
    if (lowerName.contains('즐겨찾기')) emoji = '⭐';
    else if (lowerName.contains('육류') || lowerName.contains('고기') || lowerName.contains('meat')) emoji = '🥩';
    else if (lowerName.contains('치즈') || lowerName.contains('cheese')) emoji = '🧀';
    else if (lowerName.contains('유제품') || lowerName.contains('우유') || lowerName.contains('dairy') || lowerName.contains('milk')) emoji = '🥛';
    else if (lowerName.contains('야채') || lowerName.contains('채소') || lowerName.contains('vegetable') || lowerName.contains('veggie')) emoji = '🥦';
    else if (lowerName.contains('과일') || lowerName.contains('fruit')) emoji = '🍎';
    else if (lowerName.contains('냉동') || lowerName.contains('아이스크림')) emoji = '❄️';
    else if (lowerName.contains('음료') || lowerName.contains('beverage') || lowerName.contains('drink')) emoji = '🥤';
    else if (lowerName.contains('빵') || lowerName.contains('떡') || lowerName.contains('bakery')) emoji = '🍞';
    else if (lowerName.contains('생선') || lowerName.contains('해산물') || lowerName.contains('fish')) emoji = '🐟';
    else if (lowerName.contains('소스') || lowerName.contains('양념') || lowerName.contains('sauce')) emoji = '🥫';
    else if (lowerName.contains('즉석') || lowerName.contains('라면') || lowerName.contains('noodle')) emoji = '🍜';

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
      child: Text(emoji, style: TextStyle(fontSize: 20)),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
            AppLocalizations.of(context)!.languageSettings ?? "언어 선택",
            style: TextStyle(fontFamily: 'KidariFont', fontWeight: FontWeight.bold)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageOption(context, "한국어", const Locale('ko')),
            _languageOption(context, "English", const Locale('en')),
            _languageOption(context, "Deutsch", const Locale('de')),
          ],
        ),
      ),
    );
  }

  // 언어 선택용 리스트 타일 위젯
  Widget _languageOption(BuildContext context, String title, Locale locale) {
    return ListTile(
      title: Text(title, style: TextStyle(fontFamily: 'KidariFont')),
      onTap: () {
        // LocaleProvider를 통해 언어 변경 실행!
        Provider.of<LocaleProvider>(context, listen: false).setLocale(locale);
        Navigator.pop(context); // 다이얼로그 닫기
      },
    );
  }

  // ★ [신규 추가] 뱃지용 작은 이모지 텍스트 반환
  String _getCategorySimpleEmoji(String name) {
    String lowerName = name.toLowerCase();
    if (lowerName.contains('육류') || lowerName.contains('고기') || lowerName.contains('meat')) return '🥩';
    if (lowerName.contains('치즈') || lowerName.contains('cheese')) return '🧀';
    if (lowerName.contains('유제품') || lowerName.contains('우유') || lowerName.contains('dairy') || lowerName.contains('milk')) return '🥛';
    if (lowerName.contains('야채') || lowerName.contains('채소') || lowerName.contains('vegetable') || lowerName.contains('veggie')) return '🥦';
    if (lowerName.contains('과일') || lowerName.contains('fruit')) return '🍎';
    if (lowerName.contains('냉동') || lowerName.contains('아이스크림')) return '❄️';
    if (lowerName.contains('음료') || lowerName.contains('beverage') || lowerName.contains('drink')) return '🥤';
    if (lowerName.contains('빵') || lowerName.contains('떡') || lowerName.contains('bakery')) return '🍞';
    if (lowerName.contains('생선') || lowerName.contains('해산물') || lowerName.contains('fish')) return '🐟';
    if (lowerName.contains('소스') || lowerName.contains('양념') || lowerName.contains('sauce')) return '🥫';
    if (lowerName.contains('즉석') || lowerName.contains('라면') || lowerName.contains('noodle')) return '🍜';
    return '🏷️';
  }

  // 아이템 처리 로직
  Future<void> _processItemCount(BuildContext context, FridgeItem item, bool isConsume) async {
    int originalQty = item.quantity;
    bool wasRemoved = (!item.isFavorite && item.quantity <= 1);

    if (isConsume) {
      await _service.consumeItems(item, 1);
      if (item.quantity <= 1 && !item.isFavorite) await NotificationService().cancelNotification(item.id!);
    } else {
      await _service.discardItems(item, 1);
      if (item.quantity <= 1) await NotificationService().cancelNotification(item.id!);
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        // ★ action을 지우고 content 안에 Row로 '실행 취소'를 직접 만들었습니다.
        content: Row(
          children: [
            Expanded(
                child: Text(isConsume ? AppLocalizations.of(context)!.ateOne : AppLocalizations.of(context)!.discardedOne, style: TextStyle(fontFamily: 'KidariFont'))
            ),
            GestureDetector(
              onTap: () async {
                ScaffoldMessenger.of(context).hideCurrentSnackBar(); // 누르는 즉시 스낵바 닫기
                if (!wasRemoved) {
                  await _service.updateItemQuantity(item.id!, originalQty);
                } else {
                  if (isConsume) {
                    await _service.updateItemStatus(item.id!, 'normal');
                    if (originalQty > 0) await _service.updateItemQuantity(item.id!, originalQty);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.undoDiscardFromHistory), behavior: SnackBarBehavior.floating));
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.undo, style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold, fontFamily: 'KidariFont')),
            ),
          ],
        ),
      ),
    );
  }

  // ★ 아이템 속성(이름, 장소, 카테고리) 수정 팝업
  // ★ 파라미터에 dynamicLocations와 dynamicCategories를 추가로 받습니다!
  void _showEditPropertiesDialog(
      BuildContext context,
      FridgeItem item,
      List<String> dynamicLocations,
      List<String> dynamicCategories
      ) {
    TextEditingController nameController = TextEditingController(text: item.name);
    String selectedLocation = item.storageLocation;
    String selectedCategory = item.category;

    // 🚨 [핵심 안전장치] 만약 기존 카테고리나 장소가 삭제되어서 DB 리스트에 없다면?
    // 에러가 나지 않도록 현재 아이템이 가진 값을 리스트에 임시로 쏙 끼워 넣어줍니다.
    List<String> safeLocations = List.from(dynamicLocations);
    if (!safeLocations.contains(selectedLocation)) {
      safeLocations.add(selectedLocation);
    }

    List<String> safeCategories = List.from(dynamicCategories);
    if (!safeCategories.contains(selectedCategory)) {
      safeCategories.add(selectedCategory);
    }

    showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
              builder: (stateContext, setState) {
                return AlertDialog(
                  title: Text(AppLocalizations.of(context)!.editItemInfo, style: TextStyle(fontFamily: 'KidariFont', fontWeight: FontWeight.bold)),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. 이름 수정 (기존과 동일)
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.itemName,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          style: TextStyle(fontFamily: 'KidariFont', fontSize: 18),
                        ),
                        SizedBox(height: 15),

                        // 2. 보관 장소 수정 (수동 리스트 대신 safeLocations 사용)
                        DropdownButtonFormField<String>(
                          value: selectedLocation,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.storageLocation,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: safeLocations.map((loc) => DropdownMenuItem(
                              value: loc,
                              child: Text(loc, style: TextStyle(fontFamily: 'KidariFont', fontSize: 16))
                          )).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => selectedLocation = val);
                          },
                        ),
                        SizedBox(height: 15),

                        // 3. 카테고리 수정 (수동 리스트 대신 safeCategories 사용)
                        DropdownButtonFormField<String>(
                          value: selectedCategory, // 안전장치 덕분에 에러 안 남!
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.category,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: safeCategories.map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat, style: TextStyle(fontFamily: 'KidariFont', fontSize: 16))
                          )).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => selectedCategory = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    // ... (취소 버튼 코드는 기존과 동일) ...
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      onPressed: () async {
                        await _service.updateItemProperties(
                          item.id!,
                          newName: nameController.text.trim(),
                          newLocation: selectedLocation,
                          newCategory: selectedCategory,
                        );
                        Navigator.pop(dialogContext);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.successInfoEdit, style: TextStyle(fontFamily: 'KidariFont')))
                          );
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.save, style: TextStyle(fontFamily: 'KidariFont', fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                );
              }
          );
        }
    );
  }

  // 아이템 클릭 다이얼로그
  void _showActionDialog(BuildContext mainContext, FridgeItem item) {
    showDialog(
      context: mainContext,
      builder: (dialogContext) {
        int countToProcess = 1;
        DateTime currentExpiryDate = item.expiryDate;

        int daysLeft = currentExpiryDate.difference(DateTime.now()).inDays + 1;
        TextEditingController daysController = TextEditingController(text: daysLeft.toString());

        return StatefulBuilder(
          builder: (stateContext, setState) {
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.left(item.name, item.quantity),
                style: TextStyle(
                  fontFamily: 'KidariFont',
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 팝업 상단 아이콘들 (수정 버튼 & 즐겨찾기)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit_note, color: Colors.blueGrey, size: 28),
                          tooltip: AppLocalizations.of(context)!.editItemInfo,
                          onPressed: () async {
                            Navigator.pop(dialogContext); // 현재 팝업 닫기

                            // 1. 장소 리스트는 탭에 맞춰서 고정!
                            List<String> dbLocations = [AppLocalizations.of(context)!.storageFridge, AppLocalizations.of(context)!.storageFreezer, AppLocalizations.of(context)!.storagePantry];

                            // 2. DB에서 유저가 만든 최신 카테고리 이름만 쏙 뽑아옵니다!
                            List<String> dbCategories = await _service.getCategoryNames();

                            // 만약 DB에서 가져온 게 아무것도 없다면(초기 에러 등) 기본값 사용
                            if (dbCategories.isEmpty) {
                              dbCategories = ['채소', '과일', '육류', '수산물', '유제품', '가공식품', '음료', '조미료', '기타'];
                            }

                            if (!mainContext.mounted) return;

                            // 3. 불러온 리스트를 넣어서 수정 팝업 열기
                            _showEditPropertiesDialog(mainContext, item, dbLocations, dbCategories);
                          },
                        ),

                        // 기존 즐겨찾기 버튼
                        IconButton(
                          icon: Icon(item.isFavorite ? Icons.star : Icons.star_border, color: Colors.amber, size: 30),
                          tooltip: AppLocalizations.of(context)!.toggleFavorite,
                          onPressed: () async {
                            await _service.toggleItemFavorite(item.id!, item.isFavorite);
                            Navigator.pop(dialogContext);
                          },
                        ),
                      ],
                    ),
                    Text(AppLocalizations.of(context)!.selectQuantityAndDate, style: TextStyle(color: Colors.grey[700], fontFamily: 'KidariFont', fontWeight: FontWeight.bold)),
                    SizedBox(height: 15),

                    // 수량 조절
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 빼기 버튼
                        IconButton(
                            icon: Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              if (countToProcess > 1) setState(() => countToProcess--);
                            }
                        ),

                        // 현재 선택된 숫자
                        Container(
                            margin: EdgeInsets.symmetric(horizontal: 12),
                            child: Text("$countToProcess", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'KidariFont'))
                        ),

                        // 더하기 버튼
                        IconButton(
                            icon: Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setState(() => countToProcess++);
                            }
                        ),

                        // ★ [신규 추가] '전체 선택(MAX)' 버튼!
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue[50],
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            // 버튼을 누르면 카운트를 '현재 남은 전체 수량'으로 단번에 맞춰줍니다.
                            setState(() => countToProcess = item.quantity);
                          },
                          child: Text(
                            AppLocalizations.of(context)!.total(item.quantity),//"전체(${item.quantity}개)",
                            style: TextStyle(fontFamily: 'KidariFont', fontWeight: FontWeight.bold, color: Colors.blue[700]),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Divider(),
                    SizedBox(height: 10),

                    // 유통기한 수정 (숫자 + 달력)
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: daysController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.days,
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            ),
                            onChanged: (val) {
                              int? days = int.tryParse(val);
                              if (days != null) {
                                setState(() {
                                  currentExpiryDate = DateTime.now().add(Duration(days: days));
                                });
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: mainContext,
                                initialDate: currentExpiryDate,
                                firstDate: DateTime.now().subtract(Duration(days: 365)),
                                lastDate: DateTime.now().add(Duration(days: 3650)),
                              );
                              if (picked != null) {
                                setState(() {
                                  currentExpiryDate = picked;
                                  int diff = picked.difference(DateTime.now()).inDays + 1;
                                  daysController.text = diff.toString();
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(DateFormat('yy.MM.dd').format(currentExpiryDate), style: TextStyle(fontSize: 16, color: Colors.blue[700], fontFamily: 'KidariFont')),
                                  Icon(Icons.calendar_today, size: 18, color: Colors.blueGrey),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 단순 날짜 수정 버튼
                        OutlinedButton.icon(
                          icon: Icon(Icons.edit_calendar, size: 18, color: Colors.grey[700]),
                          label: Text(AppLocalizations.of(context)!.editCurrentItemDateOnly, style: TextStyle(fontFamily: 'KidariFont', color: Colors.grey[800])),
                          style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 10)),
                          onPressed: () async {
                            await _service.updateItemExpiryDate(item.id!, currentExpiryDate);
                            await NotificationService().cancelNotification(item.id!);
                            await NotificationService().scheduleNotification(itemId: item.id!, itemName: item.name, expiryDate: currentExpiryDate);

                            if (!mainContext.mounted) return;
                            ScaffoldMessenger.of(mainContext).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.expiryUpdated, style: TextStyle(fontFamily: 'KidariFont')), behavior: SnackBarBehavior.floating, duration: Duration(seconds: 2)));
                          },
                        ),
                        SizedBox(height: 8),
                        // 새로운 항목으로 추가하는 버튼 (유저 요청 기능)
                        ElevatedButton.icon(
                          icon: Icon(Icons.add_shopping_cart, size: 18),
                          label: Text(AppLocalizations.of(context)!.addAsNewExpiryItem, style: TextStyle(fontFamily: 'KidariFont', fontWeight: FontWeight.bold, fontSize: 16)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 12)),
                          onPressed: () async {
                            Navigator.pop(dialogContext); // 팝업 닫기

                            // ★ 새로운 ID를 만들어서 아예 독립된 아이템으로 DB에 저장합니다.
                            final newItem = FridgeItem(
                              id: DateTime.now().millisecondsSinceEpoch.toString(), // 고유 ID 새로 발급!
                              name: item.name,
                              category: item.category,
                              storageLocation: item.storageLocation,
                              quantity: countToProcess, // 위에서 선택한 추가 개수
                              purchaseDate: DateTime.now(),
                              expiryDate: currentExpiryDate, // 위에서 선택한 날짜
                              isFavorite: item.isFavorite,
                            );

                            await _service.addItem(newItem); // DB 추가
                            await NotificationService().scheduleNotification(itemId: newItem.id!, itemName: newItem.name, expiryDate: newItem.expiryDate);

                            if (!mainContext.mounted) return;
                            ScaffoldMessenger.of(mainContext).showSnackBar(
                                SnackBar(
                                    content:
                                    Text(
                                        AppLocalizations.of(context)!.addedWithNewExpiry(item.name, countToProcess),//"${item.name} $countToProcess개가 새 유통기한으로 추가되었습니다! 🎉",
                                        style: TextStyle(fontFamily: 'KidariFont')
                                    ),
                                    behavior: SnackBarBehavior.floating));
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // 하단 액션 버튼들 (기존 수량 증가, 버림, 먹음)
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actionsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              actions: [
                // 1. 추가 버튼 (+ 누르고 추가)
                ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black87, padding: EdgeInsets.symmetric(horizontal: 10)),
                    child: Text(AppLocalizations.of(context)!.add, style: TextStyle(fontFamily: 'KidariFont', fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      int originalQty = item.quantity; // ★ 되돌리기를 위해 원래 수량 기억
                      await _service.updateItemQuantity(item.id!, originalQty + countToProcess);

                      if (!mainContext.mounted) return;
                      ScaffoldMessenger.of(mainContext).hideCurrentSnackBar(); // 이전 팝업 비우기
                      ScaffoldMessenger.of(mainContext).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 3),
                            content: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[200],
                                        foregroundColor: Colors.black87,
                                        padding: EdgeInsets.zero, // 내부 패딩 줄임
                                      ),
                                      onPressed: () async { /* 기존 로직 동일 */ },
                                      child: FittedBox( // 글자가 길어지면 자동으로 크기를 줄임
                                        child: Text(AppLocalizations.of(context)!.add,
                                            style: const TextStyle(fontFamily: 'KidariFont', fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    ScaffoldMessenger.of(mainContext).hideCurrentSnackBar();
                                    await _service.updateItemQuantity(item.id!, originalQty);
                                  },
                                  child: Text(AppLocalizations.of(context)!.undo, style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold, fontFamily: 'KidariFont')),
                                ),
                              ],
                            ),
                          )
                      );
                    }
                ),
                // 2. 버림 버튼
                ElevatedButton.icon(
                    icon: Icon(Icons.delete, size: 16),
                    label: Text(AppLocalizations.of(context)!.discard, style: TextStyle(fontFamily: 'KidariFont')),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 10)),
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      int originalQty = item.quantity;
                      int safeCount = countToProcess > originalQty ? originalQty : countToProcess;
                      bool isCompletelyRemoved = (originalQty <= safeCount);

                      await _service.discardItems(item, safeCount);
                      if (isCompletelyRemoved) await NotificationService().cancelNotification(item.id!);

                      if (!mainContext.mounted) return;
                      ScaffoldMessenger.of(mainContext).hideCurrentSnackBar();
                      ScaffoldMessenger.of(mainContext).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 3),
                            content: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.delete, size: 14),
                                      label: FittedBox(
                                        child: Text(AppLocalizations.of(context)!.discard,
                                            style: const TextStyle(fontFamily: 'KidariFont')),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.zero,
                                      ),
                                      onPressed: () async { /* 기존 로직 동일 */ },
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    ScaffoldMessenger.of(mainContext).hideCurrentSnackBar();
                                    if (!isCompletelyRemoved) {
                                      await _service.updateItemQuantity(item.id!, originalQty);
                                    } else {
                                      if (!mainContext.mounted) return;
                                      ScaffoldMessenger.of(mainContext).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.undoDiscardFromHistory, style: TextStyle(fontFamily: 'KidariFont')), behavior: SnackBarBehavior.floating));
                                    }
                                  },
                                  child: Text(AppLocalizations.of(context)!.undo, style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold, fontFamily: 'KidariFont')),
                                ),
                              ],
                            ),
                          )
                      );
                    }
                ),
                // 3. 먹음 버튼
                ElevatedButton.icon(
                    icon: Icon(Icons.check, size: 16),
                    label: Text(AppLocalizations.of(context)!.eat, style: TextStyle(fontFamily: 'KidariFont')),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 10)),
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      int originalQty = item.quantity;
                      int safeCount = countToProcess > originalQty ? originalQty : countToProcess;
                      bool isCompletelyRemoved = (originalQty <= safeCount);

                      await _service.consumeItems(item, safeCount);
                      if (isCompletelyRemoved && !item.isFavorite) await NotificationService().cancelNotification(item.id!);

                      if (!mainContext.mounted) return;
                      ScaffoldMessenger.of(mainContext).hideCurrentSnackBar();
                      ScaffoldMessenger.of(mainContext).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 3),
                            content: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.check, size: 14),
                                      label: FittedBox(
                                        child: Text(AppLocalizations.of(context)!.eat,
                                            style: const TextStyle(fontFamily: 'KidariFont')),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.zero,
                                      ),
                                      onPressed: () async { /* 기존 로직 동일 */ },
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    ScaffoldMessenger.of(mainContext).hideCurrentSnackBar();
                                    if (!isCompletelyRemoved) {
                                      await _service.updateItemQuantity(item.id!, originalQty);
                                    } else {
                                      await _service.updateItemStatus(item.id!, 'normal');
                                      await _service.updateItemQuantity(item.id!, originalQty);
                                    }
                                  },
                                  child: Text(AppLocalizations.of(context)!.undo, style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold, fontFamily: 'KidariFont')),
                                ),
                              ],
                            ),
                          )
                      );
                    }
                ),
              ],
            );
          },
        );
      },
    );
  }

  // (기존 메뉴 함수들)
  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: Text(
                AppLocalizations.of(context)!.renameFridge),
            content: TextField(
                controller: controller,
                decoration: InputDecoration(hintText: AppLocalizations.of(context)!.enterNewName)),
            actions: [
              TextButton(child: Text(AppLocalizations.of(context)!.cancel),
                  onPressed: () => Navigator.pop(context)),
              ElevatedButton(
                  child: Text(AppLocalizations.of(context)!.change),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      _service.updateFridgeName(controller.text);
                      Navigator.pop(context);
                    }
                  }
                  )
            ]
        )
    );
  }

  void _showInviteCode(BuildContext context) async {
    String code = await _service.getInviteCode();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.familyInviteCode),
            content:
            Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      code,
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 2), textAlign: TextAlign.center),
                  SizedBox(height: 10),
                  Text(
                      AppLocalizations.of(context)!.shareCode,//"이 코드를 가족에게 공유하세요.",
                      style: TextStyle(fontSize: 12, color: Colors.grey))]),
            actions: [
              TextButton(onPressed: ()=>Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.close))])); }

  // 다 먹은 즐겨찾기 아이템을 다시 채우는 다이얼로그 (버그 패치 완료)
  void _showRestockDialog(BuildContext mainContext, String name, String category) {
    int qty = 1;
    int days = 7;
    showDialog(
        context: mainContext,
        builder: (dialogContext) {
          return StatefulBuilder(
              builder: (stateContext, setState) {
                return AlertDialog(
                  title: Text(
                      AppLocalizations.of(context)!.itemfill(name),//"$name 채우기",
                      style: TextStyle(fontFamily: 'KidariFont')
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppLocalizations.of(context)!.howMuchToFill, style: TextStyle(color: Colors.grey, fontFamily: 'KidariFont')),
                      SizedBox(height: 20),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(icon: Icon(Icons.remove), onPressed: () => setState(() => qty > 1 ? qty-- : qty)),
                            Text(" $qty ", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'KidariFont')),
                            IconButton(icon: Icon(Icons.add), onPressed: () => setState(() => qty++)),
                          ]
                      ),
                      SizedBox(height: 15),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(AppLocalizations.of(context)!.expirationDate, style: TextStyle(fontFamily: 'KidariFont')),
                            DropdownButton<int>(
                              value: days,
                              items: [3, 5, 7, 10, 14, 30, 60].map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                      AppLocalizations.of(context)!.daycount(e),//"$e일",
                                      style: TextStyle(fontFamily: 'KidariFont')
                                  )
                              )
                              ).toList(),
                              onChanged: (val) => setState(() => days = val!),
                            ),
                          ]
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(child: Text(AppLocalizations.of(context)!.undo, style: TextStyle(color: Colors.grey, fontFamily: 'KidariFont')), onPressed: () => Navigator.pop(dialogContext)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      child: Text(AppLocalizations.of(context)!.putInFridge, style: TextStyle(fontFamily: 'KidariFont')),
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        await _service.restockFromFavorite(name, category, qty, DateTime.now().add(Duration(days: days)));

                        if (!mainContext.mounted) return;
                        ScaffoldMessenger.of(mainContext).showSnackBar(
                            SnackBar(
                                content:
                                Text(
                                    AppLocalizations.of(context)!.filledItems(name, qty),//"$name $qty개 채워졌습니다! 🛒",
                                    style: TextStyle(fontFamily: 'KidariFont')
                                ), behavior: SnackBarBehavior.floating));
                      },
                    ),
                  ],
                );
              }
          );
        }
    );
  }
  // ★ 아이템 클릭 시 스르륵 올라오는 하단 메뉴
  void _showFullActionSheet(BuildContext context, FridgeItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 올라오게 설정
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    AppLocalizations.of(context)!.itemWithQuantity(item.name, item.quantity),//'${item.name} (${item.quantity}개)',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'KidariFont'),
                  ),
                ),
                const Divider(),

                // 1. 전체 먹음 버튼
                ListTile(
                  leading: const Icon(Icons.restaurant, color: Colors.green, size: 28),
                  title: Text(
                      AppLocalizations.of(context)!.markAllAsEaten,
                      style: TextStyle(fontSize: 18, fontFamily: 'KidariFont')
                  ),
                  subtitle: Text(
                      AppLocalizations.of(context)!.markAllAsDiscardedDescription(item.quantity),//'${item.quantity}개를 모두 먹은 것으로 처리합니다.',
                      style: TextStyle(fontFamily: 'KidariFont')),
                  onTap: () {
                    Navigator.pop(bottomSheetContext); // 팝업 먼저 닫기
                    _processFullQuantity(context, item, actionType: 'eat'); // 전체 처리 함수 호출
                  },
                ),

                // 2. 전체 버림 버튼
                ListTile(
                  leading: const Icon(Icons.delete_sweep, color: Colors.orange, size: 28),
                  title: Text(
                      AppLocalizations.of(context)!.markAllAsDiscarded, 
                      style: TextStyle(fontSize: 18, fontFamily: 'KidariFont')),
                  subtitle: Text(
                      AppLocalizations.of(context)!.markAllAsDiscardedDescription(item.quantity), //'${item.quantity}개를 모두 버린 것으로 처리합니다.',
                      style: TextStyle(fontFamily: 'KidariFont')),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _processFullQuantity(context, item, actionType: 'throw');
                  },
                ),

                // 3. 완전 삭제 버튼
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red, size: 28),
                  title: Text(AppLocalizations.of(context)!.deleteCompletelyFromFridge, style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'KidariFont')),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _processFullQuantity(context, item, actionType: 'delete');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  // ★ 전체 수량 일괄 처리 로직
  Future<void> _processFullQuantity(BuildContext context, FridgeItem item, {required String actionType}) async {
    try {
      if (actionType == 'eat') {
        // 예: 전체 수량만큼 먹음 처리 (DB 업데이트 등)
        // await FridgeService.updateItem(item.id, quantity: 0, status: 'eaten');
        print('${item.name} ${item.quantity}개 전부 먹음!');
      }
      else if (actionType == 'throw') {
        // 예: 전체 수량만큼 버림 처리 (DB 업데이트 등)
        // await FridgeService.updateItem(item.id, quantity: 0, status: 'discarded');
        print('${item.name} ${item.quantity}개 전부 버림!');
      }
      else if (actionType == 'delete') {
        // 예: 냉장고에서 아예 삭제 (DB 삭제)
        // await FridgeService.deleteItem(item.id);
        print('${item.name} 데이터 완전 삭제!');
      }

      // 화면 갱신 (setState가 필요하다면 추가)
      // setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.processCompleted, style: TextStyle(fontFamily: 'KidariFont')),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("일괄 처리 중 에러 발생: $e");
    }
  }

  // 위치별 리스트 빌더
  Widget _buildItemTile(BuildContext context, FridgeItem item, {bool isSubItem = false}) {
    final dDay = _calculateDDay(item.expiryDate);
    final color = _getUrgencyColor(item.expiryDate);
    bool isOutOfStock = item.quantity == 0;

    Widget tile = ListTile(
      contentPadding: isSubItem ? EdgeInsets.only(left: 30, right: 16) : null,
      onTap: () {
        if (isOutOfStock) {
          _showRestockDialog(context, item.name, item.category);
        } else {
          // ★ 원래 쓰시던 개별 처리 다이얼로그 그대로 유지!
          _showActionDialog(context, item);
        }
      },
      onLongPress: () {
        if (!isOutOfStock) {
          // ★ [신규 추가] 꾹~ 누르면 전체 처리 팝업 등장!
          _showFullActionSheet(context, item);
        }
      },
      title: Row(
        children: [
          if (isSubItem) Text("└  ", style: TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              isSubItem ? AppLocalizations.of(context)!.expiryUntil(DateFormat('yyyy.MM.dd').format(item.expiryDate)) : item.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'KidariFont', decoration: isOutOfStock ? TextDecoration.lineThrough : null, fontSize: isSubItem ? 15 : 18),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!isSubItem) SizedBox(width: 8),

          // ★ [신규] 즐겨찾기 상태일 때만 '카테고리 뱃지' 추가!
          if (!isSubItem && item.isFavorite)
            Container(
              margin: EdgeInsets.only(right: 4),
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6)),
              child: Text(
                  AppLocalizations.of(context)!.categoryWithEmoji(_getCategorySimpleEmoji(item.category), item.category),//"${_getCategorySimpleEmoji(item.category)} ${item.category}",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'KidariFont')
              ),
            ),

          if (!isSubItem)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: _getLocationColor(item.storageLocation), borderRadius: BorderRadius.circular(6)),
              child: Text(item.storageLocation, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _getLocationTextColor(item.storageLocation), fontFamily: 'KidariFont')),
            ),
        ],
      ),
      subtitle: Text(
          isOutOfStock ? AppLocalizations.of(context)!.needToBuy(count) : AppLocalizations.of(context)!.quantities(item.quantity),//"${item.quantity}개",
          style: TextStyle(fontFamily: 'KidariFont')
      ),
      // 서브 아이템은 장바구니 버튼 생략, D-Day만 표시
      trailing: isOutOfStock && !isSubItem
          ? IconButton(
          icon: Icon(
              Icons.add_shopping_cart,
              color: Colors.blue, size: 28),
          onPressed: () => _showRestockDialog(context, item.name, item.category)
      )
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(dDay, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: isSubItem ? 16 : 18, fontFamily: 'KidariFont')),
          if (!isSubItem) Text(DateFormat('MM.dd').format(item.expiryDate), style: TextStyle(fontSize: 15, color: Colors.grey, fontFamily: 'KidariFont')),
        ],
      ),
    );

    // 스와이프해서 먹음/버림 처리하는 기능은 그대로 유지!
    Widget dismissibleTile = Dismissible(
      key: Key(item.id!),
      direction: isOutOfStock ? DismissDirection.none : DismissDirection.horizontal,
      background: Container(color: Colors.green, alignment: Alignment.centerLeft, padding: EdgeInsets.symmetric(horizontal: 20), child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [Icon(Icons.check, color: Colors.white, size: 28), SizedBox(width: 10), Text("1개 먹음", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'KidariFont'))])),
      secondaryBackground: Container(color: Colors.red, alignment: Alignment.centerRight, padding: EdgeInsets.symmetric(horizontal: 20), child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text("1개 버림", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'KidariFont')), SizedBox(width: 10), Icon(Icons.delete_forever, color: Colors.white, size: 28)])),
      confirmDismiss: (direction) async {
        bool isConsume = (direction == DismissDirection.startToEnd);
        await _processItemCount(context, item, isConsume);
        return !item.isFavorite && item.quantity <= 1;
      },
      child: Opacity(opacity: isOutOfStock ? 0.5 : 1.0, child: tile),
    );

    if (isSubItem) {
      // 묶음 안의 아이템은 카드 테두리 없이 선으로만 구분
      return Column(children: [Divider(height: 1, color: Colors.grey[300]), dismissibleTile]);
    } else {
      // 단일 아이템은 기존처럼 카드 형태로 반환
      return Card(margin: EdgeInsets.only(bottom: 8), color: isOutOfStock ? Colors.grey[200] : null, child: dismissibleTile);
    }
  }

  // 위치별 리스트 빌더 (다 먹은 항목 숨기기 & 구매 필요 통합 로직)
  Widget _buildLocationList(BuildContext context, List<FridgeItem> allItems, String? locationFilter) {
    List<FridgeItem> filteredItems = locationFilter == null
        ? allItems
        : allItems.where((item) => item.storageLocation == locationFilter).toList();

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.kitchen_outlined, size: 60, color: Colors.grey[300]),
            SizedBox(height: 10),
            Text(AppLocalizations.of(context)!.emptyState, style: TextStyle(color: Colors.grey, fontSize: 18, fontFamily: 'KidariFont')),
          ],
        ),
      );
    }

    // 1차 그룹핑: 카테고리별로 묶기
    Map<String, List<FridgeItem>> groupedByCategory = {};
    for (var item in filteredItems) {
      String groupKey = item.isFavorite ? AppLocalizations.of(context)!.favorites : item.category;
      if (!groupedByCategory.containsKey(groupKey)) groupedByCategory[groupKey] = [];
      groupedByCategory[groupKey]!.add(item);
    }

    var sortedKeys = groupedByCategory.keys.toList();
    sortedKeys.sort((a, b) {
      if (a == AppLocalizations.of(context)!.favorites) return -1;
      if (b == AppLocalizations.of(context)!.favorites) return 1;
      return a.compareTo(b);
    });

    return ListView(
      padding: EdgeInsets.all(12),
      children: sortedKeys.map((categoryKey) {
        List<FridgeItem> categoryItems = groupedByCategory[categoryKey]!;

        // 2차 그룹핑: 이름이 같은 것끼리 묶기
        Map<String, List<FridgeItem>> itemsBySubGroup = {};
        for (var item in categoryItems) {
          // ★ [핵심] 3가지 속성을 합쳐서 고유 키(고유 이름표)를 만듭니다.
          // (예: "동원참치_가공식품_펜트리", "동원참치_가공식품_냉장")
          String uniqueKey = "${item.name}_${item.category}_${item.storageLocation}";

          if (!itemsBySubGroup.containsKey(uniqueKey)) {
            itemsBySubGroup[uniqueKey] = [];
          }
          itemsBySubGroup[uniqueKey]!.add(item);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4),
              child: Row(
                children: [
                  _getCategoryEmoji(categoryKey),
                  SizedBox(width: 10),
                  Text(categoryKey, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'KidariFont')),
                ],
              ),
            ),

            // 이름별로 묶인 아이템들을 화면에 그리기
            ...itemsBySubGroup.entries.map((entry) {
              List<FridgeItem> allGroupItems = entry.value; // 원래 묶인 전체 데이터

              // ★ 묶인 그룹의 첫 번째 아이템 이름을 대표 이름으로 사용합니다
              String itemName = allGroupItems.first.name;

              // ★ [핵심 1] 묶인 항목들의 총 수량 계산
              int totalQty = allGroupItems.fold(0, (sum, item) => sum + item.quantity);

              // ... (이 아래 코드는 기존 displayItems 로직 그대로 이어집니다) ...
              List<FridgeItem> displayItems;

              if (totalQty > 0) {
                displayItems = allGroupItems.where((item) => item.quantity > 0).toList();
              } else {
                displayItems = [allGroupItems.first];
              }

              displayItems.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

              // 필터링 결과 1개만 남았다면 단일 카드로 깔끔하게 표시
              if (displayItems.length == 1) {
                return _buildItemTile(context, displayItems.first);
              }
              // 2개 이상 남았다면 폴더(아코디언) 형태로 표시
              else {
                FridgeItem earliestItem = displayItems.first;

                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              itemName,
                              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'KidariFont', fontSize: 18),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),

                          if (earliestItem.isFavorite)
                            Container(
                              margin: EdgeInsets.only(right: 4),
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6)),
                              child: Text("${_getCategorySimpleEmoji(earliestItem.category)} ${earliestItem.category}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'KidariFont')),
                            ),

                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: _getLocationColor(earliestItem.storageLocation), borderRadius: BorderRadius.circular(6)),
                            child: Text(earliestItem.storageLocation, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _getLocationTextColor(earliestItem.storageLocation), fontFamily: 'KidariFont')),
                          ),
                        ],
                      ),

                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Text(
                                AppLocalizations.of(context)!.totalItemsSummary(totalQty, displayItems.length),//"총 $totalQty개 (기한 ${displayItems.length}종류)",
                                style: TextStyle(fontFamily: 'KidariFont', color: Colors.blueGrey, fontSize: 13)
                            ),
                            Spacer(), // 오른쪽으로 밀어내기

                            // 1. 즐겨찾기 일괄 변경 버튼 (⭐️)
                            InkWell(
                              onTap: () async {
                                bool targetFav = !earliestItem.isFavorite;
                                // ★ 주의: 화면에서 숨겨진(다 먹은) 항목들도 즐겨찾기 상태를 일치시켜 꼬이지 않게 합니다.
                                for (var item in allGroupItems) {
                                  if (item.isFavorite != targetFav) {
                                    await _service.toggleItemFavorite(item.id!, item.isFavorite);
                                  }
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                                child: Icon(earliestItem.isFavorite ? Icons.star : Icons.star_border, color: Colors.amber, size: 24),
                              ),
                            ),
                            SizedBox(width: 8),

                            // 2. 항목 추가 버튼 (➕)
                            InkWell(
                              onTap: () => _showActionDialog(context, earliestItem),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                                child: Icon(Icons.add_circle, color: Colors.blue, size: 24),
                              ),
                            ),
                          ],
                        ),
                      ),

                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_calculateDDay(earliestItem.expiryDate), style: TextStyle(color: _getUrgencyColor(earliestItem.expiryDate), fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'KidariFont')),
                          SizedBox(height: 4),
                          Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(AppLocalizations.of(context)!.expand,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontFamily: 'KidariFont',
                                        fontWeight: FontWeight.bold)
                                ),
                                Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                              ]
                          )
                        ],
                      ),
                      // 남은 항목들만 하위 리스트로 렌더링
                      children: displayItems.map((item) => _buildItemTile(context, item, isSubItem: true)).toList(),
                    ),
                  ),
                );
              }
            }).toList(),
            SizedBox(height: 10),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: StreamBuilder<String>(
            stream: _service.getFridgeNameStream(),
            builder: (context, snapshot) {
              return Text(snapshot.data ?? AppLocalizations.of(context)!.myFridge, style: TextStyle(fontFamily: 'KidariFont', fontWeight: FontWeight.bold));
            },
          ),
          actions: [
            IconButton(icon: Icon(Icons.star, color: Colors.amber), tooltip: AppLocalizations.of(context)!.manageFrequentItems, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FavoriteScreen()))),
            IconButton(icon: Icon(Icons.delete_outline), tooltip: AppLocalizations.of(context)!.discardHistory, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrashScreen()))),
            // home_screen.dart 의 PopupMenuButton 부분

            PopupMenuButton<String>(
              icon: Icon(Icons.settings),
              offset: Offset(0, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              onSelected: (value) {
                switch (value) {
                  case 'category':
                    Navigator.push(context, MaterialPageRoute(builder: (_) => CategorySettingsScreen()));
                    break;
                  case 'invite':
                    _showInviteCode(context);
                    break;
                  case 'rename':
                    _showRenameDialog(context);
                    break;
                // ★ 1. 언어 설정 케이스 추가
                  case 'language':
                    _showLanguageDialog(context);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                    value: 'category',
                    child: Row(
                        children: [
                          Icon(Icons.category, color: Colors.blue, size: 20),
                          SizedBox(width: 10),
                          Text(
                              AppLocalizations.of(context)!.manageCategories,
                              style: TextStyle(fontWeight: FontWeight.bold)
                          )
                        ]
                    )
                ),
                PopupMenuItem(
                    value: 'invite',
                    child: Row(
                        children: [
                          Icon(Icons.qr_code, color: Colors.purple, size: 20),
                          SizedBox(width: 10),
                          Text(
                              AppLocalizations.of(context)!.checkInviteCode,
                              style: TextStyle(fontWeight: FontWeight.bold)
                          )
                        ]
                    )
                ),
                PopupMenuItem(
                    value: 'language',
                    child: Row(
                        children: [
                          Icon(Icons.language, color: Colors.teal, size: 20),
                          SizedBox(width: 10),
                          Text(
                              AppLocalizations.of(context)!.languageSettings ?? "언어 설정",
                              style: TextStyle(fontWeight: FontWeight.bold)
                          )
                        ]
                    )
                ),

                PopupMenuDivider(),
                PopupMenuItem(
                    value: 'rename',
                    child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.orange, size: 20),
                          SizedBox(width: 10),
                          Text(AppLocalizations.of(context)!.renameFridge)
                        ]
                    )
                ),
              ],
            ),
            SizedBox(width: 10),
          ],

          bottom: TabBar(
            labelStyle: TextStyle(fontFamily: 'KidariFont', fontWeight: FontWeight.bold, fontSize: 16),
            unselectedLabelStyle: TextStyle(fontFamily: 'KidariFont', fontSize: 16),
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: AppLocalizations.of(context)!.all),
              Tab(text: AppLocalizations.of(context)!.storageFridge),
              Tab(text: AppLocalizations.of(context)!.storageFreezer),
              Tab(text: AppLocalizations.of(context)!.storagePantry), // [수정] 탭 이름 변경
            ],
          ),
        ),

        body: StreamBuilder<List<FridgeItem>>(
          stream: _service.getFridgeItems(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text(AppLocalizations.of(context)!.errorOccurred));
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
            final items = snapshot.data!;

            return TabBarView(
              children: [
                _buildLocationList(context, items, null),
                _buildLocationList(context, items, AppLocalizations.of(context)!.storageFridge),
                _buildLocationList(context, items, AppLocalizations.of(context)!.storageFreezer),
                _buildLocationList(context, items, AppLocalizations.of(context)!.storagePantry),
              ],
            );
          },
        ),

        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddItemScreen())),
        ),
      ),
    );
  }
}