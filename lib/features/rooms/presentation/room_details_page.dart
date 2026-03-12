import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/room.dart';
import '../domain/room_feature.dart';

class RoomDetailsPage extends StatefulWidget {
  const RoomDetailsPage({super.key, required this.room});
  final Room room;

  @override
  State<RoomDetailsPage> createState() => _RoomDetailsPageState();
}

class _RoomDetailsPageState extends State<RoomDetailsPage> {
  late final PageController _controller;
  int _page = 0;

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
    final room = widget.room;
    final theme = Theme.of(context);
    final capacityText = (room.capacity != null && room.capacity!.isNotEmpty)
        ? room.capacity!
        : 'Up to 2 guests';
    final sizeText = room.sizeFull.isNotEmpty
        ? room.sizeFull
        : (room.size.isNotEmpty ? room.size : '—');
    final bookLabel = room.type.toLowerCase().contains('suite')
        ? 'Book this suite'
        : 'Book this room';

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: 240,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _controller,
                        itemCount: room.photos.length,
                        onPageChanged: (i) => setState(() => _page = i),
                        itemBuilder: (context, index) {
                          return Image.asset(
                            room.photos[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          );
                        },
                      ),
                      Positioned(
                        top: 40,
                        left: 16,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.black,
                              size: 20,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${_page + 1}/${room.photos.length}',
                            style: const TextStyle(
                              letterSpacing: 1.4,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 16,
                    bottom: 150,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.black87,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        room.description,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                        maxLines: 3,

                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Capacity',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color.fromRGBO(83, 177, 87, 1),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                capacityText,

                                style: theme.textTheme.bodyMedium!.copyWith(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 100),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Size',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: 16,
                                  color: Color.fromRGBO(83, 177, 87, 1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sizeText,
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _FeaturesBlock(room: room),
                      const SizedBox(height: 16),
                      _AmenitiesBlock(room: room),
                      const SizedBox(height: 16),
                      _ExtrasBlock(room: room),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Text(
                        '\$${room.price.toStringAsFixed(0)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'per night',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color.fromRGBO(83, 177, 87, 1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 31,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () =>
                            context.push('/reservation', extra: room),
                        child: Text(bookLabel, style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturesBlock extends StatelessWidget {
  const _FeaturesBlock({required this.room});
  final Room room;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final featureKeys = room.features
        .map(featureKeyFromString)
        .where((e) => e != null)
        .cast<RoomFeatureKey>()
        .toList();
    final data = featureKeys.isEmpty ? RoomFeatureKey.values : featureKeys;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          padding: EdgeInsets.only(left: 12, top: 12, bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Features',
                style: theme.textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              Column(
                children: data
                    .map(
                      (key) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 2,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              child: Image.asset(featureDescriptor(key).icon),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                featureDescriptor(key).label,
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AmenitiesBlock extends StatelessWidget {
  const _AmenitiesBlock({required this.room});
  final Room room;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amenities = room.amenities.isEmpty
        ? [
            'Wi-Fi',
            'TV',
            'Hairdryer',
            'Mini-bar',
            'Telephone',
            'AC',
            'In-room safe',
            'Complimentary bottled water',
          ]
        : room.amenities;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: theme.textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 0,
          runSpacing: 0,
          children: amenities
              .map(
                (a) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        a,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          letterSpacing: 0.2,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 6),

                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Color.fromRGBO(83, 177, 87, 1),
                      ),
                      const SizedBox(width: 6),
                      Container(height: 16, width: 1, color: Colors.black54),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ExtrasBlock extends StatelessWidget {
  const _ExtrasBlock({required this.room});
  final Room room;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extras = room.extras.isEmpty
        ? [
            'Late check-out subject to availability',
            'Pillow selection on request',
          ]
        : room.extras;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Extras',
          style: theme.textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ...extras.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: Text(e, style: theme.textTheme.bodyMedium),
          ),
        ),
      ],
    );
  }
}
