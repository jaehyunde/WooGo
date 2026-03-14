import 'package:cloud_firestore/cloud_firestore.dart';

class FridgeItem {
  final String id; // Firestore 문서 ID
  final String name;
  final String category; // 'dairy', 'meat' 등
  final String storageLocation; // 'fridge', 'freezer'
  final int quantity;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final String status;
  final bool isFavorite;

  FridgeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.storageLocation,
    required this.quantity,
    required this.purchaseDate,
    required this.expiryDate,
    this.status = 'normal',
    this.isFavorite = false,
  });

  // DB에서 가져올 때 (JSON -> Object)
  factory FridgeItem.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FridgeItem(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? 'etc',
      storageLocation: data['storageLocation'] ?? 'fridge',
      quantity: data['quantity'] ?? 1,
      // Firestore Timestamp를 Dart DateTime으로 변환
      purchaseDate: (data['purchaseDate'] as Timestamp).toDate(),
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'normal',
      isFavorite: data['isFavorite'] ?? false,
    );
  }

  // DB에 저장할 때 (Object -> JSON)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'storageLocation': storageLocation,
      'quantity': quantity,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'expiryDate': Timestamp.fromDate(expiryDate),
      'status': status,
      'isFavorite': isFavorite,
      'createdAt': FieldValue.serverTimestamp(), // 정렬용
    };
  }
}