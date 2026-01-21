import 'package:gift_sense/gift_picker/models/search.dart';

abstract class BaseProvider {
  GiftSearchProvider get name;
  Future<List<GiftSearchItem>> search(List<String> ideas);
}
