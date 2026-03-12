import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grand_stay/features/map_navigation/presentation/map_navigation_page.dart';

import '../../../di.dart';
import '../data/entertainment_repository.dart';
import '../domain/entertainment_item.dart';

enum EntertainmentTab {
  liveShows,
  poolSpa,
  fitnessGym,
  outdoorAdventures,
  workshopsClasses,
}

class EntertainmentPage extends StatefulWidget {
  const EntertainmentPage({super.key});

  @override
  State<EntertainmentPage> createState() => _EntertainmentPageState();
}

class _EntertainmentPageState extends State<EntertainmentPage> {
  EntertainmentTab _tab = EntertainmentTab.liveShows;
  late final EntertainmentRepository _repo;
  List<EntertainmentItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repo = getIt<EntertainmentRepository>();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _repo.fetchItems();
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _items.where((item) {
      switch (_tab) {
        case EntertainmentTab.liveShows:
          return item.category == EntertainmentCategory.liveShows;
        case EntertainmentTab.poolSpa:
          return item.category == EntertainmentCategory.poolSpa;
        case EntertainmentTab.fitnessGym:
          return item.category == EntertainmentCategory.fitnessGym;
        case EntertainmentTab.outdoorAdventures:
          return item.category == EntertainmentCategory.outdoorAdventures;
        case EntertainmentTab.workshopsClasses:
          return item.category == EntertainmentCategory.workshopsClasses;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 5,
        leading: backButton(context),
        title: Text(
          'Entertainment & Activities',
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      body: Column(
        children: [
          _FilterBar(current: _tab, onChanged: (t) => setState(() => _tab = t)),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) =>
                        _EntertainmentCard(item: filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.current, required this.onChanged});
  final EntertainmentTab current;
  final ValueChanged<EntertainmentTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (
        tab: EntertainmentTab.liveShows,
        label: 'LIVE SHOWS',
        iconAsset: 'assets/images/entertainment/page/mic.png',
      ),
      (
        tab: EntertainmentTab.poolSpa,
        label: 'POOL & SPA',
        iconAsset: 'assets/images/entertainment/page/spa.png',
      ),
      (
        tab: EntertainmentTab.fitnessGym,
        label: 'FITNESS & GYM',
        iconAsset: 'assets/images/entertainment/page/gym.png',
      ),
      (
        tab: EntertainmentTab.outdoorAdventures,
        label: 'OUTDOOR ADVENTURES',
        iconAsset: 'assets/images/entertainment/page/map.png',
      ),
      (
        tab: EntertainmentTab.workshopsClasses,
        label: 'WORKSHOPS & CLASSES',
        iconAsset: 'assets/images/entertainment/page/paint.png',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(230, 33, 45, 1),
            Color.fromRGBO(232, 34, 42, 1),
            Color.fromRGBO(159, 7, 13, 1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final t in tabs) ...[
              _TabChip(
                label: t.label,
                iconAsset: t.iconAsset,
                selected: current == t.tab,
                onTap: () => onChanged(t.tab),
              ),
              const SizedBox(width: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.iconAsset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String iconAsset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 6),
        decoration: selected
            ? const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white, width: 2),
                ),
              )
            : null,
        child: Row(
          children: [
            SizedBox(width: 20, child: Image.asset(iconAsset)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntertainmentCard extends StatelessWidget {
  const _EntertainmentCard({required this.item});
  final EntertainmentItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tag = item.tag ?? '';

    return Container(
      height: 120,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: 110,
                child: Image.asset(item.imageAsset, fit: BoxFit.cover),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      item.when,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                          child: Image.asset(
                            'assets/images/entertainment/page/tag.png',
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tag.isNotEmpty
                              ? tag
                              : item.entryPrice.split('\n').first,
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: Colors.black,
                          ),
                        ),
                        Spacer(),
                        Center(
                          child: SizedBox(
                            height: 28,
                            width: 60,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => context.push(
                                '/entertainment/detail',
                                extra: item,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
