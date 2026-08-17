part of '../main.dart';

class RecordSummaryChip extends StatelessWidget {
  const RecordSummaryChip(
      {super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.68),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class WeekRecordCard extends StatelessWidget {
  const WeekRecordCard({
    super.key,
    required this.week,
    required this.rate,
    required this.editingLocked,
    required this.onTogglePaid,
  });

  final WeekRecord week;
  final double rate;
  final bool editingLocked;
  final VoidCallback onTogglePaid;

  @override
  Widget build(BuildContext context) {
    final hours = week.days.fold<double>(
      0,
      (sum, day) => sum + calculateDayHours(day),
    );
    final workedDays =
        week.days.where((day) => calculateDayHours(day) > 0).length;
    final statusColor =
        week.isPaid ? const Color(0xff1d6f68) : const Color(0xffa1432f);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: week.weekStart == mondayOf(DateTime.now()),
          tilePadding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          collapsedShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Week ${week.weekStart}',
                      style: const TextStyle(
                          fontSize: 19, fontWeight: FontWeight.w900),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(week.isPaid ? Icons.check : Icons.schedule,
                            size: 16, color: statusColor),
                        const SizedBox(width: 5),
                        Text(
                          week.isPaid ? 'Paid' : 'Unpaid',
                          style: TextStyle(
                              color: statusColor, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: WeekStatPill(
                          label: 'Hours', value: hours.toStringAsFixed(2))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: WeekStatPill(
                          label: 'Pay',
                          value: money(hours * rate),
                          green: !week.isPaid)),
                  const SizedBox(width: 8),
                  Expanded(
                      child:
                          WeekStatPill(label: 'Days', value: '$workedDays/7')),
                ],
              ),
            ],
          ),
          children: [
            const SizedBox(height: 8),
            if (editingLocked)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xfffff2ee),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Stop the running shift before changing payment status.',
                  style: TextStyle(
                      color: Color(0xffa1432f), fontWeight: FontWeight.w800),
                ),
              ),
            ...week.days.map((day) => RecordDayTile(day: day)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.tonalIcon(
                onPressed: editingLocked ? null : onTogglePaid,
                icon: Icon(week.isPaid ? Icons.undo : Icons.check),
                label: Text(week.isPaid ? 'Mark unpaid' : 'Mark paid'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeekStatPill extends StatelessWidget {
  const WeekStatPill({
    super.key,
    required this.label,
    required this.value,
    this.green = false,
  });

  final String label;
  final String value;
  final bool green;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: green ? const Color(0xffe8f5f2) : const Color(0xfff7fbfa),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffdbe7e4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xff66737b),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: green ? const Color(0xff178a53) : const Color(0xff17212b),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class RecordDayTile extends StatelessWidget {
  const RecordDayTile({super.key, required this.day});

  final WorkDay day;

  @override
  Widget build(BuildContext context) {
    final hours = calculateDayHours(day);
    final worked = hours > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: worked ? Colors.white : const Color(0xfff7fbfa),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: worked ? const Color(0xffcfe4de) : const Color(0xffedf1ef),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: worked ? const Color(0xffe8f5f2) : const Color(0xffedf1ef),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              worked ? Icons.timer_outlined : Icons.remove,
              color: worked ? const Color(0xff1d6f68) : const Color(0xff8a9792),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 7,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      day.label,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      day.date,
                      style: const TextStyle(
                          color: Color(0xff66737b), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  worked
                      ? '${formatTime(day.start)} - ${formatTime(day.end)}'
                      : 'No shift recorded',
                  style: TextStyle(
                    color: worked
                        ? const Color(0xff17212b)
                        : const Color(0xff8a9792),
                    fontWeight: worked ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${hours.toStringAsFixed(2)} hrs',
            style: TextStyle(
              color: worked ? const Color(0xff1d6f68) : const Color(0xff8a9792),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
