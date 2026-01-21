import 'package:flutter/material.dart';
import 'package:gift_sense/gift_picker/models/gift_context.dart';
import 'package:gift_sense/gift_picker/ui/widgets/gift_ideas_item.dart';

class GiftIdeasList extends StatelessWidget {
  const GiftIdeasList({
    super.key,
    required this.ideas,
    required this.onRemoveIdeaCtx,
  });
  final List<GiftContext> ideas;

  final void Function(GiftContext idea) onRemoveIdeaCtx;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: ideas.length,
      itemBuilder: (BuildContext context, int index) => Dismissible(
        key: ValueKey(ideas[index]),
        child: GiftIdea(idea: ideas[index]),
        onDismissed: (direction) => onRemoveIdeaCtx(ideas[index]),
      ),
    );
  }
}
