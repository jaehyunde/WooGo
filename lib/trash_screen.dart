// lib/trash_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fridge_service.dart';
import 'item_model.dart';
import 'l10n/app_localizations.dart';

class TrashScreen extends StatefulWidget {
  @override
  _TrashScreenState createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final FridgeService _service = FridgeService();

  // ★ 선택 모드 관련 변수
  bool _isSelectionMode = false;
  Set<String> _selectedIds = {}; // 선택된 아이템 ID들을 담는 통

  // 선택 모드 끄기/켜기
  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedIds.clear(); // 모드 바뀔 땐 선택 초기화
    });
  }

  // 아이템 선택/해제 토글
  void _toggleItemSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        // 다 끄면 선택 모드 종료
        if (_selectedIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  // ★ [수정됨] 일괄 삭제 실행 (선택된 것들 영구 삭제)
  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
        Text(AppLocalizations.of(context)!.permanentDelete,
            style: TextStyle(fontFamily: 'KidariFont', fontWeight: FontWeight.bold)),
        content:
        Text(
            AppLocalizations.of(context)!.confirmDeleteSelected(_selectedIds.length),//"선택한 ${_selectedIds.length}개를 완전히 삭제하시겠습니까?\n이 작업은 복구할 수 없습니다.",
            style: TextStyle(fontFamily: 'KidariFont')),
        actions: [
          TextButton(
              child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: TextStyle(color: Colors.grey, fontFamily: 'KidariFont')),
              onPressed: () => Navigator.pop(context, false)
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.delete_forever, size: 18),
            label:
            Text(
                AppLocalizations.of(context)!.delete,
                style: TextStyle(fontFamily: 'KidariFont')),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // FridgeService에 있는 deleteMultipleItems 사용
      await _service.deleteMultipleItems(_selectedIds.toList());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  AppLocalizations.of(context)!.permanentDeleteCompleted(_selectedIds.length) ,//"${_selectedIds.length}개가 영구 삭제되었습니다 🗑️",
                  style: TextStyle(fontFamily: 'KidariFont')),
              behavior: SnackBarBehavior.floating));

      setState(() {
        _isSelectionMode = false;
        _selectedIds.clear();
      });
    }
  }

  // ★ [수정됨] 일괄 복구 실행 (선택된 것들을 다시 냉장고로)
  Future<void> _restoreSelected() async {
    if (_selectedIds.isEmpty) return;

    int count = _selectedIds.length;
    // FridgeService에 있는 restoreMultipleItems 사용
    await _service.restoreMultipleItems(_selectedIds.toList());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:
        Text(
            AppLocalizations.of(context)!.restoreCompleted(count),//"$count개 복구 완료! 냉장고를 확인하세요 ♻️",
            style: TextStyle(fontFamily: 'KidariFont')),
            behavior: SnackBarBehavior.floating));

    setState(() {
      _isSelectionMode = false;
      _selectedIds.clear();
    });
  }

  // ★ [신규] 휴지통 전체 비우기 기능 (앱바 우측 버튼용)
  Future<void> _emptyTrash(List<QueryDocumentSnapshot> allDocs) async {
    if (allDocs.isEmpty) return;

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.emptyTrash,
            style: TextStyle(
                fontFamily: 'KidariFont', fontWeight: FontWeight.bold)
        ),
        content: Text(
            AppLocalizations.of(context)!.confirmEmptyTrash(allDocs.length),//"휴지통에 있는 모든 항목(${allDocs.length}개)을 영구 삭제하시겠습니까?",
            style: TextStyle(fontFamily: 'KidariFont')
        ),
        actions: [
          TextButton(child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: Colors.grey, fontFamily: 'KidariFont')), onPressed: () => Navigator.pop(context, false)),
          ElevatedButton.icon(
            icon: Icon(Icons.delete_sweep, size: 18),
            label: Text(
                AppLocalizations.of(context)!.emptyAll,
                style: TextStyle(fontFamily: 'KidariFont')),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      List<String> allIds = allDocs.map((doc) => doc.id).toList();
      await _service.deleteMultipleItems(allIds);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  AppLocalizations.of(context)!.trashCleaned,
                  style: TextStyle(fontFamily: 'KidariFont')
              ),
              behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text(
            AppLocalizations.of(context)!.selectedCount(_selectedIds.length),//"${_selectedIds.length}개 선택됨",
            style: TextStyle(fontFamily: 'KidariFont', fontSize: 18, fontWeight: FontWeight.bold))
            : Text(AppLocalizations.of(context)!.trashTitle, style: TextStyle(fontFamily: 'KidariFont', fontWeight: FontWeight.bold)),
        leading: _isSelectionMode
            ? IconButton(icon: Icon(Icons.close), onPressed: _toggleSelectionMode)
            : BackButton(),
        // 선택 모드일 때와 아닐 때 앱바 우측 액션 버튼이 바뀜
        actions: _isSelectionMode
            ? [
          IconButton(
            icon: Icon(Icons.restore, color: Colors.green),
            tooltip: AppLocalizations.of(context)!.restoreSelected,
            onPressed: _restoreSelected,
          ),
          IconButton(
            icon: Icon(Icons.delete_forever, color: Colors.redAccent),
            tooltip: AppLocalizations.of(context)!.deleteSelectedPermanently,
            onPressed: _deleteSelected,
          ),
          SizedBox(width: 10),
        ]
            : [
          // 데이터가 있을 때만 전체 비우기 버튼 활성화를 위해 StreamBuilder 안에서 데이터를 받아와야 하지만,
          // UI 편의상 앱바에 고정하고 비어있을 땐 안내 스낵바를 띄웁니다.
          StreamBuilder<QuerySnapshot>(
              stream: _service.getTrashedItemsStream(),
              builder: (context, snapshot) {
                bool isEmpty = !snapshot.hasData || snapshot.data!.docs.isEmpty;
                return IconButton(
                  icon: Icon(Icons.delete_sweep, color: isEmpty ? Colors.grey : Colors.redAccent),
                  tooltip: AppLocalizations.of(context)!.emptyTrash,
                  onPressed: () {
                    if (isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  AppLocalizations.of(context)!.trashEmpty,
                                  style: TextStyle(fontFamily: 'KidariFont')),
                              behavior: SnackBarBehavior.floating));
                    } else {
                      _emptyTrash(snapshot.data!.docs);
                    }
                  },
                );
              }
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.getTrashedItemsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(
              child: Text(AppLocalizations.of(context)!.errorOccurred));
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, size: 60, color: Colors.grey[300]),
                  SizedBox(height: 10),
                  Text(
                      AppLocalizations.of(context)!.trashEmpty,
                      style: TextStyle(color: Colors.grey, fontSize: 18, fontFamily: 'KidariFont')),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(10),
            itemCount: docs.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
            itemBuilder: (context, index) {
              var item = FridgeItem.fromSnapshot(docs[index]);
              bool isSelected = _selectedIds.contains(item.id);

              return ListTile(
                onLongPress: () {
                  if (!_isSelectionMode) {
                    _toggleSelectionMode();
                    _toggleItemSelection(item.id!);
                  }
                },
                onTap: () {
                  if (_isSelectionMode) {
                    _toggleItemSelection(item.id!);
                  } else {
                    _showIndividualAction(context, item);
                  }
                },
                tileColor: isSelected ? Colors.blue.withOpacity(0.1) : null,
                leading: _isSelectionMode
                    ? Checkbox(
                  value: isSelected,
                  activeColor: Colors.blue,
                  onChanged: (val) => _toggleItemSelection(item.id!),
                )
                    : Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
                  child: Text("", style: TextStyle(fontSize: 15)),
                ),
                title: Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'KidariFont',
                      color: Colors.black87, // ★ [요청 반영] 회색 글씨 원래대로 (검정)
                    )
                ),
                subtitle: Text(
                    AppLocalizations.of(context)!.discardedItemInfo(item.quantity, DateFormat('yy.MM.dd').format(item.expiryDate)),//"버린 개수: ${item.quantity}개  |  유통기한: ${DateFormat('yy.MM.dd').format(item.expiryDate)}",
                    style: TextStyle(fontFamily: 'KidariFont', color: Colors.blueGrey, fontSize: 13)
                ),
              );
            },
          );
        },
      ),
    );
  }

  // (선택 모드가 아닐 때) 개별 아이템 클릭 시 팝업
  void _showIndividualAction(BuildContext context, FridgeItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item.name, style: TextStyle(fontFamily: 'KidariFont', fontWeight: FontWeight.bold)),
        content: Text(
            AppLocalizations.of(context)!.whatToDoWithItem,
            style: TextStyle(fontFamily: 'KidariFont')),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
              child: Text(AppLocalizations.of(context)!.cancel,
                  style: TextStyle(color: Colors.grey, fontFamily: 'KidariFont')),
              onPressed: () => Navigator.pop(dialogContext)
          ),
          Wrap(
            alignment: WrapAlignment.end, // 오른쪽 정렬
            spacing: 8, // 가로 간격
            runSpacing: 8, // 줄바꿈 시 세로 간격
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.delete_forever, size: 16),
                label: Text(AppLocalizations.of(context)!.permanentDelete,
                    style: const TextStyle(fontFamily: 'KidariFont')),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 10)),
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await _service.deleteItemPermanently(item.id!); // 영구 삭제
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              AppLocalizations.of(context)!.permanentDeleted,
                              style: TextStyle(fontFamily: 'KidariFont')),
                          behavior: SnackBarBehavior.floating));
                },
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.restore, size: 16),
                label: Text(AppLocalizations.of(context)!.restore, style: TextStyle(fontFamily: 'KidariFont')),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 10)),
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await _service.updateItemStatus(item.id!, 'normal'); // 복구
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(
                          AppLocalizations.of(context)!.restoredToFridge,
                          style: TextStyle(fontFamily: 'KidariFont')),
                          behavior: SnackBarBehavior.floating));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}