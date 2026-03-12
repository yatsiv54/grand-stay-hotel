import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MapCard extends StatelessWidget {
  const MapCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/map'),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Image.asset('assets/images/home/map.png'),
              Positioned.fill(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 35,
                        child: Image.asset('assets/images/home/mappoint.png'),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Map & Navigation',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          letterSpacing: 0.2,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
