import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fridge_service.dart';
import 'l10n/app_localizations.dart';
import 'thema/app_color.dart';
import 'utils.dart';

class FavoriteScreen extends StatelessWidget {
  final FridgeService _service = FridgeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy01,
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.contrast),
        title: Text(AppLocalizations.of(context)!.favorites, style: TextStyle(color: AppColors.contrast, fontWeight: FontWeight.bold),),
        backgroundColor: AppColors.navy01,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.getFavoritesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text(AppLocalizations.of(context)!.errorOccurred));
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 60, color: AppColors.appwhite),
                  SizedBox(height: 10),
                  Text(AppLocalizations.of(context)!.noFavoriteItems, style: TextStyle(color: AppColors.appwhite, fontFamily: 'KidariFont')),
                  Text(AppLocalizations.of(context)!.checkStarWhenAdding, style: TextStyle(color: AppColors.appwhite, fontSize: 12, fontFamily: 'KidariFont')),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (context, index) => Divider(color: AppColors.appwhite.withOpacity(0.2)), // 구분선 색상 살짝 추가
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              String docId = docs[index].id;
              String name = data['name'];
              String category = data['category']; // 이미 선언되어 있음 ✅

              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1), // 노란색 대신 배경과 어울리는 반투명 흰색 추천 ✅
                    shape: BoxShape.circle,
                  ),
                  // 1. 별표 대신 카테고리에 맞는 이모지를 출력합니다. ✅
                  child: Text(
                      getCategoryEmoji(category),
                      style: const TextStyle(fontSize: 22)
                  ),
                ),
                title: Text(
                    name,
                    style: TextStyle(
                        color: AppColors.contrast,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'KidariFont'
                    )
                ),
                subtitle: Text(
                    translateCategory(category, context), // 카테고리명도 번역 함수가 있다면 적용 추천 ✅
                    style: TextStyle(
                        fontFamily: 'KidariFont',
                        color: AppColors.appwhite.withOpacity(0.8)
                    )
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () {
                    // 삭제 확인 다이얼로그
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.navy01, // 다이얼로그 배경색 통일
                        title: Text(
                            AppLocalizations.of(context)!.deleteFavorite,
                            style: TextStyle(fontFamily: 'KidariFont', color: AppColors.contrast)
                        ),
                        content: Text(
                            AppLocalizations.of(context)!.deleteFavoriteConfirm(name),//"'$name'을(를) 자주 쓰는 목록에서 지우시겠습니까?\n(냉장고에 있는 아이템의 별표도 해제됩니다)",
                            style: TextStyle(fontFamily: 'KidariFont', color: AppColors.appwhite)
                        ),
                        actions: [
                          TextButton(
                              child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: Colors.grey)),
                              onPressed: () => Navigator.pop(context)
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white
                            ),
                            child: Text(AppLocalizations.of(context)!.delete),
                            onPressed: () {
                              _service.removeFavorite(docId, name);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AppLocalizations.of(context)!.deleted))
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}