import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:hive/hive.dart';

// ignore: must_be_immutable
class Food extends Equatable {
  final String? category;
  final String? categoryName;
  final String name;
  final double price;
  final DateTime createdAt;
  final String? description;
  final bool available;

  // for cart
  int quantity = 0;

  // id is the document id
  String? id;

  Food({
    this.category,
    this.categoryName,
    required this.name,
    required this.price,
    required this.createdAt,
    this.description,
    required this.quantity,
    this.available = true,
  });

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      category: map['category'] as String?,
      categoryName: map['categoryName'] as String?,
      name: map['name'],
      price: (map['price'] ?? 0) * 1.0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: map['description'],
      quantity: map['quantity'] ?? 0,
      available: map['available'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'categoryName': categoryName,
      'name': name,
      'price': price,
      'createdAt': Timestamp.fromDate(createdAt),
      'description': description ?? '',
      'quantity': quantity,
      'available': available,
    };
  }

  // food is favorite
  bool get isFavorite {
    final box = Hive.box('myBox');
    final favorites = box.get('favoriteFoods') as List<dynamic>?;
    if (favorites == null || favorites.isEmpty) return false;
    return favorites.contains(id);
  }

  @override
  List<Object?> get props => [name, createdAt, id];
}
