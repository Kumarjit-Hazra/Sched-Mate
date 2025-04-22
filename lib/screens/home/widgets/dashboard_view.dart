import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/class_schedule.dart';
import '../../../services/auth_service.dart';
import '../../../services/schedule_service.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final _scheduleService = ScheduleService();
  List<ClassSchedule>? _todayClasses;
  List<ClassSchedule>? _weeklyClasses;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final today = await _scheduleService.getTodaySchedule();
    final weekly = await _scheduleService.getWeeklySchedule();

    if (mounted) {
      setState(() {
        _todayClasses = today;
        _weeklyClasses = weekly;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName =
        context.watch<AuthService>().userEmail?.split('@')[0] ?? 'User';

    return RefreshIndicator(
      onRefresh: _loadSchedules,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Welcome message
          Text(
            'Welcome, ${userName.substring(0, 1).toUpperCase()}${userName.substring(1)}!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          // Today's preview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.today,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Today's Classes",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_todayClasses == null)
                    const Center(child: CircularProgressIndicator())
                  else if (_todayClasses!.isEmpty)
                    const Text('No classes scheduled for today')
                  else
                    ...(_todayClasses!.map(
                      (schedule) => _buildClassItem(schedule),
                    )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Weekly summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_view_week,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Weekly Summary',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_weeklyClasses == null)
                    const Center(child: CircularProgressIndicator())
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total classes this week: ${_weeklyClasses!.length}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Subjects: ${_getUniqueSubjects()}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Teachers: ${_getUniqueTeachers()}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassItem(ClassSchedule schedule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.subject,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)} • ${schedule.teacher}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getUniqueSubjects() {
    if (_weeklyClasses == null) return '0';
    final subjects = _weeklyClasses!.map((s) => s.subject).toSet().length;
    return subjects.toString();
  }

  String _getUniqueTeachers() {
    if (_weeklyClasses == null) return '0';
    final teachers = _weeklyClasses!.map((s) => s.teacher).toSet().length;
    return teachers.toString();
  }
}
