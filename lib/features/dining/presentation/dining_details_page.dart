import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/dining_item.dart';

class DiningDetailsPage extends StatelessWidget {
  const DiningDetailsPage({super.key, required this.item});
  final DiningItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            ListView(
              padding: EdgeInsets.zero,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 240,
                      width: double.infinity,
                      child: Image.asset(item.image, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 40,
                      left: 12,
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
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.description,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SectionLabel('Atmosphere'),
                      const SizedBox(height: 6),
                      Text(
                        item.atmosphere,
                        style: theme.textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _OpenHoursBlock(openHours: item.openHours),
                      const SizedBox(height: 15),
                      _SectionLabel('Cuisine'),
                      const SizedBox(height: 6),
                      Text(
                        item.cuisine,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SectionLabel('Special features'),
                      const SizedBox(height: 6),
                      ...item.specialFeatures.map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            f,
                            style: theme.textTheme.bodyMedium!.copyWith(
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SectionLabel('Menu preview'),
                      const SizedBox(height: 4),
                      ...item.menuPreview.map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            f,
                            style: theme.textTheme.bodyMedium!.copyWith(
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(230, 33, 45, 1),
                      Color.fromRGBO(232, 34, 42, 1),
                      Color.fromRGBO(159, 7, 13, 1),
                    ],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      onPressed: () =>
                          context.push('/dining/reservation', extra: item),
                      child: Text(
                        'Reserve a table',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          color: Color.fromRGBO(83, 177, 87, 1),
                        ),
                      ),
                    ),
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

class _OpenHoursBlock extends StatelessWidget {
  const _OpenHoursBlock({required this.openHours});
  final String openHours;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 6,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Open hours',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color.fromRGBO(83, 177, 87, 1),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            openHours,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    );
  }
}
