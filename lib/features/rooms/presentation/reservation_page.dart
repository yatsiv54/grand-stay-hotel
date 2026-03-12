import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:grand_stay/features/map_navigation/presentation/map_navigation_page.dart';

import '../../../di.dart';
import '../../bookings/domain/booking_entry.dart';
import '../../bookings/domain/bookings_repository.dart';
import '../../bookings/presentation/booking_cubit.dart';
import '../../bookings/presentation/qr_page.dart';
import '../domain/room.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key, required this.room});

  final Room room;

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _roomNumberCtrl = TextEditingController();
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _adults = 2;
  int _children = 0;
  final Map<String, bool> _prefs = {
    'Sea view': true,
    'Quiet room': false,
    'High floor': false,
    'Extra pillow': true,
  };
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _roomNumberCtrl.dispose();
    super.dispose();
  }

  List<String> _quantityFrom(String? guests, int? adults, int? children) {
    final parts = <String>[];
    if (adults != null) parts.add('Adults: $adults');
    if (children != null) parts.add('Children: $children');
    if (parts.isNotEmpty) return parts;
    if (guests == null || guests.trim().isEmpty) return const [];
    return guests
        .split(RegExp(r'\s{2,}'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String _defaultHint(BookingCategory category) {
    switch (category) {
      case BookingCategory.rooms:
        return 'Show this code at the reception during check-in';
      case BookingCategory.dining:
        return 'Scan this code at the entrance for quicker check-in';
      case BookingCategory.deals:
      case BookingCategory.activities:
        return 'Show this code at the entrance';
    }
  }

  String? _extractDate(String? text) {
    if (text == null) return null;
    final match = RegExp(r'\d{4}-\d{2}-\d{2}').firstMatch(text);
    return match?.group(0);
  }

  String? _fallbackNextDay(BookingEntry entry) {
    if (entry.eventDate == null) return null;
    final next = entry.eventDate!.add(const Duration(days: 1));
    return next.toIso8601String().split('T').first;
  }

  Future<void> _pickDate({required bool isCheckIn}) async {
    final now = DateTime.now();
    final firstDate = isCheckIn ? now : (_checkIn ?? now);
    final lastDate = DateTime(now.year + 2);
    DateTime temp = isCheckIn
        ? (_checkIn ?? now)
        : (_checkOut ?? _checkIn ?? now);
    DateTime displayed = DateTime(temp.year, temp.month);

    DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              void shiftMonth(int delta) {
                final next = DateTime(
                  displayed.year,
                  displayed.month + delta,
                  1,
                );
                if (next.isBefore(
                      DateTime(firstDate.year, firstDate.month, 1),
                    ) ||
                    next.isAfter(DateTime(lastDate.year, lastDate.month, 1)))
                  return;
                setState(() => displayed = next);
              }

              List<DateTime> buildGrid() {
                final firstDay = DateTime(displayed.year, displayed.month, 1);
                final startWeekday = (firstDay.weekday + 6) % 7; // Monday=0
                final daysInMonth = DateTime(
                  displayed.year,
                  displayed.month + 1,
                  0,
                ).day;
                final days = <DateTime>[];
                for (int i = 0; i < startWeekday; i++) {
                  days.add(firstDay.subtract(Duration(days: startWeekday - i)));
                }
                for (int d = 1; d <= daysInMonth; d++) {
                  days.add(DateTime(displayed.year, displayed.month, d));
                }
                while (days.length < 42) {
                  days.add(days.last.add(const Duration(days: 1)));
                }
                return days;
              }

              bool isDisabled(DateTime date) =>
                  date.isBefore(
                    DateTime(firstDate.year, firstDate.month, firstDate.day),
                  ) ||
                  date.isAfter(lastDate) ||
                  (!isCheckIn && _checkIn != null && date.isBefore(_checkIn!));

              final days = buildGrid();

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Pick Date',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          onPressed: () => shiftMonth(-1),
                        ),
                        Column(
                          children: [
                            Text(
                              '${temp.day.toString().padLeft(2, '0')}.${temp.month.toString().padLeft(2, '0')}.${temp.year}',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios_rounded),
                          onPressed: () => shiftMonth(1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Table(
                      children: [
                        const TableRow(
                          children: [
                            _DayHeader('Mo'),
                            _DayHeader('Tu'),
                            _DayHeader('We'),
                            _DayHeader('Th'),
                            _DayHeader('Fr'),
                            _DayHeader('Sa'),
                            _DayHeader('Su'),
                          ],
                        ),
                        ...List.generate(6, (row) {
                          return TableRow(
                            children: List.generate(7, (col) {
                              final date = days[row * 7 + col];
                              final disabled = isDisabled(date);
                              final isSelected =
                                  date.year == temp.year &&
                                  date.month == temp.month &&
                                  date.day == temp.day &&
                                  !disabled;
                              return GestureDetector(
                                onTap: disabled
                                    ? null
                                    : () => setState(() {
                                        temp = date;
                                        displayed = DateTime(
                                          date.year,
                                          date.month,
                                        );
                                      }),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.green
                                            : Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${date.day}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                            color: disabled
                                                ? Colors.grey.shade400
                                                : (isSelected
                                                      ? Colors.white
                                                      : Colors.black87),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: isDisabled(temp)
                            ? null
                            : () => Navigator.of(context).pop(temp),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkIn = picked;
          if (_checkOut != null && !_checkOut!.isAfter(_checkIn!)) {
            _checkOut = null;
          }
        } else {
          if (_checkIn != null && picked.isBefore(_checkIn!)) {
            _checkOut = null;
          } else {
            _checkOut = picked;
          }
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_checkIn == null ||
        _checkOut == null ||
        !_checkOut!.isAfter(_checkIn!)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select valid dates')));
      return;
    }
    setState(() => _saving = true);
    final repo = getIt<BookingsRepository>();
    final room = widget.room;
    final booking = BookingEntry(
      id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
      title: room.name,
      category: BookingCategory.rooms,
      status: BookingStatus.active,
      assetPlaceholder: room.photos.isNotEmpty ? room.photos.first : 'rooms_1',
      contactName: _nameCtrl.text.trim(),
      contactPhone: _phoneCtrl.text.trim(),
      roomNumber: _roomNumberCtrl.text.trim(),
      preferences: _prefs.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList(),
      checkInDate: _checkIn!.toIso8601String().split('T').first,
      checkOutDate: _checkOut!.toIso8601String().split('T').first,
      adults: _adults,
      children: _children,
      detailPrimary:
          'Check-in: ${_checkIn!.toIso8601String().split('T').first}',
      detailSecondary:
          'Check-out: ${_checkOut!.toIso8601String().split('T').first}',
      guests: 'Adults: $_adults  Children: $_children',
      cta: BookingCta.qr,
      hint: room.hint,
    );
    await repo.addBooking(booking);
    await getIt<BookingCubit>().loadAll();
    if (!mounted) return;
    setState(() => _saving = false);
    final qrInfo = _bookingToQr(booking);
    context.push('/qr/show', extra: qrInfo);
  }

  QrInfo _bookingToQr(BookingEntry entry) {
    final guestName = _nameCtrl.text.trim().isNotEmpty
        ? _nameCtrl.text.trim()
        : 'Guest';
    final phone = _phoneCtrl.text.trim().isNotEmpty
        ? _phoneCtrl.text.trim()
        : '-';
    return RoomQrInfo(
      img: entry.assetPlaceholder,
      subtitle: entry.detailSecondary ?? entry.detailPrimary ?? '',
      name: guestName,
      phoneNumber: phone,
      placeName: entry.title,
      hint: entry.hint ?? _defaultHint(entry.category),
      roomNumber: entry.roomNumber ?? '',
      quantity: _quantityFrom(entry.guests, entry.adults, entry.children),
      preferences: entry.preferences,
      checkInDate:
          entry.checkInDate ??
          entry.eventDate?.toIso8601String().split('T').first ??
          _extractDate(entry.detailPrimary) ??
          '-',
      checkOutDate:
          entry.checkOutDate ??
          _fallbackNextDay(entry) ??
          _extractDate(entry.detailSecondary) ??
          '-',
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          toolbarHeight: 80,
          titleSpacing: 5,
          backgroundColor: Colors.white,
          shadowColor: Colors.black,
          elevation: 3,
          title: Text(room.name, style: TextStyle(fontWeight: FontWeight.w700)),
          leadingWidth: 65,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: backButton(context),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 32,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _nameCtrl,
                        label: 'Full name',
                        hint: 'Your name',
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _phoneCtrl,
                        label: 'Phone number',
                        hint: 'Your number',
                        keyboard: TextInputType.phone,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Room type',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDropdown<String>(
                        value: room.name,
                        items: [room.name],
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _roomNumberCtrl,
                        label: 'Room number',
                        hint: 'Number',
                        keyboard: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _DateField(
                              label: 'Check-in date',
                              value: _checkIn,
                              onTap: () => _pickDate(isCheckIn: true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DateField(
                              label: 'Check-out date',
                              value: _checkOut,
                              onTap: () => _pickDate(isCheckIn: false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown<int>(
                              value: _adults,
                              items: List.generate(5, (i) => i + 1),
                              onChanged: (v) =>
                                  setState(() => _adults = v ?? _adults),
                              label: 'Adults',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdown<int>(
                              value: _children,
                              items: List.generate(4, (i) => i),
                              onChanged: (v) =>
                                  setState(() => _children = v ?? _children),
                              label: 'Children',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Additional preferences',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._prefs.entries.map(
                        (e) => CheckboxListTile(
                          checkboxShape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(7),
                          ),
                          dense: true,
                          visualDensity: VisualDensity(vertical: -4),

                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            e.key,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.black87,
                            ),
                          ),
                          value: e.value,
                          activeColor: Colors.green,
                          onChanged: (v) =>
                              setState(() => _prefs[e.key] = v ?? false),
                          controlAffinity: ListTileControlAffinity.trailing,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          onPressed: _saving ? null : _submit,
                          child: _saving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Confirm reservation',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 22,
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          inputFormatters: keyboard == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            isDense: true,
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String? label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),
        DropdownButtonFormField<T>(
          icon: Icon(Icons.keyboard_arrow_down, size: 30, color: Colors.grey),
          value: value,
          items: items
              .map(
                (e) => DropdownMenuItem<T>(value: e, child: Text(e.toString())),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            isDense: true,
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Row(
              children: [
                Text(
                  value != null
                      ? '${value!.day.toString().padLeft(2, '0')}.${value!.month.toString().padLeft(2, '0')}.${value!.year}'
                      : 'Select date',
                  style: theme.textTheme.bodyMedium,
                ),
                const Spacer(),
                SizedBox(
                  width: 17,
                  child: Image.asset('assets/images/dining/calendar.png'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
