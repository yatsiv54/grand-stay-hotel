import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:grand_stay/features/map_navigation/presentation/map_navigation_page.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

sealed class QrInfo {
  QrInfo({
    required this.img,
    required this.subtitle,
    required this.name,
    required this.phoneNumber,
    required this.placeName,
    required this.title,
    required this.hint,
  });

  final String img;
  final String subtitle;
  final String name;
  final String phoneNumber;
  final String placeName;
  final String title;
  final String hint;

  String qrPayload();
}

class RoomQrInfo extends QrInfo {
  RoomQrInfo({
    required super.img,
    required super.subtitle,
    required super.name,
    required super.phoneNumber,
    required super.placeName,
    String title = 'Reservation confirmed',
    String hint = 'Show this code at the reception during check-in',
    required this.roomNumber,
    required this.quantity,
    required this.preferences,
    required this.checkInDate,
    required this.checkOutDate,
  }) : super(title: title, hint: hint);

  final String roomNumber;
  final List<String> quantity;
  final List<String> preferences;
  final String checkInDate;
  final String checkOutDate;

  @override
  String qrPayload() =>
      'Reservation verified. $name, $phoneNumber, $placeName, $checkInDate, $checkOutDate';
}

class DiningQrInfo extends QrInfo {
  DiningQrInfo({
    required super.img,
    required super.subtitle,
    required super.name,
    required super.phoneNumber,
    required super.placeName,
    String title = 'Reserve table',
    String hint = 'Scan this code at the entrance for quicker check-in',
    required this.quantity,
    required this.table,
    required this.date,
    required this.time,
  }) : super(title: title, hint: hint);

  final List<String> quantity;
  final String table;
  final String date;
  final String time;

  @override
  String qrPayload() =>
      'Reservation verified. $name, $phoneNumber, $placeName, $date, $time';
}

class OfferQrInfo extends QrInfo {
  OfferQrInfo({
    required super.img,
    required super.subtitle,
    required super.name,
    required super.phoneNumber,
    required super.placeName,
    String title = 'Reservation confirmed',
    String hint = 'Show this code at the reception during check-in',
    required this.date,
    required this.time,
  }) : super(title: title, hint: hint);

  final String date;
  final String time;

  @override
  String qrPayload() =>
      'Reservation verified. $name, $phoneNumber, $placeName, $date, $time';
}

class QrPage extends StatefulWidget {
  const QrPage({super.key, required this.info, this.embedded = false});

  final QrInfo info;
  final bool embedded;

  @override
  State<QrPage> createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> {
  late final ScreenshotController _screenshotController;

  @override
  void initState() {
    super.initState();
    _screenshotController = ScreenshotController();
  }

  @override
  void dispose() {
    // ScreenshotController не потребує явного dispose.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = widget.embedded
        ? null
        : AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            leading: backButton(context),
            title: Text(
              widget.info.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 24,
              ),
            ),
          );

    final content = Stack(
      children: [
        Positioned.fill(child: _BlurredBackground(image: widget.info.img)),
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(0, 255, 26, 0.5),
                  Color.fromRGBO(254, 0, 0, 0.5),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        SafeArea(
          top: appBar == null,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),
                      _QrBox(data: widget.info.qrPayload()),
                      const SizedBox(height: 12),
                      Text(
                        widget.info.hint,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black,
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 27),
                      if (widget.info is RoomQrInfo)
                        _RoomInfoList(info: widget.info as RoomQrInfo),
                      if (widget.info is DiningQrInfo)
                        _DiningInfoList(info: widget.info as DiningQrInfo),
                      if (widget.info is OfferQrInfo)
                        _OfferInfoList(info: widget.info as OfferQrInfo),
                      const SizedBox(height: 40),
                      _SaveButton(onTap: () => _saveQr(context)),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final body = Screenshot(controller: _screenshotController, child: content);

    if (widget.embedded) {
      return body;
    }

    return Scaffold(backgroundColor: Colors.black, appBar: appBar, body: body);
  }

  Future<void> _saveQr(BuildContext context) async {
    try {
      final status = await Permission.photos.request();
      final storageStatus = await Permission.storage.request();
      if (!status.isGranted && !storageStatus.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission required to save QR')),
          );
        }
        return;
      }

      final painter = QrPainter(
        data: widget.info.qrPayload(),
        version: QrVersions.auto,
        gapless: true,
        emptyColor: Colors.white,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.black,
        ),
      );
      final data = await painter.toImageData(1024, format: ImageByteFormat.png);
      if (data == null) throw Exception('Failed to render QR');
      await Gal.putImageBytes(
        data.buffer.asUint8List(),
        name: 'qr_${DateTime.now().millisecondsSinceEpoch}',
      );
      const success = true;
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'QR saved to gallery' : 'Save failed'),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving QR: $e')));
      }
    }
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          backButton(context),
          const SizedBox(width: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _QrBox extends StatelessWidget {
  const _QrBox({required this.data});
  final String data;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 250,
          height: 250,
          child: Image.asset('assets/images/qr/qr_border.png'),
        ),
        RepaintBoundary(
          child: QrImageView(
            data: data,
            size: 230,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Colors.white,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Colors.white,
            ),
            backgroundColor: Colors.transparent,
          ),
        ),
      ],
    );
  }
}

class _InfoRows extends StatelessWidget {
  const _InfoRows({required this.info});
  final QrInfo info;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _RoomInfoList extends StatelessWidget {
  const _RoomInfoList({required this.info});
  final RoomQrInfo info;

  @override
  Widget build(BuildContext context) {
    final items = <_InfoItem>[
      _InfoItem(iconAsset: 'assets/images/qr/name.png', text: info.name),
      _InfoItem(
        iconAsset: 'assets/images/qr/phone.png',
        text: info.phoneNumber,
      ),
      _InfoItem(
        iconAsset: 'assets/images/qr/lucide_hotel.png',
        text: info.placeName,
      ),
      if (info.roomNumber.isNotEmpty)
        _InfoItem(
          iconAsset: 'assets/images/qr/number.png',
          text: info.roomNumber,
        ),
      if (info.quantity.isNotEmpty)
        _InfoItem(
          iconAsset: 'assets/images/qr/people.png',
          text: info.quantity.join(', '),
        ),
      if (info.preferences.isNotEmpty)
        _InfoItem(
          iconAsset: 'assets/images/qr/extras.png',
          text: info.preferences.join(', '),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...items
            .where((e) => e.text.isNotEmpty)
            .map((e) => _InfoRow(item: e))
            .toList(),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _DateColumn(
                label: 'Check-in date',
                value: info.checkInDate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DateColumn(
                label: 'Check-out date',
                value: info.checkOutDate,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DiningInfoList extends StatelessWidget {
  const _DiningInfoList({required this.info});
  final DiningQrInfo info;

  @override
  Widget build(BuildContext context) {
    final items = <_InfoItem>[
      _InfoItem(iconAsset: 'assets/images/qr/name.png', text: info.name),
      _InfoItem(
        iconAsset: 'assets/images/qr/phone.png',
        text: info.phoneNumber,
      ),
      _InfoItem(
        iconAsset: 'assets/images/qr/restraunt.png',
        text: info.placeName,
      ),
      if (info.quantity.isNotEmpty)
        _InfoItem(
          iconAsset: 'assets/images/qr/people.png',
          text: info.quantity.join(', '),
        ),
      if (info.table.isNotEmpty)
        _InfoItem(iconAsset: 'assets/images/qr/number.png', text: info.table),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...items
            .where((e) => e.text.isNotEmpty)
            .map((e) => _InfoRow(item: e))
            .toList(),
        const SizedBox(height: 1),
        Row(
          children: [
            Expanded(
              child: _DateColumn(label: 'Date', value: info.date),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DateColumn(label: 'Time', value: info.time),
            ),
          ],
        ),
      ],
    );
  }
}

class _OfferInfoList extends StatelessWidget {
  const _OfferInfoList({required this.info});
  final OfferQrInfo info;

  @override
  Widget build(BuildContext context) {
    final items = <_InfoItem>[
      _InfoItem(iconAsset: 'assets/images/qr/name.png', text: info.name),
      _InfoItem(
        iconAsset: 'assets/images/qr/phone.png',
        text: info.phoneNumber,
      ),
      _InfoItem(
        iconAsset: 'assets/images/qr/lucide_hotel.png',
        text: info.placeName,
      ),
      if (info.subtitle.isNotEmpty)
        _InfoItem(
          iconAsset: 'assets/images/qr/surprise.png',
          text: info.subtitle,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...items
            .where((e) => e.text.isNotEmpty)
            .map((e) => _InfoRow(item: e))
            .toList(),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _DateColumn(label: 'Date', value: info.date),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DateColumn(label: 'Time', value: info.time),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.item});
  final _InfoItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          SizedBox(width: 22, child: Image.asset(item.iconAsset)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateColumn extends StatelessWidget {
  const _DateColumn({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            SizedBox(
              width: 28,
              child: Image.asset('assets/images/qr/calendar.png'),
            ),
            const SizedBox(width: 4),
            Text(
              ' $value',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoItem {
  _InfoItem({required this.iconAsset, required this.text});
  final String iconAsset;
  final String text;
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: onTap,
        child: Text(
          'Save QR code',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _BlurredBackground extends StatelessWidget {
  const _BlurredBackground({required this.image});
  final String image;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
        ),
      ),
    );
  }
}
