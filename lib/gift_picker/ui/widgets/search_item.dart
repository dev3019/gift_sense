import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gift_sense/gift_picker/models/search.dart';

class SearchItem extends StatelessWidget {
  const SearchItem({super.key, required this.gift});
  final GiftSearchItem gift;

  final TextStyle _subtextStyle = const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(gift.url);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(gift.title),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      gift.provider.name.toUpperCase(),
                      style: _subtextStyle,
                    ),
                    SizedBox(width: 8),
                    Text(gift.price.toUpperCase(), style: _subtextStyle),
                    SizedBox(width: 8),
                    Text(
                      'Reviews: ${gift.ratings} (${gift.reviews.toString()})',
                      style: _subtextStyle,
                    ),
                  ],
                ),
                IconButton.outlined(
                  onPressed: _launchUrl,
                  icon: Icon(Icons.link),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
