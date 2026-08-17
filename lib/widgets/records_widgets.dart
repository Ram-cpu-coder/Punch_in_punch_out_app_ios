part of '../main.dart';

class WeekSummary {
  WeekSummary({required this.week, required this.hours});

  final WeekRecord week;
  final double hours;
}

class RecordsLockBanner extends StatelessWidget {
  const RecordsLockBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: AppCard(
        color: Color(0xfffff7ed),
        child: Row(
          children: [
            Icon(Icons.lock_clock_outlined, color: Color(0xffa1432f)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'A shift is running. Week records are view-only until you stop it.',
                style: TextStyle(
                  color: Color(0xff7a3527),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordsHero extends StatelessWidget {
  const RecordsHero({
    super.key,
    required this.weekStart,
    required this.paid,
    required this.hours,
    required this.pay,
  });

  final String weekStart;
  final bool paid;
  final double hours;
  final double pay;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Week $weekStart',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color:
                      paid ? const Color(0xffd7f0eb) : const Color(0xfffff2ee),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      paid ? Icons.check : Icons.schedule,
                      size: 17,
                      color: paid
                          ? const Color(0xff1d6f68)
                          : const Color(0xffa1432f),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      paid ? 'Paid' : 'Unpaid',
                      style: TextStyle(
                        color: paid
                            ? const Color(0xff1d6f68)
                            : const Color(0xffa1432f),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _RecordsHeroTile(
                  label: 'Hours',
                  value: hours.toStringAsFixed(2),
                  icon: Icons.access_time,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _RecordsHeroTile(
                  label: 'Pay',
                  value: money(pay),
                  icon: Icons.payments_outlined,
                  green: !paid,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecordsHeroTile extends StatelessWidget {
  const _RecordsHeroTile({
    required this.label,
    required this.value,
    required this.icon,
    this.green = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool green;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xfff8fbfa),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffdbe7e4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: const Color(0xff1d6f68)),
              const SizedBox(width: 7),
              Eyebrow(label),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            value,
            style: TextStyle(
              color: green ? const Color(0xff178a53) : const Color(0xff17212b),
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class RecordsToolbar extends StatelessWidget {
  const RecordsToolbar({
    super.key,
    required this.locked,
    required this.paid,
    required this.weekStart,
    required this.onPrevious,
    required this.onCurrent,
    required this.onNext,
    required this.onSavedWeeks,
    required this.onTogglePaid,
  });

  final bool locked;
  final bool paid;
  final String weekStart;
  final VoidCallback onPrevious;
  final VoidCallback onCurrent;
  final VoidCallback onNext;
  final VoidCallback onSavedWeeks;
  final VoidCallback onTogglePaid;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              _RoundToolbarButton(
                icon: Icons.chevron_left,
                label: 'Previous',
                onPressed: onPrevious,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _WeekPickerButton(
                  weekStart: weekStart,
                  onPressed: onSavedWeeks,
                ),
              ),
              const SizedBox(width: 8),
              _RoundToolbarButton(
                icon: Icons.chevron_right,
                label: 'Next',
                onPressed: onNext,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: TextButton.icon(
                    onPressed: onCurrent,
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xffedf7f4),
                      foregroundColor: const Color(0xff1d6f68),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.today_outlined, size: 18),
                    label: const Text(
                      'Current',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: FilledButton.icon(
                    onPressed: locked ? null : onTogglePaid,
                    style: FilledButton.styleFrom(
                      backgroundColor: paid
                          ? const Color(0xffeef2f2)
                          : const Color(0xff17212b),
                      foregroundColor:
                          paid ? const Color(0xff17212b) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(paid ? Icons.undo : Icons.check, size: 18),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        locked
                            ? 'Locked'
                            : paid
                                ? 'Mark unpaid'
                                : 'Mark paid',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundToolbarButton extends StatelessWidget {
  const _RoundToolbarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: SizedBox(
        width: 46,
        height: 46,
        child: IconButton.filledTonal(
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xffedf7f4),
            foregroundColor: const Color(0xff1d6f68),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: Icon(icon),
        ),
      ),
    );
  }
}

class _WeekPickerButton extends StatelessWidget {
  const _WeekPickerButton({required this.weekStart, required this.onPressed});

  final String weekStart;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xff17212b),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xffdbe7e4)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xffedf7f4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 17,
                color: Color(0xff1d6f68),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                'Week $weekStart',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const Icon(Icons.expand_more, size: 18, color: Color(0xff66737b)),
          ],
        ),
      ),
    );
  }
}

class SoftActionButton extends StatelessWidget {
  const SoftActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.trailingIcon = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool trailingIcon;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, size: 18);
    return SizedBox(
      height: 48,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xffedf7f4),
          foregroundColor: const Color(0xff1d6f68),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: trailingIcon
              ? [
                  Text(label,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(width: 7),
                  iconWidget,
                ]
              : [
                  iconWidget,
                  const SizedBox(width: 7),
                  Text(label,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                ],
        ),
      ),
    );
  }
}

class SelectLikeTile extends StatelessWidget {
  const SelectLikeTile({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xffdbe7e4)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xffedf7f4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: const Color(0xff1d6f68)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const Icon(Icons.expand_more, size: 18, color: Color(0xff66737b)),
          ],
        ),
      ),
    );
  }
}

class WeekBrowserItem extends StatelessWidget {
  const WeekBrowserItem({
    super.key,
    required this.summary,
    required this.selected,
    required this.rate,
    required this.onTap,
  });

  final WeekSummary summary;
  final bool selected;
  final double rate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final paid = summary.week.isPaid;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xffedf7f4) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  selected ? const Color(0xff9ccac1) : const Color(0xffdbe7e4),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color:
                      paid ? const Color(0xffd7f0eb) : const Color(0xfffff2ee),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  paid ? Icons.check : Icons.schedule,
                  size: 18,
                  color:
                      paid ? const Color(0xff1d6f68) : const Color(0xffa1432f),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Week ${summary.week.weekStart}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      paid ? 'Paid' : 'Not paid',
                      style: const TextStyle(
                        color: Color(0xff66737b),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${summary.hours.toStringAsFixed(2)} hrs',
                    style: const TextStyle(
                      color: Color(0xff66737b),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    money(summary.hours * rate),
                    style: TextStyle(
                      color: paid
                          ? const Color(0xff17212b)
                          : const Color(0xff178a53),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WebStyleDayRow extends StatelessWidget {
  const WebStyleDayRow({super.key, required this.day});

  final WorkDay day;

  @override
  Widget build(BuildContext context) {
    final hours = calculateDayHours(day);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xffdbe7e4))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 9,
                  runSpacing: 3,
                  children: [
                    Text(
                      day.label,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      day.date,
                      style: const TextStyle(
                        color: Color(0xff66737b),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${hours.toStringAsFixed(2)} hrs',
                style: const TextStyle(
                  color: Color(0xff66737b),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 520;
              final fields = [
                _DayField(
                  label: 'Start',
                  value: formatTime(day.start),
                  icon: Icons.login,
                ),
                _DayField(
                  label: 'End',
                  value: formatTime(day.end),
                  icon: Icons.logout,
                ),
                _DayField(
                  label: 'Break',
                  value: '${day.breakMinutes} min',
                  icon: Icons.coffee_outlined,
                ),
              ];
              if (compact) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: fields[0]),
                        const SizedBox(width: 8),
                        Expanded(child: fields[1]),
                      ],
                    ),
                    const SizedBox(height: 8),
                    fields[2],
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: fields[0]),
                  const SizedBox(width: 8),
                  Expanded(child: fields[1]),
                  const SizedBox(width: 8),
                  Expanded(child: fields[2]),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xfff8fbfa),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xffdbe7e4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_outlined,
                    size: 18, color: Color(0xff1d6f68)),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    day.notes.isEmpty ? 'Optional note' : day.notes,
                    style: TextStyle(
                      color: day.notes.isEmpty
                          ? const Color(0xff98a5aa)
                          : const Color(0xff17212b),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayField extends StatelessWidget {
  const _DayField({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xff66737b),
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xffdbe7e4)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 17, color: const Color(0xff1d6f68)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
