// lib/category_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fridge_service.dart';
import 'l10n/app_localizations.dart';

class CategorySettingsScreen extends StatefulWidget {
  @override
  _CategorySettingsScreenState createState() => _CategorySettingsScreenState();
}

class _CategorySettingsScreenState extends State<CategorySettingsScreen> {
  final _service = FridgeService();
  final _nameController = TextEditingController();
  final _daysController = TextEditingController(text: "7");

  // 카테고리 이름에 맞는 이모지 반환 함수

  Widget _getCategoryEmoji(String name) {
    String emoji;
    // 영어 대소문자 구분을 없애기 위해 소문자로 변환해서 검사
    String lowerName = name.toLowerCase();

    if (lowerName.contains('육류') || lowerName.contains('고기') || lowerName.contains('meat') || lowerName.contains('beef') || lowerName.contains('pork')) {
      emoji = '🥩';
    }
    // ★ [요청 3] 치즈 분리 (유제품보다 먼저 검사해야 함)
    else if (lowerName.contains('치즈') || lowerName.contains('cheese')) {
      emoji = '🧀';
    }
    else if (lowerName.contains('유제품') || lowerName.contains('우유') || lowerName.contains('dairy') || lowerName.contains('milk')) {
      emoji = '🥛';
    }
    else if (lowerName.contains('야채') || lowerName.contains('채소') || lowerName.contains('vegetable') || lowerName.contains('veggie')) {
      emoji = '🥦';
    }
    // ★ [요청 1] '사과' 삭제, 영어 추가
    else if (lowerName.contains('과일') || lowerName.contains('fruit')) {
      emoji = '🍎';
    }
    else if (lowerName.contains('냉동') || lowerName.contains('아이스크림') || lowerName.contains('frozen') || lowerName.contains('ice')) {
      emoji = '❄️';
    }
    // ★ [요청 2] '주스', '물' 삭제, 영어 추가
    else if (lowerName.contains('음료') || lowerName.contains('beverage') || lowerName.contains('drink')) {
      emoji = '🥤';
    }
    // ★ [요청 4] 기타 카테고리 영어 추가
    else if (lowerName.contains('빵') || lowerName.contains('떡') || lowerName.contains('베이커리') || lowerName.contains('bread') || lowerName.contains('bakery')) {
      emoji = '🍞';
    }
    else if (lowerName.contains('생선') || lowerName.contains('해산물') || lowerName.contains('fish') || lowerName.contains('seafood')) {
      emoji = '🐟';
    }
    else if (lowerName.contains('소스') || lowerName.contains('양념') || lowerName.contains('sauce') || lowerName.contains('condiment')) {
      emoji = '🥫';
    }
    else if (lowerName.contains('즉석') || lowerName.contains('라면') || lowerName.contains('instant') || lowerName.contains('noodle')) {
      emoji = '🍜';
    }
    else {
      emoji = '🏷️'; // 매칭되는 게 없으면 기본 태그
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        shape: BoxShape.circle,
      ),
      child: Text(emoji, style: TextStyle(fontSize: 24)),
    );
  }

  // 유통기한 감소
  void _decreaseDays() {
    int current = int.tryParse(_daysController.text) ?? 0;
    if (current > 1) {
      _daysController.text = (current - 1).toString();
    }
  }

  // 유통기한 증가
  void _increaseDays() {
    int current = int.tryParse(_daysController.text) ?? 0;
    _daysController.text = (current + 1).toString();
  }

  // 숫자 조절 입력창 위젯
  Widget _buildDaysInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.defaultExpiryDays, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
        SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
              child: IconButton(
                icon: Icon(Icons.remove, size: 20),
                onPressed: _decreaseDays,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: TextField(
                  controller: _daysController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    border: UnderlineInputBorder(),
                    hintText: AppLocalizations.of(context)!.days,
                  ),
                ),
              ),
            ),
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
              child: IconButton(
                icon: Icon(Icons.add, size: 20),
                onPressed: _increaseDays,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 1. 추가 다이얼로그
  void _showAddDialog() {
    _nameController.clear();
    _daysController.text = "7";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addNewCategory),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.nameExampleSnack)
            ),
            SizedBox(height: 20),
            _buildDaysInput(),
          ],
        ),
        actions: [
          TextButton(child: Text(AppLocalizations.of(context)!.cancel), onPressed: () => Navigator.pop(context)),
          ElevatedButton(
            child: Text(AppLocalizations.of(context)!.add),
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                String newName = _nameController.text;
                int days = int.tryParse(_daysController.text) ?? 7;

                _service.addCategory(newName, days);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("'$newName' 카테고리를 추가했습니다.")));
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  // 2. 수정 다이얼로그
  void _showEditDialog(String docId, String currentName, int currentDays) {
    _nameController.text = currentName;
    _daysController.text = currentDays.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.editCategory),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: "이름")),
            SizedBox(height: 20),
            _buildDaysInput(),
          ],
        ),
        actions: [
          TextButton(child: Text(AppLocalizations.of(context)!.cancel), onPressed: () => Navigator.pop(context)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: Text(AppLocalizations.of(context)!.editComplete),
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                int days = int.tryParse(_daysController.text) ?? 7;

                _service.updateCategory(docId, _nameController.text, days);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.updated)));
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.manageCategories),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context)!.fillDefaultCategories,
            onPressed: () async {
              await _service.initializeDefaultCategories();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.refresh)));
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.getCategoriesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)!.addDefaultCategoriesHint, textAlign: TextAlign.center),
            );
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              String categoryName = data['name'];
              int defaultDays = data['defaultDays'];

              return ListTile(
                // ★ [수정] 이모지 함수 적용
                leading: _getCategoryEmoji(categoryName),

                title: Text(categoryName, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("기본 유통기한: $defaultDays일"),
                onTap: () {
                  _showEditDialog(docs[index].id, categoryName, defaultDays);
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.grey[400]),
                  onPressed: () {
                    _service.deleteCategory(docs[index].id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("'$categoryName' 카테고리를 삭제했습니다.")),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _showAddDialog,
      ),
    );
  }
}