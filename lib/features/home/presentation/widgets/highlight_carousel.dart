import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/models/highlight.dart';

class HighlightCarousel extends StatefulWidget {
  const HighlightCarousel({super.key, required this.highlights, this.onTap});

  final List<Highlight> highlights;
  final ValueChanged<Highlight>? onTap;

  @override
  State<HighlightCarousel> createState() => _HighlightCarouselState();
}

class _HighlightCarouselState extends State<HighlightCarousel> {
  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.99);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 181,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (index) => setState(() => _page = index),
            itemCount: widget.highlights.length,
            padEnds: false,
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              final highlight = widget.highlights[index];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: HighlightCard(highlight: highlight, onTap: widget.onTap),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class HighlightCard extends StatelessWidget {
  const HighlightCard({super.key, required this.highlight, this.onTap});

  final Highlight highlight;
  final ValueChanged<Highlight>? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageAsset = _assetForHighlight(highlight.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.11),
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: AspectRatio(
                  aspectRatio: 16 / 4.5,
                  child: imageAsset != null
                      ? Image.asset(imageAsset, fit: BoxFit.cover)
                      : Container(color: Colors.grey.shade300),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        highlight.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryRed,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              maxLines: 2,
                              highlight.subtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                                color: Colors.black,
                                height: 1.2,
                              ),
                            ),
                          ),
                          SizedBox(width: 75),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 8,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(83, 177, 87, 1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                minimumSize: const Size(60, 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () => onTap?.call(highlight),
              child: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

String? _assetForHighlight(String id) {
  switch (id) {
    case 'spa_escape':
      return 'assets/images/offers/spa.png';
    case 'late_checkout':
      return 'assets/images/offers/late.png';
    default:
      return null;
  }
}
