import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/class_schedule.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ScheduleService {
  static const String _cacheKey = 'cached_schedule';

  Future<List<ClassSchedule>> getWeeklySchedule() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        // Online: In the future, this will fetch from your database
        // For now, return demo data
        final schedules = _getDemoSchedules();
        await _cacheSchedules(schedules);
        return schedules;
      } else {
        // Offline: Get from cache
        return await _getCachedSchedules();
      }
    } catch (e) {
      // On error, try to get from cache
      return await _getCachedSchedules();
    }
  }

  Future<List<ClassSchedule>> getTodaySchedule() async {
    final today = DateTime.now();
    final dayName = _getDayName(today.weekday);

    try {
      final schedules = await getWeeklySchedule();
      return schedules.where((schedule) => schedule.day == dayName).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ClassSchedule>> searchSchedule(String query) async {
    try {
      final schedules = await getWeeklySchedule();
      final searchTerm = query.toLowerCase();
      return schedules
          .where(
            (schedule) =>
                schedule.subject.toLowerCase().contains(searchTerm) ||
                schedule.teacher.toLowerCase().contains(searchTerm),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _cacheSchedules(List<ClassSchedule> schedules) async {
    final prefs = await SharedPreferences.getInstance();
    final schedulesJson =
        schedules.map((schedule) => schedule.toJson()).toList();
    await prefs.setString(_cacheKey, jsonEncode(schedulesJson));
  }

  Future<List<ClassSchedule>> _getCachedSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);

    if (cachedData != null) {
      final List<dynamic> decodedData = jsonDecode(cachedData);
      return decodedData
          .map(
            (data) => ClassSchedule.fromJson(Map<String, dynamic>.from(data)),
          )
          .toList();
    }
    return _getDemoSchedules(); // Return demo data if no cache exists
  }

  List<ClassSchedule> _getDemoSchedules() {
    // Demo schedule data with a full week of classes
    return [
      // Monday Schedule
      ClassSchedule(
        id: '1',
        subject: 'Mathematics',
        teacher: 'Dr. Smith',
        startTime: DateTime(2024, 1, 1, 9, 0),
        endTime: DateTime(2024, 1, 1, 10, 30),
        day: 'Monday',
      ),
      ClassSchedule(
        id: '2',
        subject: 'Physics',
        teacher: 'Prof. Johnson',
        startTime: DateTime(2024, 1, 1, 11, 0),
        endTime: DateTime(2024, 1, 1, 12, 30),
        day: 'Monday',
      ),
      ClassSchedule(
        id: '3',
        subject: 'Computer Science',
        teacher: 'Dr. Davis',
        startTime: DateTime(2024, 1, 1, 14, 0),
        endTime: DateTime(2024, 1, 1, 15, 30),
        day: 'Monday',
      ),

      // Tuesday Schedule
      ClassSchedule(
        id: '4',
        subject: 'Chemistry',
        teacher: 'Dr. Williams',
        startTime: DateTime(2024, 1, 2, 9, 0),
        endTime: DateTime(2024, 1, 2, 10, 30),
        day: 'Tuesday',
      ),
      ClassSchedule(
        id: '5',
        subject: 'Biology',
        teacher: 'Prof. Brown',
        startTime: DateTime(2024, 1, 2, 11, 0),
        endTime: DateTime(2024, 1, 2, 12, 30),
        day: 'Tuesday',
      ),
      ClassSchedule(
        id: '6',
        subject: 'English Literature',
        teacher: 'Ms. Taylor',
        startTime: DateTime(2024, 1, 2, 14, 0),
        endTime: DateTime(2024, 1, 2, 15, 30),
        day: 'Tuesday',
      ),

      // Wednesday Schedule
      ClassSchedule(
        id: '7',
        subject: 'Physics Lab',
        teacher: 'Prof. Johnson',
        startTime: DateTime(2024, 1, 3, 9, 0),
        endTime: DateTime(2024, 1, 3, 11, 0),
        day: 'Wednesday',
      ),
      ClassSchedule(
        id: '8',
        subject: 'Mathematics',
        teacher: 'Dr. Smith',
        startTime: DateTime(2024, 1, 3, 11, 30),
        endTime: DateTime(2024, 1, 3, 13, 0),
        day: 'Wednesday',
      ),
      ClassSchedule(
        id: '9',
        subject: 'Programming',
        teacher: 'Dr. Davis',
        startTime: DateTime(2024, 1, 3, 14, 0),
        endTime: DateTime(2024, 1, 3, 15, 30),
        day: 'Wednesday',
      ),

      // Thursday Schedule
      ClassSchedule(
        id: '10',
        subject: 'Chemistry Lab',
        teacher: 'Dr. Williams',
        startTime: DateTime(2024, 1, 4, 9, 0),
        endTime: DateTime(2024, 1, 4, 11, 0),
        day: 'Thursday',
      ),
      ClassSchedule(
        id: '11',
        subject: 'Biology',
        teacher: 'Prof. Brown',
        startTime: DateTime(2024, 1, 4, 11, 30),
        endTime: DateTime(2024, 1, 4, 13, 0),
        day: 'Thursday',
      ),
      ClassSchedule(
        id: '12',
        subject: 'History',
        teacher: 'Mr. Anderson',
        startTime: DateTime(2024, 1, 4, 14, 0),
        endTime: DateTime(2024, 1, 4, 15, 30),
        day: 'Thursday',
      ),

      // Friday Schedule
      ClassSchedule(
        id: '13',
        subject: 'Computer Science',
        teacher: 'Dr. Davis',
        startTime: DateTime(2024, 1, 5, 9, 0),
        endTime: DateTime(2024, 1, 5, 10, 30),
        day: 'Friday',
      ),
      ClassSchedule(
        id: '14',
        subject: 'Mathematics',
        teacher: 'Dr. Smith',
        startTime: DateTime(2024, 1, 5, 11, 0),
        endTime: DateTime(2024, 1, 5, 12, 30),
        day: 'Friday',
      ),
      ClassSchedule(
        id: '15',
        subject: 'English Literature',
        teacher: 'Ms. Taylor',
        startTime: DateTime(2024, 1, 5, 14, 0),
        endTime: DateTime(2024, 1, 5, 15, 30),
        day: 'Friday',
      ),
    ];
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
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
}
