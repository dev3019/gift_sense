import 'package:flutter/material.dart';
import 'package:gift_sense/gift_picker/models/gift_context.dart';

class GiftIdea extends StatelessWidget {
  const GiftIdea({super.key, required this.idea});
  final GiftContext idea;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 64),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(idea.category.name.toUpperCase()),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(idea.sex.name.toString().toUpperCase().substring(0, 1)),
                SizedBox(width: 16),
                Text(idea.age.toString()),
                SizedBox(width: 16),
                Icon(giftCategoryIcons[idea.category]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
