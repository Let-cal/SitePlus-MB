import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:siteplus_mb/pages/TaskPage/components/task.dart';
import 'package:siteplus_mb/pages/TaskPage/components/task_card.dart';
import 'package:siteplus_mb/pages/TaskPage/components/task_filter_chips.dart';

import 'package:siteplus_mb/pages/TaskPage/components/samble_data.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedStatus = 'Active';
  List<Task> tasks = [];
  bool isLoading = true;
  late List<Task> _cachedFilteredTasks;

  @override
  void initState() {
    super.initState();
    _cachedFilteredTasks = [];
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      print("Loading tasks...");
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      // Use SampleData instead of generating fake data
      final sampleTasks = SampleData.getTasks();

      setState(() {
        tasks = sampleTasks;
        isLoading = false;
        _updateFilteredTasks(); // Update filtered tasks after loading
      });

      print("Tasks loaded: ${tasks.length}");
      for (var task in tasks) {
        print("Task: ${task.name}, Status: ${task.status}");
      }
    } catch (e) {
      print("Error loading tasks: $e");

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateFilteredTasks() {
    _cachedFilteredTasks =
        selectedStatus == 'All'
            ? tasks
            : tasks.where((task) => task.status == selectedStatus).toList();
  }

  List<Task> get filteredTasks => _cachedFilteredTasks;

  void _onStatusSelected(String status) {
    if (status == selectedStatus) return;

    setState(() {
      selectedStatus = status;
    });
    _updateFilteredTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (MediaQuery.of(context).size.width >= 1200)
              Expanded(
                child: _buildMainContent().animate().fadeIn(
                  duration: 800.ms,
                  curve: Curves.easeOut,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wrap header trong LayoutBuilder để xử lý responsive
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 600) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tasks Overview',
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ).animate().slide(
                                  duration: 300.ms,
                                  begin: const Offset(-1, 0),
                                  end: Offset.zero,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Manage and track your tasks efficiently',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      );
                    } else {
                      // Stack layout for smaller screens
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Tasks Overview',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().slide(
                            duration: 300.ms,
                            begin: const Offset(-1, 0),
                            end: Offset.zero,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage and track your tasks efficiently',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
                TaskFilterChips(
                  selectedStatus: selectedStatus,
                  onStatusSelected: _onStatusSelected,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        if (isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: _buildTaskGrid(),
          ),
      ],
    );
  }

  Widget _buildTaskGrid() {
    if (filteredTasks.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text("No tasks available")),
      );
    }

    int crossAxisCount = MediaQuery.of(context).size.width > 600 ? 2 : 1;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final task = filteredTasks[index];
          return EnhancedTaskCard(task: task)
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 100 * index),
                duration: 400.ms,
              )
              .slideY(begin: 0.2, curve: Curves.easeOutQuad);
        }, childCount: filteredTasks.length),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
        ),
      ),
    );
  }
}
