// lib/entrance_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'fridge_service.dart';
import 'intro_screen.dart';
import 'l10n/app_localizations.dart';

class EntranceScreen extends StatefulWidget {
  @override
  _EntranceScreenState createState() => _EntranceScreenState();
}

class _EntranceScreenState extends State<EntranceScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _codeController = TextEditingController();

  bool _isLoading = false;
  bool _isJoinMode = false; // ★ [신규] 입력창을 보여줄지 말지 결정하는 스위치

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
  Future<void> _createFrigde() async {
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

      // 3. DB에 냉장고(Household) 문서 생성
      DocumentReference houseRef = await _db.collection('households').add({
        'name': '우리집 냉장고',
        'inviteCode': inviteCode,
        'members': [user.uid],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4. 유저 정보 연결
      await _db.collection('users').doc(user.uid).set({
        'householdId': houseRef.id,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // ★★★ [신규 추가] 냉장고 생성 직후, 기본 카테고리 자동 생성하기 ★★★

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 로고 영역
            Icon(Icons.kitchen_rounded, size: 80, color: Colors.blue[300]),
            SizedBox(height: 20),
            Text(
              "WooGo",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: 'KidariFont',
                color: Colors.blue[800],
              ),
            ),
            Text(AppLocalizations.of(context)!.myFridge,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey,
                    fontSize: 18,
                    fontFamily: 'KidariFont')),
            SizedBox(height: 60),


            // ★ 버튼 A: 새 냉장고 만들기 (항상 보임)
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: _createFrigde,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: Text(AppLocalizations.of(context)!.createNewFridge,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),

            SizedBox(height: 20),

            Row(children: [
              Expanded(child: Divider()),
              Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text(AppLocalizations.of(context)!.or, style: TextStyle(fontSize: 16, color: Colors.grey))),
              Expanded(child: Divider())
            ]),

            SizedBox(height: 15),

            // ★ 버튼 B vs 입력창 (상태에 따라 변신!)
            AnimatedCrossFade(
              duration: Duration(milliseconds: 300),
              crossFadeState: _isJoinMode ? CrossFadeState.showSecond : CrossFadeState.showFirst,

              // 1. 처음 상태: 버튼 모양
              firstChild: SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _isJoinMode = true); // 클릭하면 입력창 모드로 변경!
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(AppLocalizations.of(context)!.enterWithInviteCode,
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold)),
                ),
              ),

              // 2. 누른 후 상태: 입력창 모양
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: TextField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.inviteCode6Digits,
                    hintText: AppLocalizations.of(context)!.inviteCodeExample,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() => _isJoinMode = false);
                        _codeController.clear();
                      },
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.login, color: Colors.blue),
                      onPressed: _joinFridge,
                    ),
                  ),
                  onSubmitted: (_) => _joinFridge(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}