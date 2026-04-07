import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'fridge_service.dart';
import 'home_screen.dart';
import 'entrance_screen.dart';
import 'l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'thema/app_color.dart';


class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final FridgeService _service = FridgeService();
  String _fridgeName = "";

  // ★ [신규] 애니메이션을 위한 크기 변수 (1.0 = 100% 크기)
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _prepareData();
    _syncData();
    _loadFridgeName();
  }

  Future<void> _loadFridgeName() async {
    // 1. 현재 사용 중인 householdId 가져오기
    String? householdId = FridgeService().currentHouseholdId;


    if (householdId != null) {
      // 2. Firestore에서 해당 냉장고 문서 가져오기
      var doc = await FirebaseFirestore.instance
          .collection('households')
          .doc(householdId)
          .get();

      if (doc.exists && mounted) {
        setState(() {
          // 3. 필드명 'name'으로 저장된 값을 변수에 할당
          _fridgeName = doc.data()?['name'] ?? "";
        });
      }
    }
  }

  Future<void> _prepareData() async {
    // 1. 저장된 냉장고 ID 복구 (가장 중요!)
    String? savedId = await _service.loadSavedId();

    // 2. 기존 동기화 로직 실행
    if (savedId != null) {
      await _service.syncFamilyNotifications();
    }

    if (mounted) setState(() {}); // ID 로드 후 화면 갱신이 필요하다면 실행
  }

  void _syncData() async {
    await _service.syncFamilyNotifications();
  }

  // ★ [신규] 터치 시작 (작아짐)
  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.95; // 95% 크기로 축소
    });
  }

  // ★ [신규] 터치 끝 (원상복구)
  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0; // 원래 크기로 복귀
    });
  }

  // ★ [신규] 터치 취소 (드래그해서 밖으로 나감 등)
  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  Stream<int> _getUrgentCount() {
    return _service.getFridgeItems().map((items) {
      final now = DateTime.now();
      return items.where((item) {
        final diff = item.expiryDate.difference(now).inDays;
        return diff <= 3 && diff >= 0;
      }).length;
    });
  }

  void _showExitOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  AppLocalizations.of(context)!.settingsAndExit,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'KidariFont'
                  )
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.blue),
                title: Text(AppLocalizations.of(context)!.logout, style: TextStyle(fontFamily: 'KidariFont')),
                subtitle: Text(AppLocalizations.of(context)!.returnToHome, style: TextStyle(fontFamily: 'KidariFont')),
                onTap: () { Navigator.pop(context); _processLogout(context); },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.delete_forever, color: Colors.red),
                title: Text(AppLocalizations.of(context)!.deleteFridge, style: TextStyle(fontFamily: 'KidariFont')),
                subtitle: Text(AppLocalizations.of(context)!.allDataDeletedPermanently, style: TextStyle(fontFamily: 'KidariFont')),
                onTap: () { Navigator.pop(context); _confirmDeleteFridge(context); },
              ),
            ],
          ),
        );
      },
    );
  }

  void _processLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    _service.logout();
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => EntranceScreen()), (route) => false);
  }

  Future<void> _confirmDeleteFridge(BuildContext mainContext) async {
    // 로그아웃과 삭제를 위해 필요한 정보를 미리 변수에 담아둡니다.
    final navigator = Navigator.of(mainContext);
    final messenger = ScaffoldMessenger.of(mainContext);
    final localizations = AppLocalizations.of(mainContext)!;

    showDialog(
      context: mainContext,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.confirmDelete, style: const TextStyle(color: Colors.red, fontFamily: 'KidariFont')),
        content: Text(localizations.deleteFridgeWarning, style: const TextStyle(fontFamily: 'KidariFont')),
        actions: [
          TextButton(
              child: Text(localizations.cancel, style: const TextStyle(fontFamily: 'KidariFont')),
              onPressed: () => Navigator.pop(dialogContext)
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text(localizations.deleteAndExit, style: const TextStyle(fontFamily: 'KidariFont')),
            onPressed: () async {
              // 1. 다이얼로그 닫기
              Navigator.pop(dialogContext);

              // 2. 냉장고 데이터 삭제 (로그아웃 전에 수행)
              await _service.deleteHousehold();

              // 3. 로그아웃 수행
              await FirebaseAuth.instance.signOut();

              // ★ [수정 핵심]
              // 로그아웃 후 context가 unmount 되었을 수 있으므로,
              // 미리 확보해둔 'navigator'를 사용하여 강제로 이동시킵니다.
              navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => EntranceScreen()),
                      (route) => false
              );

              // 스낵바는 최상단 메신저를 통해 띄웁니다.
              messenger.showSnackBar(
                  SnackBar(content: Text(localizations.fridgeDeleted), behavior: SnackBarBehavior.floating)
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/intro_basic.png'),
            fit: BoxFit.cover,
            //colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 226),
                  Text(
                      _fridgeName.isEmpty ? AppLocalizations.of(context)!.myFridge : _fridgeName,
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy01,
                          fontFamily: 'KidariFont'
                      )
                  ),
                  SizedBox(height: 138.5), //366이어야함

                  // 터치 효과가 적용된 냉장고
                  GestureDetector(
                    onTapDown: _onTapDown,
                    onTapUp: _onTapUp,
                    onTapCancel: _onTapCancel,
                    onTap: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => HomeScreen()));
                    },
                    child: AnimatedScale(
                      scale: _scale, // 변수 연결
                      duration: Duration(milliseconds: 100), // 0.1초 동안 부드럽게
                      curve: Curves.easeInOut, // 부드러운 움직임 곡선
                      child: Container(
                        decoration: BoxDecoration(
                        ),
                        child: Image.asset('assets/images/intro_fridge_white.png', width: 381.5, fit: BoxFit.contain),
                      ),
                    ),
                  ),

                  //SizedBox(height: 30),
                  //Text(AppLocalizations.of(context)!.touchFridgeToOpen, style: TextStyle(fontSize: 16, color: Colors.white70, fontFamily: 'KidariFont', shadows: [Shadow(blurRadius: 5, color: Colors.black45, offset: Offset(1, 1))])),
                ],
              ),
            ),

            // (포스트잇 및 버튼 코드는 기존과 동일)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              right: 60,
              child: StreamBuilder<int>(
                stream: _getUrgentCount(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == 0) return SizedBox();
                  return Transform.rotate(
                    angle: 0.25,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      decoration: BoxDecoration(
                          color: AppColors.navy01,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black38,
                                blurRadius: 8,
                                offset: Offset(4, 4)
                            )
                          ]),
                      child: Column(
                        children: [
                          Icon(Icons.push_pin, size: 20, color: AppColors.contrast),
                          SizedBox(height: 5),
                          Text(
                              AppLocalizations.of(context)!.expiringSoon, 
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 14, color: AppColors.appwhite,
                                  fontFamily: 'KidariFont')
                          ),
                          Text(
                              AppLocalizations.of(context)!.countItems(snapshot.data ?? 0),//"${snapshot.data}개",
                              style: TextStyle(
                                  color: AppColors.contrast,
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 18,
                                  fontFamily: 'KidariFont')
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 50,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                    color: AppColors.navy01,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5)
                    ]
                ),
                child: IconButton(
                  icon: Icon(Icons.exit_to_app, color: AppColors.contrast),
                  tooltip: AppLocalizations.of(context)!.exitOptions,
                  onPressed: () => _showExitOptions(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}