import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mapUri = Uri.parse('https://maps.app.goo.gl/XqLPTCi1DKPpLnNQ7');
    final phoneUri = Uri.parse('tel:+19202088000');
    final privacyUri = Uri.parse(
      'https://www.grandstayhospitality.com/privacy-policy',
    );

    Future<void> launchLink(Uri uri, {String? fallbackMessage}) async {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(fallbackMessage ?? 'Unable to open link')),
        );
      }
    }

    return Container(
      color: AppTheme.surface,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
        children: [
          _ActionButton(
            textColor: Color.fromRGBO(237, 31, 38, 1),
            color: const Color.fromRGBO(255, 189, 189, 1),
            label: 'Call reception',
            icon: 'assets/images/support/call.png',
            onTap: () =>
                launchLink(phoneUri, fallbackMessage: 'Cannot start call'),
          ),
          const SizedBox(height: 28),
          _ActionButton(
            textColor: Color.fromRGBO(83, 177, 87, 1),
            color: const Color.fromRGBO(217, 255, 221, 1),
            label: 'Open Hotel location',
            icon: 'assets/images/support/dot.png',
            onTap: () =>
                launchLink(mapUri, fallbackMessage: 'Cannot open Maps link'),
          ),
          const SizedBox(height: 28),
          _ActionButton(
            textColor: Color.fromRGBO(213, 145, 0, 1),
            color: const Color.fromRGBO(247, 246, 173, 1),
            label: 'Privacy Policy',
            icon: 'assets/images/support/dot2.png',
            onTap: () => launchLink(
              privacyUri,
              fallbackMessage: 'Cannot open Privacy Policy',
            ),
          ),
          const SizedBox(height: 28),
          _FaqTile(
            title: 'Check-in & check-out times',
            content: const [
              'Check-in: from 14:00',
              'Check-out: until 12:00',
              'Early check-in and late check-out',
              'are available on request and',
              'depend on availability.',
              'Some offers may include extended hours.',
            ],
          ),
          const SizedBox(height: 10),
          _FaqTile(
            title: 'How to use my QR Pass?',
            content: const [
              'Use your QR Pass here:',
              '• Reception — for room check-in',
              '• Restaurant host — for dining',
              '• Spa desk — for treatments',
              '• Event entry — for activities',
              '• Service points — for special offers',
              'The QR Pass shows your next upcoming',
              'reservation automatically.',
            ],
          ),
          const SizedBox(height: 10),
          _FaqTile(
            title: 'Room amenities',
            content: const [
              'All rooms include:',
              '• Wi-Fi',
              '• Smart TV',
              '• Air conditioning',
              '• Safe',
              '• Mini-fridge',
              '• Tea & coffee set',
              '• Hairdryer',
              '• Bathroom amenities',
              '',
              'Suites may include additional features',
              'such as lounge area, balcony or bathtub.',
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.color,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.textColor,
  });

  final Color color;
  final Color textColor;
  final String label;
  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(32),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 24, child: Image.asset(icon)),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.title, required this.content});

  final String title;
  final List<String> content;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 52,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Color.fromRGBO(156, 164, 171, 1),
                    size: 30,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(1, 8, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.content
                  .map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        line,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black,
                          fontSize: 14,
                          height: 1.2,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}
