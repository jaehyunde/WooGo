import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'fridge_service.dart';
import 'intro_screen.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'locale_provider.dart';
import 'thema/app_color.dart';
import 'package:dotted_border/dotted_border.dart';

class EntranceScreen extends StatefulWidget {
  @override
  _EntranceScreenState createState() => _EntranceScreenState();
}

class _EntranceScreenState extends State<EntranceScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _codeController = TextEditingController();
  final _fridgeNameController = TextEditingController();

  bool _isLoading = false;
  bool _isJoinMode = false; // 입력창을 보여줄지 말지 결정하는 스위치
  bool _isCodeFocused = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // 자동 로그인 체크
  Future<void> _checkLoginStatus() async {
    User? user = _auth.currentUser;
    // 1. 로그인 안 된 경우 -> 여기서 멈춤 (화면 보여줌)
    if (user == null) return;

    // 2. 로그인 된 경우 -> 소속된 집이 있는지 확인
    final userDoc = await _db.collection('users').doc(user.uid).get();

    if (userDoc.exists && userDoc.data() != null && userDoc.data()!['householdId'] != null) {
      String householdId = userDoc.data()!['householdId'];
      _goToHome(householdId);
    }
  }

  Future<void> _goToHome(String householdId) async {
    // 기기 저장소에 ID가 완전히 저장될 때까지 기다립니다.
    await FridgeService().setHouseholdId(householdId);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => IntroScreen()),
    );
  }

  // A. 새 냉장고 만들기
  Future<void> _createFridge(String name) async {
    setState(() => _isLoading = true);

    try {
      // 1. 로그인 확인
      User? user = _auth.currentUser;
      if (user == null) {
        UserCredential userCredential = await _auth.signInAnonymously();
        user = userCredential.user;
      }
      if (user == null) throw Exception("로그인에 실패했습니다.");

      // 2. 초대코드 생성
      String inviteCode = Uuid().v4().substring(0, 6).toUpperCase();
      DocumentReference houseRef = await _db.collection('households').add({
        'name': name,
        'inviteCode': inviteCode,
        'members': [user.uid],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4. 유저 정보 연결
      await _db.collection('users').doc(user.uid).set({
        'householdId': houseRef.id,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // 1) 서비스에 "방금 만든 이 냉장고를 쓸 거야"라고 ID 등록
      //FridgeService().setHouseholdId(houseRef.id);
      await FridgeService().setHouseholdId(houseRef.id);

      // 2) 기본 카테고리(육류, 과일 등) 생성 함수 실행!
      await FridgeService().initializeDefaultCategories();

      // 5. 모든 준비가 끝났으니 이동
      _goToHome(houseRef.id);

    } catch (e) {
      print("에러 발생: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("오류가 발생했습니다: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ★ [추가] 냉장고 이름 입력 팝업
  void _showCreateFridgeDialog() {
    // 팝업을 열 때마다 컨트롤러 비우기
    _fridgeNameController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            AppLocalizations.of(context)!.enterFridgeName,
            style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _fridgeNameController,
            decoration: InputDecoration(
              // 사용자가 입력 전 힌트로 "우리집 냉장고" 등을 보여줍니다.
              hintText: AppLocalizations.of(context)!.myFridge,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel ?? "취소"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // 입력값이 있으면 그 값을, 없으면 기본 이름을 사용합니다.
                String finalName = _fridgeNameController.text.trim().isEmpty
                    ? AppLocalizations.of(context)!.myFridge
                    : _fridgeNameController.text.trim();

                _createFridge(finalName); // 실제 생성 함수 호출
              },
              child: Text(AppLocalizations.of(context)!.confirm ?? "확인"),
            ),
          ],
        );
      },
    );
  }

  // B. 코드로 입장하기
  Future<void> _joinFridge() async {
    String inputCode = _codeController.text.trim().toUpperCase();
    if (inputCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.enterCode)));
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? user = _auth.currentUser;
      if (user == null) {
        UserCredential userCredential = await _auth.signInAnonymously();
        user = userCredential.user;
      }

      // 코드 확인
      final querySnapshot = await _db
          .collection('households')
          .where('inviteCode', isEqualTo: inputCode)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception(AppLocalizations.of(context)!.invalidCode);
      }

      final houseDoc = querySnapshot.docs.first;

      // 유저 정보 저장
      await _db.collection('users').doc(user!.uid).set({
        'householdId': houseDoc.id,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // 하우스 멤버 추가
      await _db.collection('households').doc(houseDoc.id).update({
        'members': FieldValue.arrayUnion([user.uid])
      });

      _goToHome(houseDoc.id);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            "Language / 언어 / Sprache",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min, // 세로 길이를 내용물에 맞춤
            children: [
              _buildLanguageTile("한국어 (Korean)", const Locale('ko')),
              const Divider(),
              _buildLanguageTile("English (영어)", const Locale('en')),
              const Divider(),
              _buildLanguageTile("Deutsch (독일어)", const Locale('de')),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageTile(String label, Locale locale) {
    return ListTile(
      title: Text(label, textAlign: TextAlign.center),
      onTap: () {
        Provider.of<LocaleProvider>(context, listen: false).setLocale(locale);
        Navigator.pop(context); // 팝업 닫기
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(body: Center(child: Image.asset('assets/images/loading_logo.png', fit: BoxFit.cover, alignment: Alignment.center)));

    // 1. 전체를 GestureDetector로 감싸 빈 공간 터치를 감지합니다. ✅
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 포커스 해제 -> 점선 테두리 사라짐
      },
      // 2. 투명한 배경 터치도 인식하도록 설정 (iOS 필수) ✅
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/entrance_basic.png', // 실제 경로에 맞게 수정
                fit: BoxFit.cover, // 1242x2688 이미지를 화면에 꽉 채우는 핵심 속성!
              ),
            ),

            // 2. (옵션) 배경이 너무 밝아 글자가 안 보인다면 어둡게 처리 ✅
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 로고 영역
                  // const Icon(Icons.kitchen_rounded, size: 80, color: AppColors.navy03),
                  const SizedBox(height: 350),
                  /*const Text(
                    "WooGo",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'KidariFont',
                      color: AppColors.navy01,
                    ),
                  ),
                  Text(AppLocalizations.of(context)!.myFridge,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.navy02,
                          fontSize: 18,
                          fontFamily: 'KidariFont')),*/
                  const SizedBox(height: 330),

                  // ★ 버튼 A: 새 냉장고 만들기
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _showCreateFridgeDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy01,
                        foregroundColor: AppColors.appwhite,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: Text(AppLocalizations.of(context)!.createNewFridge,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(children: [
                    const Expanded(child: Divider(color: AppColors.navy03)),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(AppLocalizations.of(context)!.or,
                            style: const TextStyle(fontSize: 14, color: AppColors.navy03, fontWeight: FontWeight.bold))),
                    const Expanded(child: Divider(color: AppColors.navy03))
                  ]),

                  const SizedBox(height: 12),

                  // ★ 버튼 B vs 입력창
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: !_isJoinMode
                        ? // --- [Case 1: 초대코드 입력 버튼] ---
                    SizedBox(
                      key: const ValueKey('button'),
                      width: double.infinity,
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: OutlinedButton(
                          onPressed: () => setState(() => _isJoinMode = true),
                          style: OutlinedButton.styleFrom(
                            // 1. 버튼 배경색 추가 (흰색 10% 정도가 세련되게 보입니다) ✅
                            backgroundColor: AppColors.appwhite,
                            side: const BorderSide(color: AppColors.navy01, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(AppLocalizations.of(context)!.enterWithInviteCode,
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: AppColors.navy01,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    )
                        : // --- [Case 2: 초대코드 입력창] ---
                    SizedBox(
                      key: const ValueKey('input'),
                      width: double.infinity,
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Container(
                          // 2. 입력창 배경색 및 라운드 처리 ✅
                          decoration: BoxDecoration(
                            color: AppColors.appwhite, // 버튼과 동일한 배경색
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Focus(
                            onFocusChange: (hasFocus) => setState(() => _isCodeFocused = hasFocus),
                            child: DottedBorder(
                              // 3. 테두리 색상 제어 ✅
                              color: _isCodeFocused ? AppColors.navy01 : AppColors.navy01,
                              strokeWidth: 2,
                              strokeCap: StrokeCap.round,
                              dashPattern: _isCodeFocused ? const [4, 5.5] : const [1, 0],
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(12),
                              child: Center(
                                child: TextField(
                                  controller: _codeController,
                                  cursorColor: AppColors.navy01,
                                  textAlignVertical: TextAlignVertical.center,
                                  style: const TextStyle(
                                      color: AppColors.navy01, fontFamily: 'KidariFont', fontSize: 16),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                    hintText: AppLocalizations.of(context)!.inviteCodeExample,
                                    hintStyle: TextStyle(color: AppColors.navy01.withOpacity(0.6), fontSize: 16, fontWeight: FontWeight.bold),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    prefixIcon: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.arrow_back, color: AppColors.navy01, size: 20),
                                      onPressed: () {
                                        setState(() => _isJoinMode = false);
                                        _codeController.clear();
                                        FocusScope.of(context).unfocus();
                                      },
                                    ),
                                    suffixIcon: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.login, color: AppColors.navy01, size: 20),
                                      onPressed: _joinFridge,
                                    ),
                                  ),
                                  onSubmitted: (_) => _joinFridge(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- [추가된 지구본 버튼] ---
            Positioned(
              top: 60,
              right: 25,
              child: GestureDetector(
                onTap: _showLanguageDialog,
                child: Container(
                  padding: const EdgeInsets.all(4), // 아이콘 크기에 맞춰 패딩 살짝 조절
                  decoration: BoxDecoration(
                    color: AppColors.navy01, // 배경은 기존 네이비 유지
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  // 1. 이모지 대신 Icon 위젯 사용 ✅
                  child: const Icon(
                    Icons.language, // 또는 Icons.public (취향에 맞게 선택)
                    color: AppColors.appwhite, // 아이콘 색상을 흰색 계열로 변경
                    size: 35, // 기존 이모지 크기와 비슷하게 설정
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}