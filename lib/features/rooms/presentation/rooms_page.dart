import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:grand_stay/di.dart';
import 'package:grand_stay/features/map_navigation/presentation/map_navigation_page.dart';

import '../data/rooms_local_repository.dart';
import '../domain/room.dart';
import '../domain/rooms_repository.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  late final RoomsRepository _repository;
  bool _loading = true;
  List<Room> _rooms = [];
  List<Room> _allRooms = [];
  final Set<String> _filters = {};
  RoomsSort? _sort;

  @override
  void initState() {
    super.initState();
    _repository = getIt<RoomsRepository>();
    _load();
  }

  Future<void> _load() async {
    final data = await _repository.fetchRooms();
    if (!mounted) return;
    setState(() {
      _allRooms = data;
      _rooms = _applyFilters(data);
      _loading = false;
    });
  }

  List<Room> _applyFilters(List<Room> source) {
    var result = List<Room>.from(source);
    if (_filters.isNotEmpty) {
      result = result.where((room) {
        final tag = room.tag?.toLowerCase();
        final filtersLower = _filters.map((e) => e.toLowerCase()).toList();
        final hasAllTags =
            tag != null && filtersLower.every((f) => tag.contains(f));
        final isFamily = filtersLower.contains('family');
        final hasChildrenCapacity =
            isFamily && room.capacity!.toLowerCase().contains('children');
        return (hasAllTags && (!isFamily || hasChildrenCapacity)) ||
            (isFamily && hasChildrenCapacity);
      }).toList();
    }
    result.sort((a, b) {
      switch (_sort) {
        case RoomsSort.priceHighLow:
          return b.price.compareTo(a.price);
        case RoomsSort.sizeSmallLarge:
          return _sizeValue(a.size).compareTo(_sizeValue(b.size));
        case RoomsSort.sizeLargeSmall:
          return _sizeValue(b.size).compareTo(_sizeValue(a.size));
        case RoomsSort.priceLowHigh:
        case null:
          return a.price.compareTo(b.price);
      }
    });
    return result;
  }

  double _sizeValue(String raw) {
    final cleaned = raw.replaceAll(RegExp('[^0-9\\.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          toolbarHeight: 80,
          titleSpacing: 10,
          backgroundColor: Colors.white,
          shadowColor: Colors.black,
          elevation: 3,
          leading: backButton(context),
          title: const Text(
            'Rooms & Suites',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          foregroundColor: Colors.black,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
                children: [
                  _SortSection(
                    sort: _sort,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _sort = value;
                        _rooms = _applyFilters(_allRooms);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _FiltersSection(
                    filters: _filters,
                    onChanged: (label, value) {
                      setState(() {
                        if (value) {
                          _filters.add(label);
                        } else {
                          _filters.remove(label);
                        }
                        _rooms = _applyFilters(_allRooms);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  ..._rooms.map(
                    (room) => _RoomCard(
                      room: room,
                      theme: theme,
                      onDetails: () => context.push('/room', extra: room),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

enum RoomsSort { priceLowHigh, priceHighLow, sizeSmallLarge, sizeLargeSmall }

class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.room,
    required this.theme,
    required this.onDetails,
  });

  final Room room;
  final ThemeData theme;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RoomCarousel(photos: room.photos),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            room.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.black87,
                              fontSize: 20,
                            ),
                          ),
                          Spacer(),
                          Text(
                            'From ',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '\$${room.price.toStringAsFixed(0)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              room.description,
                              style: theme.textTheme.bodyMedium!.copyWith(
                                fontSize: 14,
                                color: Color.fromRGBO(156, 164, 171, 1),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'night',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.black45,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ..._buildTags(room),
                          Spacer(),
                          SizedBox(
                            width: 60,
                            height: 28,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                elevation: 0,
                              ),
                              onPressed: onDetails,
                              child: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTags(Room room) {
    final optionalTag = room.tag?.trim();
    final tags = <Widget>[
      _Tag(label: room.bed, icon: 'assets/images/rooms/bed.png'),
      Text('•'),
      _Tag(label: room.size, icon: 'assets/images/rooms/size.png'),
      Text('•'),
      if (optionalTag != null && optionalTag.isNotEmpty)
        _Tag(label: optionalTag, icon: _iconForTag(optionalTag)),
    ];
    return [
      for (int i = 0; i < tags.length; i++) ...[
        if (i > 0) const SizedBox(width: 8),
        tags[i],
      ],
    ];
  }
}

class _RoomCarousel extends StatefulWidget {
  const _RoomCarousel({required this.photos});
  final List<String> photos;

  @override
  State<_RoomCarousel> createState() => _RoomCarouselState();
}

class _RoomCarouselState extends State<_RoomCarousel> {
  int _page = 0;
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 180,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.photos.length,
              onPageChanged: (value) => setState(() => _page = value),
              itemBuilder: (context, index) {
                final asset = widget.photos[index];
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(asset),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.photos.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                  border: BoxBorder.all(color: Colors.white, width: 1),
                  color: _page == i ? Colors.white : Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SortSection extends StatelessWidget {
  const _SortSection({required this.sort, required this.onChanged});
  final RoomsSort? sort;
  final ValueChanged<RoomsSort?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort by',
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<RoomsSort>(
          icon: Icon(Icons.keyboard_arrow_down_rounded),
          value: sort,
          hint: const Text('Price'),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: const [
            DropdownMenuItem(
              value: RoomsSort.priceLowHigh,
              child: Text('Price: Low to High'),
            ),
            DropdownMenuItem(
              value: RoomsSort.priceHighLow,
              child: Text('Price: High to Low'),
            ),
            DropdownMenuItem(
              value: RoomsSort.sizeSmallLarge,
              child: Text('Size: Small to Large'),
            ),
            DropdownMenuItem(
              value: RoomsSort.sizeLargeSmall,
              child: Text('Size: Large to Small'),
            ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _FiltersSection extends StatelessWidget {
  const _FiltersSection({required this.filters, required this.onChanged});
  final Set<String> filters;
  final void Function(String label, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    const options = ['Sea view', 'Balcony', 'Jacuzzi', 'Family'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filters',
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(fontSize: 20),
        ),

        ...options.map((option) {
          final selected = filters.contains(option);
          final disabled = option == '';
          return CheckboxListTile(
            visualDensity: VisualDensity(horizontal: 0, vertical: -3),
            side: BorderSide(color: Colors.grey, width: 1.5),
            checkboxShape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(7),
            ),
            value: selected,
            onChanged: disabled
                ? null
                : (val) => onChanged(option, val ?? false),
            title: Text(
              option,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 17,
                color: selected ? Colors.black87 : Colors.grey.shade400,
              ),
            ),
            controlAffinity: ListTileControlAffinity.trailing,
            activeColor: Colors.green,
            dense: true,
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }
}

String _iconForTag(String tag) {
  final lower = tag.toLowerCase();
  if (lower.contains('view')) return 'assets/images/rooms/sea.png';
  if (lower.contains('2+2')) return 'assets/images/rooms/bed.png';
  if (lower.contains('breakfast') || lower.contains('dining')) {
    return 'assets/images/rooms/dining.png';
  }
  if (lower.contains('balcony') || lower.contains('terrace')) {
    return 'assets/images/rooms/balcony.png';
  }
  if (lower.contains('workspace') || lower.contains('desk')) {
    return 'assets/images/rooms/desk.png';
  }
  if (lower.contains('sofa') || lower.contains('lounge'))
    return 'assets/images/rooms/sofa.png';
  return 'assets/images/rooms/bed.png';
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.icon});
  final String label;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 18, child: Image.asset(icon)),

          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }
}
