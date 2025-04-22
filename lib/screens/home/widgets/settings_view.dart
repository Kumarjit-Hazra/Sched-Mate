import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/theme_service.dart';
import '../../../services/schedule_service.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  Future<void> _clearData(BuildContext context) async {
    final scheduleService = ScheduleService();
    await scheduleService.clearCache();

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cache cleared successfully')));
  }

  @override
  Widget build(BuildContext context) {
    final bool isDemo = context.watch<AuthService>().isDemo;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          child: ListTile(
            leading: Icon(
              context.watch<ThemeService>().isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: context.watch<ThemeService>().isDarkMode,
              onChanged: (_) => context.read<ThemeService>().toggleTheme(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('App Info'),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Version: 1.0.0'),
                    SizedBox(height: 8),
                    Text('Made with ❤️ by kumarjit'),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.devices,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Offline Mode'),
                subtitle: const Text('Cache last schedule for offline access'),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
              ListTile(
                leading: Icon(
                  Icons.science,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Demo Mode'),
                subtitle: Text(
                  isDemo ? 'Using demo credentials' : 'Not in demo mode',
                ),
                trailing: TextButton(
                  onPressed: isDemo ? () => _clearData(context) : null,
                  child: const Text('Clear Data'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () => context.read<AuthService>().signOut(),
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
        ),
      ],
    );
  }
}
