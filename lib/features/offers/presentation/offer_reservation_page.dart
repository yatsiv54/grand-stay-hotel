import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grand_stay/features/map_navigation/presentation/map_navigation_page.dart';

import '../../../di.dart';
import '../../bookings/domain/booking_entry.dart';
import '../../bookings/domain/bookings_repository.dart';
import '../../bookings/presentation/booking_cubit.dart';
import '../../bookings/presentation/qr_page.dart';
import '../domain/offer.dart';

class OfferReservationPage extends StatefulWidget {
  const OfferReservationPage({super.key, required this.offer});
  final Offer offer;

  @override
  State<OfferReservationPage> createState() => _OfferReservationPageState();
}

class _OfferReservationPageState extends State<OfferReservationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  DateTime? _checkIn;
  bool _saving = false;

  DateTime get _today => DateTime.now();
  DateTime get _validUntil {
    final today = _today;
    final until = widget.offer.validUntilDate;
    if (until == null) return today.add(const Duration(days: 365));
    // якщо дата валідності у минулому — використовуємо сьогодні, щоб не ламати date picker
    return until.isBefore(today) ? today : until;
  }

  List<int> get _validWeekdays => widget.offer.validWeekdays;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          title: const Text('Reserve Exclusive deals'),
          leading: backButton(context),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.offer.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.black87,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    label: 'Full name',
                    controller: _nameCtrl,
                    hint: 'Your name',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    label: 'Phone number',
                    controller: _phoneCtrl,
                    hint: 'Your number',
                    keyboard: TextInputType.phone,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _DateTile(
                    label: 'Check-in date',
                    value: _checkIn,
                    onTap: _pickDate,
                    until: _validUntil,
                    weekdays: _validWeekdays,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      onPressed: _saving ? null : _submit,
                      child: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Confirm reservation',
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                            ),
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

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: Colors.black, fontSize: 16),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final firstDate = _today;
    final lastDate = _validUntil;
    final desired = _checkIn ?? _today;
    final initial = _resolveInitial(desired, firstDate, lastDate);
    if (initial == null) {
      _showError('No available dates for this offer');
      return;
    }
    final picked = await _showCustomDatePicker(
      initial: initial.isAfter(lastDate) ? lastDate : initial,
      firstDate: firstDate,
      lastDate: lastDate,
      isAllowed: (day) => _isAllowedDay(day, firstDate, lastDate),
    );
    if (picked != null) {
      setState(() => _checkIn = picked);
    }
  }

  Future<DateTime?> _showCustomDatePicker({
    required DateTime initial,
    required DateTime firstDate,
    required DateTime lastDate,
    required bool Function(DateTime) isAllowed,
  }) async {
    DateTime temp = initial;
    DateTime displayed = DateTime(temp.year, temp.month);

    List<DateTime> buildGrid() {
      final firstDay = DateTime(displayed.year, displayed.month, 1);
      final startWeekday = (firstDay.weekday + 6) % 7;
      final daysInMonth = DateTime(displayed.year, displayed.month + 1, 0).day;
      final days = <DateTime>[];
      for (int i = 0; i < startWeekday; i++) {
        days.add(firstDay.subtract(Duration(days: startWeekday - i)));
      }
      for (int d = 1; d <= daysInMonth; d++) {
        days.add(DateTime(displayed.year, displayed.month, d));
      }
      while (days.length < 42) {
        days.add(
          DateTime(
            displayed.year,
            displayed.month,
            daysInMonth + (days.length - startWeekday) + 1,
          ),
        );
      }
      return days;
    }

    bool disabled(DateTime date) =>
        date.isBefore(
          DateTime(firstDate.year, firstDate.month, firstDate.day),
        ) ||
        date.isAfter(lastDate) ||
        !isAllowed(date);

    return showDialog<DateTime>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
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

              final days = buildGrid();
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => shiftMonth(-1),
                        ),
                        Text(
                          '${displayed.year}-${displayed.month.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () => shiftMonth(1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Table(
                      children: [
                        const TableRow(
                          children: [
                            Center(child: Text('Mon')),
                            Center(child: Text('Tue')),
                            Center(child: Text('Wed')),
                            Center(child: Text('Thu')),
                            Center(child: Text('Fri')),
                            Center(child: Text('Sat')),
                            Center(child: Text('Sun')),
                          ],
                        ),
                        ...List.generate(6, (row) {
                          return TableRow(
                            children: List.generate(7, (col) {
                              final date = days[row * 7 + col];
                              final isDisabled = disabled(date);
                              final isSelected =
                                  date.year == temp.year &&
                                  date.month == temp.month &&
                                  date.day == temp.day &&
                                  !isDisabled;
                              return GestureDetector(
                                onTap: isDisabled
                                    ? null
                                    : () => setState(() => temp = date),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? Colors.green
                                            : Colors.transparent,
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        '${date.day}',
                                        style: TextStyle(
                                          color: isDisabled
                                              ? Colors.grey
                                              : (isSelected
                                                    ? Colors.white
                                                    : Colors.black),
                                          fontWeight: FontWeight.w600,
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
                    const SizedBox(height: 12),
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
                        onPressed: () => Navigator.of(context).pop(temp),
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
  }

  bool _isAllowedDay(DateTime day, DateTime first, DateTime last) {
    return !day.isAfter(last) &&
        !day.isBefore(first) &&
        (_validWeekdays.isEmpty || _validWeekdays.contains(day.weekday));
  }

  DateTime? _resolveInitial(DateTime desired, DateTime first, DateTime last) {
    final clamped = desired.isBefore(first)
        ? first
        : (desired.isAfter(last) ? last : desired);
    if (_isAllowedDay(clamped, first, last)) return clamped;
    for (var i = 1; i <= 14; i++) {
      final next = clamped.add(Duration(days: i));
      if (_isAllowedDay(next, first, last)) return next;
    }
    for (var i = 1; i <= 14; i++) {
      final prev = clamped.subtract(Duration(days: i));
      if (_isAllowedDay(prev, first, last)) return prev;
    }
    return _validWeekdays.isEmpty ? clamped : null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_checkIn == null) {
      _showError('Select date');
      return;
    }
    if (_validUntil != null && _checkIn!.isAfter(_validUntil!)) {
      final dateLabel = _validUntil!.toIso8601String().split('T').first;
      _showError('Dates must be before $dateLabel');
      return;
    }
    if (_validWeekdays.isNotEmpty &&
        !_validWeekdays.contains(_checkIn!.weekday)) {
      _showError('Select allowed days only');
      return;
    }
    setState(() => _saving = true);
    final repo = getIt<BookingsRepository>();
    final booking = BookingEntry(
      id: 'offer_${widget.offer.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: widget.offer.title,
      category: BookingCategory.deals,
      status: BookingStatus.active,
      assetPlaceholder: widget.offer.image,
      contactName: _nameCtrl.text.trim(),
      contactPhone: _phoneCtrl.text.trim(),
      date: _checkIn!.toIso8601String().split('T').first,
      time: null,
      detailPrimary: 'Date: ${_checkIn!.toIso8601String().split('T').first}',
      detailSecondary: null,
      cta: BookingCta.qr,
      hint: widget.offer.hint,
      eventDate: _checkIn,
    );
    await repo.addBooking(booking);
    await getIt<BookingCubit>().loadAll();
    if (!mounted) return;
    setState(() => _saving = false);
    final info = _toQrInfo(booking);
    context.push('/qr/show', extra: info);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  QrInfo _toQrInfo(BookingEntry entry) {
    final guestName = _nameCtrl.text.trim().isNotEmpty
        ? _nameCtrl.text.trim()
        : 'Guest';
    final phone = _phoneCtrl.text.trim().isNotEmpty
        ? _phoneCtrl.text.trim()
        : '-';
    final date = entry.date ??
        entry.eventDate?.toIso8601String().split('T').first ??
        '-';
    final time = entry.time ??
        _formatTime(entry.eventDate) ??
        '-';
    return OfferQrInfo(
      img: entry.assetPlaceholder,
      subtitle: entry.detailSecondary ?? entry.detailPrimary ?? '',
      name: guestName,
      phoneNumber: phone,
      placeName: entry.title,
      hint: entry.hint ?? 'Show this code at the entrance',
      date: date,
      time: time,
    );
  }

  String? _formatTime(DateTime? dt) {
    if (dt == null) return null;
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
    required this.until,
    required this.weekdays,
  });
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final DateTime? until;
  final List<int> weekdays;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: Colors.black, fontSize: 16),
        ),
        const SizedBox(height: 4),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null
                        ? value!.toIso8601String().split('T').first
                        : 'Select date',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                SizedBox(
                  width: 20,
                  child: Image.asset('assets/images/dining/calendar.png'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        if (until != null)
          Text(
            'Valid until ${until!.toIso8601String().split('T').first}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
        if (weekdays.isNotEmpty)
          Text(
            'Allowed days: ${_weekdayLabels(weekdays)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
      ],
    );
  }

  String _weekdayLabels(List<int> days) {
    const names = {
      DateTime.monday: 'Mon',
      DateTime.tuesday: 'Tue',
      DateTime.wednesday: 'Wed',
      DateTime.thursday: 'Thu',
      DateTime.friday: 'Fri',
      DateTime.saturday: 'Sat',
      DateTime.sunday: 'Sun',
    };
    return days
        .map((d) => names[d] ?? '')
        .where((e) => e.isNotEmpty)
        .join(', ');
  }
}
