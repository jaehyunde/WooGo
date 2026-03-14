// lib/favorite_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fridge_service.dart';
import 'l10n/app_localizations.dart';

class FavoriteScreen extends StatelessWidget {
  final FridgeService _service = FridgeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.favorites)),
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
                  Icon(Icons.star_border, size: 60, color: Colors.grey[300]),
                  SizedBox(height: 10),
                  Text(AppLocalizations.of(context)!.noFavoriteItems, style: TextStyle(color: Colors.grey, fontFamily: 'KidariFont')),
                  Text(AppLocalizations.of(context)!.checkStarWhenAdding, style: TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'KidariFont')),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              String docId = docs[index].id;
              String name = data['name'];
              String category = data['category'];

              return ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.yellow[100], shape: BoxShape.circle),
                  child: Text("⭐", style: TextStyle(fontSize: 20)),
                ),
                title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'KidariFont')),
                subtitle: Text(category, style: TextStyle(fontFamily: 'KidariFont')),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    // 삭제 확인 다이얼로그
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(AppLocalizations.of(context)!.deleteFavorite, style: TextStyle(fontFamily: 'KidariFont')),
                        content: Text("'$name'을(를) 자주 쓰는 목록에서 지우시겠습니까?\n(냉장고에 있는 아이템의 별표도 해제됩니다)", style: TextStyle(fontFamily: 'KidariFont')),
                        actions: [
                          TextButton(child: Text("취소", style: TextStyle(color: Colors.grey)), onPressed: () => Navigator.pop(context)),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                            child: Text(AppLocalizations.of(context)!.delete),
                            onPressed: () {
                              // ★ [수정됨] 이름(name)도 같이 전달!
                              _service.removeFavorite(docId, name);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.deleted)));
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