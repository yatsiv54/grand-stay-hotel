import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:grand_stay/features/map_navigation/presentation/map_navigation_page.dart';

import '../../bookings/domain/booking_entry.dart';
import '../../bookings/domain/bookings_repository.dart';
import '../../bookings/presentation/booking_cubit.dart';
import '../../bookings/presentation/qr_page.dart';
import '../../../di.dart';
import '../domain/dining_item.dart';

class DiningReservationPage extends StatefulWidget {
  const DiningReservationPage({super.key, required this.item});
  final DiningItem item;

  @override
  State<DiningReservationPage> createState() => _DiningReservationPageState();
}

class _DiningReservationPageState extends State<DiningReservationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  int _adults = 2;
  int _children = 0;
  DateTime? _date;
  TimeOfDay? _time;
  final _commentsCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _commentsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
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
            'Reserve Table',
            style: Theme.of(
              context,
            ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
          ),
          leading: backButton(context),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.black87,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _nameCtrl,
                        label: 'Full name',
                        hint: 'Your name',
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _phoneCtrl,
                        label: 'Phone number',
                        hint: 'Your number',
                        keyboard: TextInputType.phone,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown<int>(
                              label: 'Adults',
                              value: _adults,
                              items: List.generate(8, (i) => i + 1),
                              onChanged: (v) =>
                                  setState(() => _adults = v ?? _adults),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdown<int>(
                              label: 'Children',
                              value: _children,
                              items: List.generate(6, (i) => i),
                              onChanged: (v) =>
                                  setState(() => _children = v ?? _children),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _DateField(
                              label: 'Date',
                              value: _date,
                              onTap: _pickDate,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TimeField(
                              label: 'Time',
                              value: _time,
                              onTap: _pickTime,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _commentsCtrl,
                        label: 'Comments',
                        hint: 'Your comments',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 40),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 12,
                        ),
                        child: SafeArea(
                          top: false,
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: _saving ? null : _submit,
                              child: _saving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Confirm reservation',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await _showCustomDatePicker(
      context: context,
      initial: _date ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay temp = _time ?? const TimeOfDay(hour: 19, minute: 0);
    bool am = temp.period == DayPeriod.am;
    int hour = temp.hourOfPeriod == 0 ? 12 : temp.hourOfPeriod;
    int minute = temp.minute;

    int clampVal(String text, int min, int max, int fallback) {
      final v = int.tryParse(text);
      if (v == null) return fallback;
      if (v < min) return min;
      if (v > max) return max;
      return v;
    }

    String pad2(int v) => v.toString().padLeft(2, '0');

    final hourCtrl = TextEditingController(text: pad2(hour));
    final minuteCtrl = TextEditingController(text: pad2(minute));

    TimeOfDay? result;
    result = await showDialog<TimeOfDay>(
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
              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 12, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        icon: const Icon(Icons.close, color: Colors.black26),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose Time',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _TimeInputBox(
                          controller: hourCtrl,
                          min: 1,
                          max: 12,
                          onChanged: (text) {
                            final v = clampVal(text, 1, 12, hour);
                            if (v != hour) {
                              setState(() => hour = v);
                              final padded = pad2(v);
                              if (hourCtrl.text != padded) {
                                hourCtrl.text = padded;
                                hourCtrl.selection = TextSelection.fromPosition(
                                  TextPosition(offset: padded.length),
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        _TimeInputBox(
                          controller: minuteCtrl,
                          min: 0,
                          max: 59,
                          twoDigits: true,
                          onChanged: (text) {
                            final v = clampVal(text, 0, 59, minute);
                            if (v != minute) {
                              setState(() => minute = v);
                              final padded = pad2(v);
                              if (minuteCtrl.text != padded) {
                                minuteCtrl.text = padded;
                                minuteCtrl.selection =
                                    TextSelection.fromPosition(
                                      TextPosition(offset: padded.length),
                                    );
                              }
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            _AmPmButton(
                              isTop: true,
                              label: 'AM',
                              selected: am,
                              onTap: () => setState(() => am = true),
                            ),
                            _AmPmButton(
                              isTop: false,
                              label: 'PM',
                              selected: !am,
                              onTap: () => setState(() => am = false),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: () {
                            final safeHour = clampVal(
                              hourCtrl.text,
                              1,
                              12,
                              hour,
                            );
                            final safeMinute = clampVal(
                              minuteCtrl.text,
                              0,
                              59,
                              minute,
                            );
                            hour = safeHour;
                            minute = safeMinute;
                            final h24 = (safeHour % 12) + (am ? 0 : 12);
                            Navigator.of(
                              context,
                            ).pop(TimeOfDay(hour: h24, minute: safeMinute));
                          },
                          child: Text(
                            'Save',
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
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
    if (result != null) {
      setState(() => _time = result);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null || _time == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select date and time')));
      return;
    }
    setState(() => _saving = true);
    final repo = getIt<BookingsRepository>();
    final dateTime = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );
    final item = widget.item;
    final booking = BookingEntry(
      id: 'dining_${item.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: item.name,
      category: BookingCategory.dining,
      status: BookingStatus.active,
      assetPlaceholder: item.image,
      contactName: _nameCtrl.text.trim(),
      contactPhone: _phoneCtrl.text.trim(),
      detailPrimary:
          'Date: ${_date!.toIso8601String().split('T').first}  Time: ${_time!.format(context)}',
      detailSecondary: item.tags.join(', '),
      guests: 'Adults: $_adults  Children: $_children',
      date: _date!.toIso8601String().split('T').first,
      time: _time!.format(context),
      adults: _adults,
      children: _children,
      table: _commentsCtrl.text.trim().isNotEmpty
          ? _commentsCtrl.text.trim()
          : null,
      cta: BookingCta.qr,
      hint: item.hint,
      eventDate: dateTime,
    );
    await repo.addBooking(booking);
    await getIt<BookingCubit>().loadAll();
    if (!mounted) return;
    setState(() => _saving = false);
    final info = _toQrInfo(booking);
    context.push('/qr/show', extra: info);
  }

  QrInfo _toQrInfo(BookingEntry entry) {
    final guestName = _nameCtrl.text.trim().isNotEmpty
        ? _nameCtrl.text.trim()
        : 'Guest';
    final phone = _phoneCtrl.text.trim().isNotEmpty
        ? _phoneCtrl.text.trim()
        : '-';

    return DiningQrInfo(
      img: entry.assetPlaceholder,
      subtitle: entry.detailSecondary ?? '',
      name: guestName,
      phoneNumber: phone,
      placeName: entry.title,
      hint: entry.hint ?? 'Scan this code at the entrance for quicker check-in',
      quantity: _quantityFrom(entry.guests, entry.adults, entry.children),
      table: entry.table?.trim().isNotEmpty == true ? entry.table!.trim() : '',
      date:
          entry.date ??
          entry.eventDate?.toIso8601String().split('T').first ??
          '-',
      time: entry.time ?? _formatTime(entry.eventDate) ?? '-',
    );
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

  String? _formatTime(DateTime? dt) {
    if (dt == null) return null;
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          inputFormatters: keyboard == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          maxLines: maxLines,
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

  Future<DateTime?> _showCustomDatePicker({
    required BuildContext context,
    required DateTime initial,
    required DateTime firstDate,
    required DateTime lastDate,
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
        date.isAfter(lastDate);

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

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          items: items
              .map(
                (e) => DropdownMenuItem<T>(value: e, child: Text(e.toString())),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                  width: 20,
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

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.value,
    required this.onTap,
  });
  final String label;
  final TimeOfDay? value;
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
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Row(
              children: [
                Text(
                  value != null ? value!.format(context) : 'Select time',
                  style: theme.textTheme.bodyMedium,
                ),
                const Spacer(),
                const Icon(Icons.access_time_rounded, color: Colors.green),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeInputBox extends StatelessWidget {
  const _TimeInputBox({
    required this.controller,
    required this.onChanged,
    required this.min,
    required this.max,
    this.twoDigits = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int min;
  final int max;
  final bool twoDigits;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 96,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(240, 240, 240, 1),
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 48,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(twoDigits ? 2 : 2),
        ],
        decoration: const InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _AmPmButton extends StatelessWidget {
  const _AmPmButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isTop,
  });
  final bool isTop;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 41,
        decoration: BoxDecoration(
          color: selected
              ? Color.fromRGBO(231, 34, 43, 1)
              : Color.fromRGBO(240, 240, 240, 1),
          border: BoxBorder.all(color: Colors.black12, width: 1),
          borderRadius: isTop
              ? BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                )
              : BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
