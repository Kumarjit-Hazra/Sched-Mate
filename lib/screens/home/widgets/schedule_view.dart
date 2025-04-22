import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../models/class_schedule.dart';
import '../../../services/schedule_service.dart';
import '../../../services/export_service.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  final _scheduleService = ScheduleService();
  final _exportService = ExportService();
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<ClassSchedule>? _weeklySchedule;
  List<ClassSchedule> _selectedDaySchedule = [];
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final schedule = await _scheduleService.getWeeklySchedule();
    if (mounted) {
      setState(() {
        _weeklySchedule = schedule;
        _updateSelectedDaySchedule();
      });
    }
  }

  void _updateSelectedDaySchedule() {
    if (_weeklySchedule == null) return;

    final selectedDayName = _getDayName(_selectedDay.weekday);
    _selectedDaySchedule =
        _weeklySchedule!
            .where((schedule) => schedule.day == selectedDayName)
            .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  Future<void> _exportSchedule(String format) async {
    if (_weeklySchedule == null) return;

    setState(() => _isExporting = true);

    try {
      final path =
          format == 'pdf'
              ? await _exportService.exportToPDF(_weeklySchedule!)
              : await _exportService.exportToExcel(_weeklySchedule!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Schedule exported to $path'),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to export schedule')),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: _isExporting ? null : () => _exportSchedule('pdf'),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('PDF'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _isExporting ? null : () => _exportSchedule('excel'),
                icon: const Icon(Icons.table_chart),
                label: const Text('Excel'),
              ),
            ],
          ),
        ),
        TableCalendar(
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2024, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: CalendarFormat.week,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _updateSelectedDaySchedule();
            });
          },
        ),
        if (_isExporting)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        Expanded(
          child:
              _weeklySchedule == null
                  ? const Center(child: CircularProgressIndicator())
                  : _selectedDaySchedule.isEmpty
                  ? Center(
                    child: Text(
                      'No classes scheduled for ${_getDayName(_selectedDay.weekday)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _selectedDaySchedule.length,
                    itemBuilder: (context, index) {
                      final schedule = _selectedDaySchedule[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.class_),
                          title: Text(schedule.subject),
                          subtitle: Text(
                            '${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}\n${schedule.teacher}',
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
