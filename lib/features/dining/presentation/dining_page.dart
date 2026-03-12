import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grand_stay/features/map_navigation/presentation/map_navigation_page.dart';

import '../../../di.dart';
import '../data/dining_repository.dart';
import '../domain/dining_item.dart';

class DiningPage extends StatefulWidget {
  const DiningPage({super.key});

  @override
  State<DiningPage> createState() => _DiningPageState();
}

class _DiningPageState extends State<DiningPage> {
  late final DiningRepository _repo;
  List<DiningItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repo = getIt<DiningRepository>();
    _load();
  }

  Future<void> _load() async {
    final data = await _repo.fetchItems();
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          toolbarHeight: 80,
          titleSpacing: 5,
          backgroundColor: Colors.white,
          shadowColor: Colors.black,
          elevation: 3,
          title: Text(
            'Where would you like to eat?',
            style: Theme.of(
              context,
            ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
          ),
          leading: backButton(context),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                itemBuilder: (context, index) =>
                    _DiningCard(item: _items[index]),
              ),
      ),
    );
  }
}

class _DiningCard extends StatelessWidget {
  const _DiningCard({required this.item});
  final DiningItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tagLabel = item.tags.isNotEmpty
        ? item.tags.join(', ')
        : item.openHours;
    return Container(
      height: 120,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 110,
                child: Image.asset(item.image, fit: BoxFit.cover),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 12, 8),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          item.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black,
                            fontSize: 12,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          item.openHours,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                            fontSize: 12,
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
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                tagLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
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
                          onPressed: () =>
                              context.push('/dining/detail', extra: item),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
