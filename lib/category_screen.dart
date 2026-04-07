import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fridge_service.dart';
import 'l10n/app_localizations.dart';
import 'utils.dart';
import 'thema/app_color.dart';

class CategorySettingsScreen extends StatefulWidget {
  @override
  _CategorySettingsScreenState createState() => _CategorySettingsScreenState();
}

class _CategorySettingsScreenState extends State<CategorySettingsScreen> {
  final _service = FridgeService();
  final _nameController = TextEditingController();
  final _daysController = TextEditingController(text: "7");

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
        Text(
            AppLocalizations.of(context)!.defaultExpiryDays,
            style: TextStyle(
                color: AppColors.navy01,
                fontSize: 12
            )
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8)
              ),
              child: IconButton(
                icon: Icon(Icons.remove, size: 20, color: AppColors.navy01,),
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
            TextField(
                controller: _nameController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.name)
            ),
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
        title: Text(
          AppLocalizations.of(context)!.manageCategories,
          style: TextStyle(
              color: AppColors.navy01
          ),
        ),
        iconTheme: IconThemeData(
          color: AppColors.navy01,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh), color: AppColors.navy01,
            tooltip: AppLocalizations.of(context)!.fillDefaultCategories,
            onPressed: () async {
              await _service.initializeDefaultCategories();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.refresh,
                        style: TextStyle(
                            color: AppColors.navy01
                        ),
                      )
                  )
              );
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
                // 1. leading: 이모지 문자열을 가져와서 원형 배경 위젯으로 만듭니다. ✅
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle
                  ),
                  child: Text(
                    getCategoryEmoji(categoryName), // utils.dart 함수 호출
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                title: Text(
                    translateCategory(categoryName, context),
                    style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'KidariFont', color: AppColors.navy01)
                ),

                // 3. subtitle: "기본 유통기한" 문구도 다국어 처리를 권장합니다.
                subtitle: Text(
                  "${AppLocalizations.of(context)!.defaultExpiryDays}: $defaultDays${AppLocalizations.of(context)!.day}",
                  style: TextStyle(fontFamily: 'KidariFont', color: AppColors.navy01),
                ),

                onTap: () {
                  _showEditDialog(docs[index].id, categoryName, defaultDays);
                },

                trailing: IconButton(
                  icon: Icon(Icons.delete, color: AppColors.navy01),
                  onPressed: () {
                    _service.deleteCategory(docs[index].id);
                    // 4. SnackBar 메시지도 다국어 대응 ✅
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              AppLocalizations.of(context)!.categoryDeletedWithName(categoryName),
                              style: const TextStyle(fontFamily: 'KidariFont')
                          )
                      ),
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