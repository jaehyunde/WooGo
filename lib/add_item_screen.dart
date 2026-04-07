import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'item_model.dart';
import 'fridge_service.dart';
import 'notification_service.dart';
import 'l10n/app_localizations.dart';
import 'utils.dart';
import 'thema/app_color.dart';
import 'package:dotted_border/dotted_border.dart';

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

  late FocusNode _nameFocusNode;
  late FocusNode _expiryDaysFocusNode;

  bool _addToFavorites = false;
  bool _isNameFocused = false;
  bool _isExpiryDaysFocused = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
    }
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory;
    }
    _nameFocusNode = FocusNode();

    // 포커스가 바뀔 때마다 상태를 업데이트하는 리스너 등록 ✅
    _nameFocusNode.addListener(() {
      setState(() {
        _isNameFocused = _nameFocusNode.hasFocus;
      });
    });
    _expiryDaysFocusNode = FocusNode();

    // 리스너 등록
    _expiryDaysFocusNode.addListener(() {
      setState(() {
        _isExpiryDaysFocused = _expiryDaysFocusNode.hasFocus;
      });
    });
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
    return GestureDetector(
      onTap: () {
        // 2. 화면 어디든 빈 곳을 누르면 포커스를 강제로 해제하여 키보드를 닫습니다.
        FocusManager.instance.primaryFocus?.unfocus();
      },
      // 3. 중요: 투명한 배경 터치도 인식하게 하여 '진짜 빈 공간'을 눌러도 작동하게 합니다.
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: AppColors.navy01,
        appBar: AppBar(
            backgroundColor: AppColors.navy01,
            iconTheme: IconThemeData(color: AppColors.contrast),
            title: Text(
              AppLocalizations.of(context)!.fillFridgePlus,
              style: TextStyle(color: AppColors.contrast),
            )
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 이름 입력
                Focus(
                  onFocusChange: (hasFocus) {
                    setState(() => _isNameFocused = hasFocus); // 상태 변수 필요 ✅
                  },
                  child: DottedBorder(
                    // 1. 선택 시 실선(두께 3), 미선택 시 실선(두께 2) 느낌 유지
                    color: AppColors.appwhite,
                    strokeWidth: _isNameFocused ? 3 : 2,
                    strokeCap: StrokeCap.round,

                    // 2. 선택 시 점선 [4, 4], 미선택 시 실선 [1, 0] ✅
                    dashPattern: _isNameFocused ? const [4, 4.7] : const [1, 0],

                    borderType: BorderType.RRect,
                    radius: const Radius.circular(12), // 기존 곡률 12 유지
                    child: TextField(
                      style: TextStyle(color: AppColors.appwhite, fontSize: 16),
                      controller: _nameController,
                      cursorColor: AppColors.appwhite,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.itemName,
                        labelStyle: TextStyle(
                          color: AppColors.appwhite.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                        ),
                        hintText: AppLocalizations.of(context)!.itemNameExample,
                        hintStyle: TextStyle(
                          color: AppColors.appwhite.withOpacity(0.8),
                        ),

                        // 3. DottedBorder가 테두리를 그리므로 TextField 자체 보더는 제거 ✅
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,

                        // 아이콘 및 패딩 설정
                        prefixIcon: Icon(Icons.edit, color: AppColors.contrast),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _saveItem(),
                    ),
                  ),
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
                      menuItems.add(DropdownMenuItem(
                        value: name,
                        child: Row(
                          children: [
                            // String을 Text 위젯으로 감싸서 전달 ✅
                            Text(
                                getCategoryEmoji(name),
                                style: TextStyle(
                                    fontSize: 22,
                                    color: AppColors.contrast
                                )
                            ),
                            SizedBox(width: 10),
                            Text(
                                translateCategory(name, context),
                                style: TextStyle(
                                    fontFamily: 'KidariFont',
                                    color: AppColors.appwhite, fontWeight: FontWeight.bold
                                )
                            ),
                          ],
                        ),
                      ));
                    }

                    if (menuItems.isEmpty)
                      return Text(AppLocalizations.of(context)!.noCategories);
                    if (_selectedCategory != null &&
                        !menuItems.any((item) => item.value ==
                            _selectedCategory)) _selectedCategory = null;

                    return DropdownMenu<String>(
                      initialSelection: _selectedCategory,
                      // 텍스트 스타일 및 메뉴 높이 유지
                      textStyle: TextStyle(color: AppColors.appwhite, fontSize: 16),
                      menuHeight: 400,
                      width: MediaQuery.of(context).size.width - 32, // Padding 16*2 제외

                      // 1. 열린 박스(메뉴)의 스타일 설정 ✅
                      menuStyle: MenuStyle(
                        backgroundColor: WidgetStatePropertyAll(AppColors.navy01),
                        // 열린 박스의 너비만 따로 제한 (예: 250)
                        fixedSize: const WidgetStatePropertyAll(Size.fromWidth(250)),
                        // 열린 박스의 테두리 색상 및 모양 설정
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: AppColors.appwhite, width: 2), // 테두리 색상 지정
                          ),
                        ),
                      ),

                      // 2. 입력창 디자인 설정 (기존 InputDecoration 반영)
                      label: Text(
                        AppLocalizations.of(context)!.category,
                        style: TextStyle(color: AppColors.appwhite.withOpacity(0.8), fontWeight: FontWeight.bold),
                      ),
                      inputDecorationTheme: InputDecorationTheme(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.appwhite, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.appwhite, width: 2),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      // 아이콘 및 기타 설정
                      trailingIcon: Icon(Icons.arrow_drop_down, color: AppColors.contrast),
                      leadingIcon: Icon(Icons.category, color: AppColors.contrast),
                      hintText: AppLocalizations.of(context)!.chooseCategory,

                      // 3. 항목 데이터 변환 (기존 menuItems 활용)
                      dropdownMenuEntries: menuItems.map((item) {
                        return DropdownMenuEntry<String>(
                          value: item.value!,
                          label: "${getCategoryEmoji(item.value!)} ${translateCategory(item.value!, context)}",
                          labelWidget: item.child, // 기존에 정의된 Row(이모지+텍스트) 위젯 사용
                        );
                      }).toList(),

                      // 4. 기존 로직 유지 (수정/삭제 금지) ✅
                      onSelected: (val) {
                        setState(() {
                          _selectedCategory = val;
                          var selectedDoc = snapshot.data!.docs.firstWhere((
                              doc) => doc['name'] == val);
                          _baseDays = selectedDoc['defaultDays'];
                          _recalculateExpiryDate();
                        });
                      },
                    );
                  },
                ),
                SizedBox(height: 20),

                // 3. 보관 장소
                DropdownMenu<String>(
                  initialSelection: _selectedLocation,
                  // 닫힌 상태의 박스 너비 (전체 너비 사용)
                  width: MediaQuery.of(context).size.width - 32, // Padding 16*2 제외
                  textStyle: TextStyle(
                      fontFamily: 'KidariFont',
                      color: AppColors.appwhite.withOpacity(0.8),
                      fontWeight: FontWeight.bold
                  ),

                  // 1. 열린 박스(메뉴)의 스타일 설정 ✅
                  menuStyle: MenuStyle(
                    backgroundColor: WidgetStatePropertyAll(AppColors.navy01),
                    // 열린 박스의 너비만 따로 제한
                    fixedSize: const WidgetStatePropertyAll(Size.fromWidth(250)),
                    // 열린 박스의 테두리 색상 및 곡선 설정
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: AppColors.appwhite, width: 2), // 테두리 색상
                      ),
                    ),
                  ),

                  // 2. 입력창 디자인 설정 (기존 InputDecoration 속성 반영)
                  label: Text(
                    AppLocalizations.of(context)!.storageLocation,
                    style: TextStyle(color: AppColors.contrast, fontWeight: FontWeight.bold),
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.appwhite, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.appwhite, width: 2),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  leadingIcon: Icon(Icons.kitchen, color: AppColors.contrast),
                  trailingIcon: Icon(Icons.arrow_drop_down, color: AppColors.contrast, size: 24),

                  // 3. 항목 데이터 변환 ✅
                  dropdownMenuEntries: [
                    {'val': '냉장', 'label': AppLocalizations.of(context)!.storageFridge},
                    {'val': '냉동', 'label': AppLocalizations.of(context)!.storageFreezer},
                    {'val': '펜트리', 'label': AppLocalizations.of(context)!.storagePantry},
                  ].map((item) {
                    return DropdownMenuEntry<String>(
                      value: item['val']!,
                      label: item['label']!,
                      labelWidget: Text(
                          item['label']!,
                          style: TextStyle(
                              fontFamily: 'KidariFont',
                              color: AppColors.appwhite,
                              fontWeight: FontWeight.bold
                          )
                      ),
                    );
                  }).toList(),

                  // 4. 기존 로직 절대 유지 ✅
                  onSelected: (val) {
                    setState(() {
                      _selectedLocation = val!;
                      _recalculateExpiryDate();
                    });
                  },
                ),
                SizedBox(height: 20),

                // 4. 수량 입력
                Text(
                    AppLocalizations.of(context)!.quantity,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.contrast,
                        fontFamily: 'KidariFont')),
                SizedBox(height: 8),
                Row(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.appwhite, width: 2),
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: IconButton(
                              icon: Icon(
                                Icons.remove, color: AppColors.contrast,),
                              onPressed: _decreaseQuantity)
                      ),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0),
                              child: TextField(
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'KidariFont',
                                      color: AppColors.appwhite),
                                  decoration: InputDecoration(
                                      border: UnderlineInputBorder(
                                      )
                                  )
                              )
                          )
                      ),
                      Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.appwhite, width: 2),
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: IconButton(
                              icon: Icon(Icons.add, color: AppColors.contrast),
                              onPressed: _increaseQuantity)
                      )
                    ]
                ),
                SizedBox(height: 20),

                // 5. 유통기한 (숫자 + 달력 하이브리드)
                Text(
                    AppLocalizations.of(context)!.expiryAutoCalculated,
                    style: TextStyle(
                        fontFamily: 'KidariFont',
                        color: AppColors.navy01
                    )
                ),
                SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Focus(
                        // 1. 여기서 포커스 변화를 감지해서 상태를 바꿉니다. ✅
                        onFocusChange: (hasFocus) {
                          setState(() => _isExpiryDaysFocused = hasFocus);
                        },
                        child: DottedBorder(
                          // 2. 부모(Focus)가 알려준 상태에 따라 점선/실선을 결정합니다. ✅
                          color: AppColors.appwhite,
                          strokeWidth: _isNameFocused ? 3 : 2,
                          strokeCap: StrokeCap.round,
                          dashPattern: _isExpiryDaysFocused ? const [4, 4] : const [1, 0],
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(12),
                          child: TextField(
                            controller: _expiryDaysController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'KidariFont',
                                color: AppColors.appwhite),
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,

                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                suffixText: AppLocalizations.of(context)!.day,
                                suffixStyle: TextStyle(color: AppColors.contrast)
                            ),
                            onChanged: _onDaysChanged,
                          ),
                        ),
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
                            firstDate: DateTime.now().subtract(
                                Duration(days: 365)),
                            lastDate: DateTime.now().add(Duration(days: 3650)),
                          );
                          if (picked != null) _onDatePicked(picked);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 13,
                              horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.appwhite, width: 2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  DateFormat('yyyy.MM.dd').format(_expiryDate),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'KidariFont',
                                      color: AppColors.appwhite
                                  )
                              ),
                              Icon(Icons.calendar_today,
                                  color: AppColors.contrast),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),
                CheckboxListTile(
                    title: Text(
                        AppLocalizations.of(context)!.addToFavorites,
                        style: TextStyle(
                            fontFamily: 'KidariFont',
                            color: AppColors.contrast
                        )
                    ),
                    activeColor: AppColors.contrast,
                    checkColor: AppColors.navy01,
                    side: BorderSide(
                      color: AppColors.contrast,
                      width: 2.0,
                    ),
                    value: _addToFavorites,
                    onChanged: (bool? value) {
                      setState(() {
                        _addToFavorites = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero
                ),
                SizedBox(height: 20),
                SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                        onPressed: _saveItem,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.contrast,
                            foregroundColor: AppColors.navy01,
                            textStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'KidariFont'
                            )
                        ),
                        child: Text(AppLocalizations.of(context)!.put)
                    )
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}