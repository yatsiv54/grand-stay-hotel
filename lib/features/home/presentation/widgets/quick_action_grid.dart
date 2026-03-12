import 'package:flutter/material.dart';

import '../../domain/models/quick_action.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({
    super.key,
    required this.actions,
    required this.onTap,
  });

  final List<QuickAction> actions;
  final ValueChanged<QuickAction> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 108,
        crossAxisSpacing: 10,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) => _ActionTile(
        action: actions[index],
        onTap: () => onTap(actions[index]),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.action, required this.onTap});

  final QuickAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
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
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 35, child: Image.asset(action.icon)),
              const SizedBox(height: 8),
              Text(
                action.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 20,
                  color: Colors.white,
                  height: 1.2,
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
