import 'package:flutter/material.dart';
import 'package:gift_sense/gift_picker/adapters/ai/gemini_adapter.dart';
import 'package:gift_sense/gift_picker/adapters/providers/amazon_provider.dart';
import 'package:gift_sense/gift_picker/models/gift_context.dart';
import 'package:gift_sense/gift_picker/models/search.dart';
import 'package:gift_sense/gift_picker/orchestrator/gift_search_orchestrator.dart';
import 'package:gift_sense/gift_picker/ui/widgets/gift_ideas_list.dart';
import 'package:gift_sense/gift_picker/ui/widgets/search_list.dart';

class GiftPickerApp extends StatefulWidget {
  const GiftPickerApp({super.key});
  @override
  State<GiftPickerApp> createState() => _GiftPickerAppState();
}

class _GiftPickerAppState extends State<GiftPickerApp> {
  final List<GiftContext> _giftIdeas = [
    GiftContext(
      description: 'Test-1',
      category: GiftCategory.books,
      sex: Sex.male,
      age: 22,
    ),
    GiftContext(
      description: 'Test-2',
      category: GiftCategory.clothing,
      sex: Sex.male,
      age: 22,
    ),
    GiftContext(
      description: 'Test-3',
      category: GiftCategory.home,
      sex: Sex.female,
      age: 50,
    ),
    GiftContext(
      description: 'Test-4',
      category: GiftCategory.entertainment,
      sex: Sex.male,
      age: 12,
    ),
    GiftContext(
      description: 'Test-1',
      category: GiftCategory.books,
      sex: Sex.male,
      age: 22,
    ),
    GiftContext(
      description: 'Test-2',
      category: GiftCategory.clothing,
      sex: Sex.male,
      age: 22,
    ),
    GiftContext(
      description: 'Test-3',
      category: GiftCategory.home,
      sex: Sex.female,
      age: 50,
    ),
    GiftContext(
      description: 'Test-4',
      category: GiftCategory.entertainment,
      sex: Sex.male,
      age: 12,
    ),
    GiftContext(
      description: 'Test-1',
      category: GiftCategory.books,
      sex: Sex.male,
      age: 22,
    ),
    GiftContext(
      description: 'Test-2',
      category: GiftCategory.clothing,
      sex: Sex.male,
      age: 22,
    ),
    GiftContext(
      description: 'Test-3',
      category: GiftCategory.home,
      sex: Sex.female,
      age: 50,
    ),
    GiftContext(
      description: 'Test-4',
      category: GiftCategory.entertainment,
      sex: Sex.male,
      age: 12,
    ),
  ];
  final _giftContextController = TextEditingController();
  final _ageTextController = TextEditingController();
  Sex? _selectedSex;
  GiftCategory? _selectedCategory;
  bool _isLoading = false;
  GiftSearchResponse? _searchResponse;

  void _openGiftOptionsOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_searchResponse != null && _searchResponse!.items.isNotEmpty
                ? SearchList(searchItems: _searchResponse!.items)
                : const Center(child: Text('No results'))),
    );
  }

  void _validateInput() async {
    final enteredAge = int.tryParse(_ageTextController.text);
    final validAge = enteredAge != null && enteredAge > 0;

    if (_giftContextController.text.trim().isEmpty ||
        !validAge ||
        _selectedCategory == null ||
        _selectedSex == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Invalid Input'),
            content: const Text('Please fill in all fields'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }
    setState(
      () => _giftIdeas.add(
        GiftContext(
          description: _giftContextController.text,
          category: _selectedCategory!,
          sex: _selectedSex!,
          age: enteredAge,
        ),
      ),
    );

    setState(() => _isLoading = true);

    try {
      final orchestrator = await GiftSearchOrchestrator.getInstance(
        aiAdapter: GeminiAiAdapter(),
        providers: [AmazonProvider()],
      );
      final result = await orchestrator.search(
        GiftContext(
          description: _giftContextController.text,
          category: _selectedCategory!,
          sex: _selectedSex!,
          age: enteredAge,
        ),
      );

      setState(() => _searchResponse = result);
      _openGiftOptionsOverlay(context);
    } catch (e) {
      debugPrint('GiftPickerApp._validateInput search failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removeGiftContext(GiftContext ideaCtx) {
    int lastPos = _giftIdeas.indexOf(ideaCtx);
    setState(() {
      _giftIdeas.remove(ideaCtx);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Idea removed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _giftIdeas.insert(lastPos, ideaCtx);
            });
          },
        ),
        duration: Duration(seconds: 3),
        persist: false,
      ),
    );
  }

  @override
  void dispose() {
    _giftContextController.dispose();
    _ageTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gift Picker')),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Center(
          child: Column(
            children: [
              TextField(
                controller: _giftContextController,
                maxLength: 50,
                decoration: InputDecoration(
                  labelText: 'Describe what you are looking for',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  DropdownMenu(
                    hintText: 'Category',
                    onSelected: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    dropdownMenuEntries: GiftCategory.values
                        .map(
                          (cat) => DropdownMenuEntry(
                            value: cat,
                            label: cat.name.toUpperCase(),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        DropdownMenu(
                          hintText: 'Sex',
                          onSelected: (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedSex = value;
                            });
                          },
                          dropdownMenuEntries: Sex.values
                              .map(
                                (s) => DropdownMenuEntry(
                                  value: s,
                                  label: s.name.toUpperCase(),
                                ),
                              )
                              .toList(),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _ageTextController,
                            maxLength: 2,
                            decoration: InputDecoration(labelText: 'Age'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _validateInput,
                child: const Text('Find Gift Ideas'),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GiftIdeasList(
                  ideas: _giftIdeas,
                  onRemoveIdeaCtx: _removeGiftContext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
