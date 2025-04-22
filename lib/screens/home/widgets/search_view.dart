import 'package:flutter/material.dart';
import 'dart:async';
import '../../../models/class_schedule.dart';
import '../../../services/schedule_service.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _scheduleService = ScheduleService();
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<ClassSchedule>? _searchResults;
  String _selectedFilter = 'subject'; // 'subject' or 'teacher'

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final schedule = await _scheduleService.getWeeklySchedule();
    if (mounted) {
      setState(() => _searchResults = schedule);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        _loadInitialData();
        return;
      }

      final results = await _scheduleService.searchSchedule(query);
      if (mounted) {
        setState(() {
          _searchResults =
              results.where((schedule) {
                final searchTerm = query.toLowerCase();
                return _selectedFilter == 'subject'
                    ? schedule.subject.toLowerCase().contains(searchTerm)
                    : schedule.teacher.toLowerCase().contains(searchTerm);
              }).toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText:
                      'Search ${_selectedFilter == 'subject' ? 'subjects' : 'teachers'}...',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'subject',
                    label: Text('Subject'),
                    icon: Icon(Icons.book),
                  ),
                  ButtonSegment(
                    value: 'teacher',
                    label: Text('Teacher'),
                    icon: Icon(Icons.person),
                  ),
                ],
                selected: {_selectedFilter},
                onSelectionChanged: (Set<String> selection) {
                  setState(() {
                    _selectedFilter = selection.first;
                    if (_searchController.text.isNotEmpty) {
                      _onSearchChanged(_searchController.text);
                    }
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child:
              _searchResults == null
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults!.isEmpty
                  ? Center(
                    child: Text(
                      'No classes found',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _searchResults!.length,
                    itemBuilder: (context, index) {
                      final schedule = _searchResults![index];
                      return Card(
                        child: ListTile(
                          title: Text(schedule.subject),
                          subtitle: Text(
                            '${schedule.day}\n${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}\n${schedule.teacher}',
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
