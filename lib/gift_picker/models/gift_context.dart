import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

enum Sex { male, female }
enum GiftCategory { books, home, clothing, entertainment }

const giftCategoryIcons = {
  GiftCategory.books: Icons.book,
  GiftCategory.home: Icons.home,
  GiftCategory.clothing: Icons.checkroom,
  GiftCategory.entertainment: Icons.movie,
};

class GiftContext {
  GiftContext({
    required this.description,
    required this.category,
    required this.sex,
    required this.age,
  
  }): id = uuid.v4();

  final String id;
  final String description;
  final GiftCategory category;
  final Sex sex;
  final int age;
}
