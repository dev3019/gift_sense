import 'package:flutter/material.dart';
import 'package:gift_sense/gift_picker/models/search.dart';
import 'package:gift_sense/gift_picker/ui/widgets/search_item.dart';

class SearchList extends StatelessWidget {
  const SearchList({super.key, required this.searchItems});

  final List<GiftSearchItem> searchItems;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: searchItems.length,
      itemBuilder: (context, index) => SearchItem(gift: searchItems[index]),
    );
  }
}
