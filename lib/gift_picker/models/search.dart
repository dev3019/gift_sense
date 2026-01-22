
import 'package:gift_sense/gift_picker/models/gift_context.dart';

enum GiftSearchProvider { amazon }

class GiftSearchRequest {
  const GiftSearchRequest({
    required this.description,
    required this.category,
    required this.sex,
    required this.age,
  });

  final String description;
  final GiftCategory category;
  final Sex sex;
  final int age;
}

class GiftSearchResponse {
  const GiftSearchResponse({required this.items});
  final List<GiftSearchItem> items;
}

class GiftSearchItem {
  const GiftSearchItem({
    required this.title,
    required this.trimmedTitle,
    required this.provider,
    required this.url,
    required this.price,
    this.ratings = '0',
    this.reviews = 0,
  });

  final String title;
  final String trimmedTitle;
  final GiftSearchProvider provider;
  final String url;
  final String price;
  final String ratings;
  final int reviews;
}
