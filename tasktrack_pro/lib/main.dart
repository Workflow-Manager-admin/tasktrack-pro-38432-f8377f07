import 'package:flutter/material.dart';
import 'task_creation_dialog.dart';

void main() {
  runApp(const TaskTrackProApp());
}

// PUBLIC_INTERFACE
class TaskTrackProApp extends StatelessWidget {
  const TaskTrackProApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    // Setup color scheme according to provided theme colors.
    const primaryColor = Color(0xFF1976D2);
    const secondaryColor = Color(0xFF424242);
    const accentColor = Color(0xFFFFC107);

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black87,
      primaryContainer: const Color(0x1A1976D2), // 0x1A = 10% opacity
      onPrimaryContainer: Colors.black,
      secondaryContainer: const Color(0x1A424242),
      onSecondaryContainer: Colors.black,
      surfaceTint: Colors.white,
      outline: Colors.black26,
      outlineVariant: Colors.black12,
      inverseSurface: Colors.black87,
      onInverseSurface: Colors.white,
      inversePrimary: accentColor,
      shadow: Colors.black54,
      scrim: Colors.black54,
      // Removed deprecated background/onBackground
    );

    final theme = ThemeData(
      colorScheme: colorScheme,
      primaryColor: primaryColor,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryColor,
        unselectedItemColor: secondaryColor,
      ),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'TaskTrack Pro',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const MainContainer(),
    );
  }
}

// PUBLIC_INTERFACE
class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  // For initial implementation, we'll have three tabs: Tasks, Completed, Settings
  int _currentIndex = 0;

  // Sample Data for Tasks
  final List<Map<String, dynamic>> tasks = [
    {
      'title': 'Buy groceries',
      'due': DateTime.now().add(const Duration(hours: 2)),
      'completed': false,
      'list': 'Personal',
    },
    {
      'title': 'Team meeting',
      'due': DateTime.now().add(const Duration(hours: 3)),
      'completed': false,
      'list': 'Work',
    },
    {
      'title': 'Submit project report',
      'due': DateTime.now().add(const Duration(days: 1)),
      'completed': true,
      'list': 'Work',
    },
  ];

  // PUBLIC_INTERFACE
  void _onCreateTask() async {
    // Show the enhanced task creation modal and update state on submission.
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const TaskCreationDialog(),
    );

    if (result != null) {
      setState(() {
        tasks.add({
          'title': result['title'],
          'description': result['description'],
          'due': result['due'],
          'completed': false,
          'list': 'Personal',
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created successfully!')),
      );
    }
  }

  // PUBLIC_INTERFACE
  Widget _buildTaskList() {
    // Group by "due" date, only show incomplete tasks.
    final tasksByDate = <String, List<Map<String, dynamic>>>{};
    for (final task in tasks.where((t) => !t['completed'])) {
      final key = "${task['due'].year}-${task['due'].month}-${task['due'].day}";
      tasksByDate.putIfAbsent(key, () => []).add(task);
    }
    if (tasksByDate.isEmpty) {
      return const Center(
        child: Text('No tasks for today!'),
      );
    }

    return ListView(
      children: tasksByDate.entries.map((entry) {
        final parts = entry.key.split('-');
        final date = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "${date.day}/${date.month}/${date.year}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1976D2),
                ),
              ),
            ),
            ...entry.value.map((task) => _TaskTile(
                  title: task['title'],
                  due: task['due'],
                  completed: task['completed'],
                  onComplete: () {
                    setState(() {
                      task['completed'] = true;
                    });
                  },
                )),
          ],
        );
      }).toList(),
    );
  }

  // PUBLIC_INTERFACE
  Widget _buildCompletedList() {
    final completed = tasks.where((t) => t['completed']).toList();
    if (completed.isEmpty) {
      return const Center(
        child: Text('No completed tasks yet!'),
      );
    }
    return ListView(
      children: completed.map((task) => ListTile(
        leading: const Icon(Icons.check_circle, color: Color(0xFF1976D2)),
        title: Text(
          task['title'],
          style: const TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
          ),
        ),
        subtitle: Text('Completed on: '
            '${task['due'].day}/${task['due'].month}/${task['due'].year}'),
      )).toList(),
    );
  }

  // PUBLIC_INTERFACE
  Widget _buildSettings() {
    return const Center(
      child: Text('Settings coming soon!', style: TextStyle(fontSize: 16)),
    );
  }

  // PUBLIC_INTERFACE
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('TaskTrack Pro'),
      actions: [
        // Simulate a "notifications"/reminders icon in the top bar.
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            // For now, just show a snackbar.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reminders & Notifications')),
            );
          },
        ),
      ],
    );
  }

  // PUBLIC_INTERFACE
  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (idx) {
        setState(() {
          _currentIndex = idx;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt_outlined),
          label: "Tasks",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check_circle_outline),
          label: "Completed"
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: "Settings",
        ),
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_currentIndex) {
      case 1:
        body = _buildCompletedList();
        break;
      case 2:
        body = _buildSettings();
        break;
      case 0:
      default:
        body = _buildTaskList();
        break;
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: body,
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _onCreateTask,
              tooltip: 'Create Task',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}

/// Widget for Individual Task Tile (Title, due date, completion)
class _TaskTile extends StatelessWidget {
  final String title;
  final DateTime due;
  final bool completed;
  final VoidCallback onComplete;

  const _TaskTile({
    required this.title,
    required this.due,
    required this.completed,
    required this.onComplete,
  });

  // PUBLIC_INTERFACE
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: completed,
        onChanged: completed ? null : (v) => onComplete(),
        activeColor: const Color(0xFF1976D2),
      ),
      title: Text(
        title,
        style: completed
            ? const TextStyle(
                decoration: TextDecoration.lineThrough, color: Colors.grey)
            : null,
      ),
      subtitle: Text('Due: ${due.day}/${due.month}/${due.year} ${due.hour.toString().padLeft(2, '0')}:${due.minute.toString().padLeft(2, '0')}'),
      trailing: !completed
          ? IconButton(
              icon: const Icon(Icons.notifications_active, color: Color(0xFFFFC107)),
              tooltip: "Set Reminder",
              onPressed: () {
                // Placeholder for reminders
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Set Reminder (Coming Soon)')),
                );
              },
            )
          : null,
    );
  }
}
