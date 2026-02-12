import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:gift_sense/gift_picker/adapters/providers/base_provider.dart';
import 'package:gift_sense/gift_picker/models/search.dart';
import 'package:gift_sense/core/supabase_service.dart';

class AmazonProvider implements BaseProvider {
  static final _randomizer = Random();

  @override
  GiftSearchProvider get name => GiftSearchProvider.amazon;

  @override
  Future<List<GiftSearchItem>> search(List<String> ideas) async {
    try {
      if (ideas.isEmpty) return [];
      int index = (_randomizer.nextInt(ideas.length));

      final idea = ideas[index].replaceAll(' ', '+');
      final responseData = await callApi(idea);
      return parseResponse(responseData);
    } catch (e) {
      debugPrint('AmazonProvider.search failed: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> callApi(String query) async {
    try {
      final response = await SupabaseService.client.functions.invoke(
        'serp-amazon-search',
        body: {'query': query},
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      debugPrint('AmazonProvider.callApi: unexpected response type: ${response.data.runtimeType}');
      return {};
    } catch (e) {
      debugPrint('AmazonProvider.callApi failed: $e');
      return {};
    }
  }

  List<GiftSearchItem> parseResponse(Map<String, dynamic> responseData) {
    try {
      if (responseData['success'] == false) return [];
      final results = responseData['results'];
      if (results is! List) return [];
      final links = results;
    // final links = [
    //   {
    //     "position": 1,
    //     "asin": "B0DJFZ48LV",
    //     "title":
    //         "DIABLO IV: THE OFFICIAL COMPREHENSIVE GAME GUIDE - Full Walkthrough, Secrets and Collectibles - ENCYCLOPEDIA",
    //     "link":
    //         "https://www.amazon.ca/DIABLO-COMPREHENSIVE-Walkthrough-Collectibles-ENCYCLOPEDIA/dp/B0DJFZ48LV/ref=mp_s_a_1_1?dib=eyJ2IjoiMSJ9.-NKC4JNICLCdHsBqcv-wfzPkI4MEn5P9x1StYwyNjdlERqrfEXRguliJ4RyAH2qT_zhcr_b-rcd_LNFHDMghn_z0rAksm1ACmL_vvEbaFqmkjvEUcPaxmskCHp6lVqATvhxwPI9yMiqStI_KGF5kQveHrfmKGPN4SzxJl7FPIxb5FVsXMWXgOYpYVCkpAVB-UjND0j6IBM-zxpwre1kg-g.qvYqix1OyS-NS53HE_iDxM_MEXDfBR8WpmqkEd7y1gg&dib_tag=se&keywords=Diablo%2BIV%2BBooks&qid=1768238645&sr=8-1",
    //     "link_clean":
    //         "https://www.amazon.ca/DIABLO-COMPREHENSIVE-Walkthrough-Collectibles-ENCYCLOPEDIA/dp/B0DJFZ48LV/",
    //     "thumbnail":
    //         "https://m.media-amazon.com/images/I/715vZx8BOCL._AC_SX148_SY213_QL70_.jpg",
    //     "rating": 3.5,
    //     "reviews": 12,
    //     "price": "\$67.62",
    //     "extracted_price": 67.62,
    //     "delivery": [
    //       "FREE delivery Tue, Jan 20",
    //       "Or fastest delivery Sat, Jan 17",
    //     ],
    //   },
    //   {
    //     "position": 2,
    //     "asin": "0425284891",
    //     "title": "The Lost Horadrim (Diablo IV)",
    //     "link":
    //         "https://www.amazon.ca/Lost-Horadrim-Diablo-IV/dp/0425284891/ref=mp_s_a_1_2?dib=eyJ2IjoiMSJ9.-NKC4JNICLCdHsBqcv-wfzPkI4MEn5P9x1StYwyNjdlERqrfEXRguliJ4RyAH2qT_zhcr_b-rcd_LNFHDMghn_z0rAksm1ACmL_vvEbaFqmkjvEUcPaxmskCHp6lVqATvhxwPI9yMiqStI_KGF5kQveHrfmKGPN4SzxJl7FPIxb5FVsXMWXgOYpYVCkpAVB-UjND0j6IBM-zxpwre1kg-g.qvYqix1OyS-NS53HE_iDxM_MEXDfBR8WpmqkEd7y1gg&dib_tag=se&keywords=Diablo%2BIV%2BBooks&qid=1768238645&sr=8-2",
    //     "link_clean":
    //         "https://www.amazon.ca/Lost-Horadrim-Diablo-IV/dp/0425284891/",
    //     "thumbnail":
    //         "https://m.media-amazon.com/images/I/81seV03IweL._AC_SX148_SY213_QL70_.jpg",
    //     "price": "\$41.99",
    //     "extracted_price": 41.99,
    //     "price_unit": "Print List Price:",
    //     "old_price": "\$25.70",
    //     "extracted_old_price": 25.7,
    //     "prime": true,
    //     "delivery": [
    //       "FREE delivery",
    //       "This title will be released on April 21, 2026.",
    //     ],
    //   },
    //   {
    //     "position": 3,
    //     "asin": "B0DL62G7GM",
    //     "title":
    //         "DIABLO IV Vessel of Hatred - THE COMPREHENSIVE GAME GUIDE: FULL Walkthrough, Secrets and Collectibles!",
    //     "link":
    //         "https://www.amazon.ca/DIABLO-Vessel-Hatred-COMPREHENSIVE-Collectibles/dp/B0DL62G7GM/ref=mp_s_a_1_3?dib=eyJ2IjoiMSJ9.-NKC4JNICLCdHsBqcv-wfzPkI4MEn5P9x1StYwyNjdlERqrfEXRguliJ4RyAH2qT_zhcr_b-rcd_LNFHDMghn_z0rAksm1ACmL_vvEbaFqmkjvEUcPaxmskCHp6lVqATvhxwPI9yMiqStI_KGF5kQveHrfmKGPN4SzxJl7FPIxb5FVsXMWXgOYpYVCkpAVB-UjND0j6IBM-zxpwre1kg-g.qvYqix1OyS-NS53HE_iDxM_MEXDfBR8WpmqkEd7y1gg&dib_tag=se&keywords=Diablo%2BIV%2BBooks&qid=1768238645&sr=8-3",
    //     "link_clean":
    //         "https://www.amazon.ca/DIABLO-Vessel-Hatred-COMPREHENSIVE-Collectibles/dp/B0DL62G7GM/",
    //     "thumbnail":
    //         "https://m.media-amazon.com/images/I/81gBTvp4pRL._AC_SX148_SY213_QL70_.jpg",
    //     "rating": 3.5,
    //     "reviews": 12,
    //     "price": "\$22.15",
    //     "extracted_price": 22.15,
    //     "delivery": [
    //       "FREE delivery Tue, Jan 20 on your first order",
    //       "Or fastest delivery Sat, Jan 17",
    //     ],
    //   },
    //   {
    //     "position": 4,
    //     "asin": "1956916644",
    //     "title": "Shadows of Sanctuary: A Diablo Short Story Collection",
    //     "link":
    //         "https://www.amazon.ca/Shadows-Sanctuary-Diablo-Short-Collection/dp/1956916644/ref=mp_s_a_1_4?dib=eyJ2IjoiMSJ9.-NKC4JNICLCdHsBqcv-wfzPkI4MEn5P9x1StYwyNjdlERqrfEXRguliJ4RyAH2qT_zhcr_b-rcd_LNFHDMghn_z0rAksm1ACmL_vvEbaFqmkjvEUcPaxmskCHp6lVqATvhxwPI9yMiqStI_KGF5kQveHrfmKGPN4SzxJl7FPIxb5FVsXMWXgOYpYVCkpAVB-UjND0j6IBM-zxpwre1kg-g.qvYqix1OyS-NS53HE_iDxM_MEXDfBR8WpmqkEd7y1gg&dib_tag=se&keywords=Diablo%2BIV%2BBooks&qid=1768238645&sr=8-4",
    //     "link_clean":
    //         "https://www.amazon.ca/Shadows-Sanctuary-Diablo-Short-Collection/dp/1956916644/",
    //     "thumbnail":
    //         "https://m.media-amazon.com/images/I/81AA+TRwWML._AC_SX148_SY213_QL70_.jpg",
    //     "rating": 5,
    //     "reviews": 7,
    //     "price": "\$30.95",
    //     "extracted_price": 30.95,
    //     "delivery": [
    //       "FREE delivery Fri, Jan 16 on your first order",
    //       "Or fastest delivery Tomorrow, Jan 13",
    //     ],
    //     "stock": "Only 4 left in stock (more on the way).",
    //   },
    //   {
    //     "position": 5,
    //     "asin": "B0DZZJ6VNY",
    //     "title": "2026 Diablo 4 Wall Calendar",
    //     "link":
    //         "https://www.amazon.ca/2026-Diablo-4-Wall-Calendar/dp/B0DZZJ6VNY/ref=mp_s_a_1_5?dib=eyJ2IjoiMSJ9.-NKC4JNICLCdHsBqcv-wfzPkI4MEn5P9x1StYwyNjdlERqrfEXRguliJ4RyAH2qT_zhcr_b-rcd_LNFHDMghn_z0rAksm1ACmL_vvEbaFqmkjvEUcPaxmskCHp6lVqATvhxwPI9yMiqStI_KGF5kQveHrfmKGPN4SzxJl7FPIxb5FVsXMWXgOYpYVCkpAVB-UjND0j6IBM-zxpwre1kg-g.qvYqix1OyS-NS53HE_iDxM_MEXDfBR8WpmqkEd7y1gg&dib_tag=se&keywords=Diablo%2BIV%2BBooks&qid=1768238645&sr=8-5",
    //     "link_clean":
    //         "https://www.amazon.ca/2026-Diablo-4-Wall-Calendar/dp/B0DZZJ6VNY/",
    //     "thumbnail":
    //         "https://m.media-amazon.com/images/I/71F8mF6Lc+L._AC_SX148_SY213_QL70_.jpg",
    //     "rating": 3.4,
    //     "reviews": 3,
    //     "price": "\$18.39",
    //     "extracted_price": 18.39,
    //     "delivery": [
    //       "FREE delivery Fri, Jan 16 on your first order",
    //       "Or fastest delivery Wed, Jan 14",
    //     ],
    //   },
    // ];

      return links
          .map((link) {
            final title = (link['title'] ?? link['brand'] ?? '').toString();
            final price = (link['price'] ?? 'N/A').toString();
            if (title.isEmpty || price == 'N/A') {
              return null;
            }
            return GiftSearchItem(
              title: title,
              trimmedTitle: _trimTitle(title),
              provider: name,
              url: (link['link_clean']).toString(),
              price: price,
              ratings: (link['rating'] ?? '0').toString(),
              reviews: link['reviews'] ?? 0,
            );
          })
          .nonNulls
          .toList();
    } catch (e) {
      debugPrint('AmazonProvider.parseResponse failed: $e');
      return [];
    }
  }

  String _trimTitle(String title) {
    if (title.length > 200) {
      return '${title.substring(0, 197)}...';
    }
    return title;
  }
}
