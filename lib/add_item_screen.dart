// lib/add_item_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'item_model.dart';
import 'fridge_service.dart';
import 'notification_service.dart';
import 'l10n/app_localizations.dart';

class AddItemScreen extends StatefulWidget {
  final String? initialName;
  final String? initialCategory;

  AddItemScreen({this.initialName, this.initialCategory});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _service = FridgeService();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  // 유통기한 일수 입력용 컨트롤러
  final _expiryDaysController = TextEditingController(text: '7');

  String? _selectedCategory;
  String _selectedLocation = '냉장';
  int _baseDays = 7;

  DateTime _expiryDate = DateTime.now().add(Duration(days: 7));
  bool _addToFavorites = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
    }
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory;
    }
  }

  // 날짜 재계산 로직
  void _recalculateExpiryDate() {
    int finalDays = _baseDays;

    if (_selectedLocation == '냉동') {
      finalDays = _baseDays + 30;
    }

    setState(() {
      _expiryDate = DateTime.now().add(Duration(days: finalDays));
      _expiryDaysController.text = finalDays.toString();
    });
  }

  // 숫자를 입력했을 때 날짜 변경
  void _onDaysChanged(String value) {
    int? days = int.tryParse(value);
    if (days != null) {
      setState(() {
        _expiryDate = DateTime.now().add(Duration(days: days));
      });
    }
  }

  // 달력으로 날짜를 바꿨을 때 숫자 변경
  void _onDatePicked(DateTime picked) {
    setState(() {
      _expiryDate = picked;
      int daysDiff = picked.difference(DateTime.now()).inDays + 1;
      if (daysDiff < 0) daysDiff = 0;
      _expiryDaysController.text = daysDiff.toString();
    });
  }

  Widget _getCategoryEmoji(String name) {
    String emoji = '🏷️';
    String lowerName = name.toLowerCase();
    if (lowerName.contains('육류') || lowerName.contains('고기') || lowerName.contains('meat') || lowerName.contains('beef') || lowerName.contains('pork')) emoji = '🥩';
    else if (lowerName.contains('치즈') || lowerName.contains('cheese')) emoji = '🧀';
    else if (lowerName.contains('유제품') || lowerName.contains('우유') || lowerName.contains('dairy') || lowerName.contains('milk')) emoji = '🥛';
    else if (lowerName.contains('야채') || lowerName.contains('채소') || lowerName.contains('vegetable') || lowerName.contains('veggie')) emoji = '🥦';
    else if (lowerName.contains('과일') || lowerName.contains('fruit')) emoji = '🍎';
    else if (lowerName.contains('냉동') || lowerName.contains('아이스크림') || lowerName.contains('frozen') || lowerName.contains('ice')) emoji = '❄️';
    else if (lowerName.contains('음료') || lowerName.contains('beverage') || lowerName.contains('drink')) emoji = '🥤';
    else if (lowerName.contains('빵') || lowerName.contains('떡') || lowerName.contains('베이커리') || lowerName.contains('bread') || lowerName.contains('bakery')) emoji = '🍞';
    else if (lowerName.contains('생선') || lowerName.contains('해산물') || lowerName.contains('fish') || lowerName.contains('seafood')) emoji = '🐟';
    else if (lowerName.contains('소스') || lowerName.contains('양념') || lowerName.contains('sauce') || lowerName.contains('condiment')) emoji = '🥫';
    else if (lowerName.contains('즉석') || lowerName.contains('라면') || lowerName.contains('instant') || lowerName.contains('noodle')) emoji = '🍜';
    return Text(emoji, style: TextStyle(fontSize: 22));
  }

  void _increaseQuantity() {
    int current = int.tryParse(_quantityController.text) ?? 1;
    setState(() {
      current++;
      _quantityController.text = current.toString();
    });
  }

  void _decreaseQuantity() {
    int current = int.tryParse(_quantityController.text) ?? 1;
    if (current > 1) {
      setState(() {
        current--;
        _quantityController.text = current.toString();
      });
    }
  }

  void _saveItem() {
    // 1. 버튼을 누르자마자 모든 대기 중인 팝업부터 즉시 박살 냅니다! (에러 무한 대기열 방지)
    ScaffoldMessenger.of(context).clearSnackBars();

    // 2. 키보드를 가장 먼저 내립니다. (애니메이션 충돌 방지)
    FocusScope.of(context).unfocus();

    // --- 유효성 검사 (여기서 뜨는 팝업도 짧게 둥둥 띄웁니다) ---
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.enterItemName),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ));
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.selectCategory),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ));
      return;
    }

    // --- 데이터 저장 로직 (기존과 동일) ---
    final newItem = FridgeItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      category: _selectedCategory!,
      storageLocation: _selectedLocation,
      quantity: int.tryParse(_quantityController.text) ?? 1,
      purchaseDate: DateTime.now(),
      expiryDate: _expiryDate,
      isFavorite: _addToFavorites,
    );

    _service.addItem(newItem);

    if (_addToFavorites) {
      _service.addFavorite(newItem.name, newItem.category);
    }

    NotificationService().scheduleNotification(
        itemId: newItem.id!,
        itemName: newItem.name,
        expiryDate: newItem.expiryDate
    );

    _nameController.clear();
    setState(() {
      _quantityController.text = '1';
      _addToFavorites = false;
    });

    // 3. ★핵심★ 키보드가 내려갈 시간을 벌어주고 스낵바를 띄웁니다.
    // 3. ★ 정상적인 duration 복구 완료! (강제 종료 타이머 삭제)
    Future.delayed(Duration(milliseconds: 100), () {
      if (!mounted) return; // 안전장치

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2), // 이제 이 타이머가 정상 작동합니다!
          content: Row(
            children: [
              Expanded(
                child: Text("'${newItem.name}' 추가됨", style: TextStyle(fontFamily: 'KidariFont')),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();

                  // 실행 취소 팝업 (이 녀석도 action이 없으니 2초 뒤 자동 소멸!)
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.alreadySaved, style: TextStyle(fontFamily: 'KidariFont')),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      )
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(AppLocalizations.of(context)!.undo, style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold, fontFamily: 'KidariFont')),
                ),
              ),
            ],
          ),
        ),
      );
    });
  } // _saveItem()

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.fillFridgePlus)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 이름 입력
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.itemName, hintText: AppLocalizations.of(context)!.itemNameExample, border: OutlineInputBorder(), prefixIcon: Icon(Icons.edit)),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _saveItem(),
              ),
              SizedBox(height: 20),

              // 2. 카테고리 선택
              StreamBuilder<QuerySnapshot>(
                stream: _service.getCategoriesStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text("에러: ${snapshot.error}");
                  if (!snapshot.hasData) return LinearProgressIndicator();

                  List<DropdownMenuItem<String>> menuItems = [];
                  for (var doc in snapshot.data!.docs) {
                    var data = doc.data() as Map<String, dynamic>;
                    String name = data['name'];
                    menuItems.add(DropdownMenuItem(value: name, child: Row(children: [_getCategoryEmoji(name), SizedBox(width: 10), Text(name, style: TextStyle(fontFamily: 'KidariFont'))])));
                  }

                  if (menuItems.isEmpty) return Text(AppLocalizations.of(context)!.noCategories);
                  if (_selectedCategory != null && !menuItems.any((item) => item.value == _selectedCategory)) _selectedCategory = null;

                  return DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.category, border: OutlineInputBorder(), prefixIcon: Icon(Icons.category)),
                    items: menuItems,
                    hint: Text(AppLocalizations.of(context)!.chooseCategory),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategory = val;
                        var selectedDoc = snapshot.data!.docs.firstWhere((doc) => doc['name'] == val);
                        _baseDays = selectedDoc['defaultDays'];
                        _recalculateExpiryDate();
                      });
                    },
                  );
                },
              ),
              SizedBox(height: 20),

              // 3. 보관 장소
              DropdownButtonFormField<String>(
                value: _selectedLocation,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.storageLocation, border: OutlineInputBorder(), prefixIcon: Icon(Icons.kitchen)),
                items: ['냉장', '냉동', '펜트리'].map((String loc) {
                  return DropdownMenuItem<String>(value: loc, child: Text(loc, style: TextStyle(fontFamily: 'KidariFont')));
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedLocation = val!;
                    _recalculateExpiryDate();
                  });
                },
              ),
              SizedBox(height: 20),

              // 4. 수량 입력
              Text(AppLocalizations.of(context)!.quantity, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700], fontFamily: 'KidariFont')),
              SizedBox(height: 8),
              Row(children: [Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)), child: IconButton(icon: Icon(Icons.remove), onPressed: _decreaseQuantity)), Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: TextField(controller: _quantityController, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'KidariFont'), decoration: InputDecoration(border: UnderlineInputBorder())))), Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)), child: IconButton(icon: Icon(Icons.add), onPressed: _increaseQuantity))]),
              SizedBox(height: 20),

              // 5. 유통기한 (숫자 + 달력 하이브리드)
              Text(AppLocalizations.of(context)!.expiryAutoCalculated, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'KidariFont')),
              SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _expiryDaysController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'KidariFont'),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.days,
                        border: OutlineInputBorder(),
                        suffixText: AppLocalizations.of(context)!.day,
                      ),
                      onChanged: _onDaysChanged,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _expiryDate,
                          firstDate: DateTime.now().subtract(Duration(days: 365)),
                          lastDate: DateTime.now().add(Duration(days: 3650)),
                        );
                        if (picked != null) _onDatePicked(picked);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('yyyy.MM.dd').format(_expiryDate), style: TextStyle(fontSize: 16, fontFamily: 'KidariFont')),
                            Icon(Icons.calendar_today, color: Colors.blue),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
              CheckboxListTile(title: Text(AppLocalizations.of(context)!.addToFavorites, style: TextStyle(fontFamily: 'KidariFont')), value: _addToFavorites, onChanged: (bool? value) { setState(() { _addToFavorites = value ?? false; }); }, controlAffinity: ListTileControlAffinity.leading, contentPadding: EdgeInsets.zero),
              SizedBox(height: 20),
              SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                      onPressed: _saveItem,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          textStyle: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'KidariFont')
                      ),
                      child: Text(AppLocalizations.of(context)!.put)
                  )
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}