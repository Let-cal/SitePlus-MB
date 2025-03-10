import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siteplus_mb/components/SectionHeader.dart';
import 'package:siteplus_mb/pages/TaskPage/components/pagination_component.dart';
import 'package:siteplus_mb/pages/TaskPage/components/task_card.dart';
import 'package:siteplus_mb/pages/TaskPage/components/task_filter_chips.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/TaskPage/task_api_model.dart';
import 'package:siteplus_mb/utils/constants.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ApiService _apiService = ApiService();
  // Thêm biến động cho status maps
  Map<String, int> statusApiMap = Map.from(STATUS_API_MAP);
  Map<int, String> apiStatusMap = Map.from(API_STATUS_MAP);
  // Filter state
  String selectedStatus = 'Tất Cả';
  String selectedPriority = 'Tất Cả';

  // Pagination state
  int currentPage = 1;
  int totalPages = 1;
  int pageSize = 5;
  int totalRecords = 0;
  //load status of task from api
  Future<void> _loadTaskStatuses() async {
    try {
      final result = await _apiService.getTaskStatuses();
      if (result['success'] == true) {
        final statusData = result['data']['statuses'] as List<dynamic>;

        // Cập nhật STATUS_API_MAP và STATUS_ID_TO_NAME_MAP
        Map<String, int> newStatusMap = {};
        Map<int, String> newStatusIdToNameMap = {};

        for (var status in statusData) {
          final int id = status['id'];
          final String name = status['name'];

          // Chuẩn hóa tên status để phù hợp với UI
          String uiName;
          if (name == 'Chưa nhận')
            uiName = STATUS_CHUA_NHAN;
          else if (name == 'Đã nhận')
            uiName = STATUS_DA_NHAN;
          else if (name == 'Hoàn thành')
            uiName = STATUS_HOAN_THANH;
          else
            uiName = name; // Trường hợp có status mới từ API

          newStatusMap[uiName] = id;
          newStatusIdToNameMap[id] = uiName;
        }

        // Cập nhật map toàn cục
        setState(() {
          STATUS_API_MAP = newStatusMap;
          API_STATUS_MAP = newStatusIdToNameMap;
        });
      }
    } catch (e) {
      print("Error loading task statuses: $e");
    }
  }

  // Task data
  List<Task> tasks = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  late AnimationController _animationController;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _loadTaskStatuses().then((_) => _loadTasks());

    // Start the animation after a brief delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      int? statusValue =
          selectedStatus != 'Tất Cả' ? STATUS_API_MAP[selectedStatus] : null;

      int? priorityValue =
          selectedPriority != 'Tất Cả'
              ? PRIORITY_API_MAP[selectedPriority]
              : null;

      final result = await _apiService.getTasks(
        status: statusValue,
        priority: priorityValue,
        page: currentPage,
        pageSize: pageSize,
      );

      if (result['success'] == true) {
        final TaskResponse response = TaskResponse.fromJson(result);

        setState(() {
          tasks = response.listData;
          totalPages = response.totalPage;
          totalRecords = response.totalRecords;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          tasks = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Không thể tải nhiệm vụ'),
          ),
        );
      }
    } catch (e) {
      print("Error loading tasks: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đã xảy ra lỗi: ${e.toString()}')));
    }
  }

  void _onStatusSelected(String status) {
    if (status == selectedStatus) return;
    setState(() {
      selectedStatus = status;
      currentPage = 1;
    });
    _loadTasks();
  }

  void _onPrioritySelected(String priority) {
    if (priority == selectedPriority) return;
    setState(() {
      selectedPriority = priority;
      currentPage = 1;
    });
    _loadTasks();
  }

  void _changePage(int page) {
    if (page < 1 || page > totalPages || page == currentPage) return;
    setState(() {
      currentPage = page;
    });
    _pageController
        .animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .then((_) {
          _loadTasks();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          currentPage = 1;
        });
        await _loadTasks();
      },
      child: CustomScrollView(
        slivers: [
          // Header và bộ lọc
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: 'Danh sách nhiệm vụ',
                    subtitle: 'Quản lý và theo dõi các nhiệm vụ',
                    icon: LucideIcons.fileCheck,
                  ),
                  const SizedBox(height: 24),
                  // Task filters
                  TaskFilterChips(
                        selectedStatus: selectedStatus,
                        selectedPriority: selectedPriority,
                        onStatusSelected: _onStatusSelected,
                        onPrioritySelected: _onPrioritySelected,
                        availableStatuses: apiStatusMap,
                      )
                      .animate()
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        curve: Curves.easeOutQuart,
                        duration: 600.ms,
                        delay: 300.ms,
                      )
                      .fadeIn(delay: 300.ms, duration: 500.ms),
                ],
              ),
            ),
          ),
          if (isLoading)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator()
                        .animate(onPlay: (controller) => controller.repeat())
                        .scaleXY(
                          begin: 0.8,
                          end: 1.2,
                          duration: 1000.ms,
                          curve: Curves.easeInOut,
                        )
                        .then()
                        .scaleXY(
                          begin: 1.2,
                          end: 0.8,
                          duration: 1000.ms,
                          curve: Curves.easeInOut,
                        ),
                    const SizedBox(height: 16),
                    Text(
                          'Đang tải nhiệm vụ...',
                          style: theme.textTheme.bodyLarge,
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .fadeIn(duration: 1000.ms)
                        .then()
                        .fadeOut(duration: 1000.ms),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: _buildTaskList(),
            ),

          // Phần phân trang
          if (!isLoading && tasks.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: PaginationComponent(
                      currentPage: currentPage,
                      totalPages: totalPages,
                      onPageChanged: _changePage,
                    )
                    .animate()
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      curve: Curves.easeOutQuart,
                      duration: 600.ms,
                      delay: 200.ms,
                    )
                    .fadeIn(delay: 200.ms, duration: 500.ms),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    if (tasks.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.5),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),
              Text(
                "Không có nhiệm vụ nào phù hợp với bộ lọc",
                style: Theme.of(context).textTheme.titleMedium,
              ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final task = tasks[index];
        // Calculate staggered delay based on index
        final delayMs = 100 + (index * 100);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Hero(
            // Use ID as hero tag to enable smooth transitions if you implement task details page
            tag: 'task-card-${task.id}',
            child: Material(
              color: Colors.transparent,
              child: AnimatedTaskCard(task: task, index: index, delay: delayMs),
            ),
          ),
        );
      }, childCount: tasks.length),
    );
  }
}

class AnimatedTaskCard extends StatelessWidget {
  final Task task;
  final int index;
  final int delay;

  const AnimatedTaskCard({
    super.key,
    required this.task,
    required this.index,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedTaskCard(key: ValueKey('task-${task.id}'), task: task)
        .animate()
        .fadeIn(
          duration: 600.ms,
          delay: Duration(milliseconds: delay),
          curve: Curves.easeOutQuad,
        )
        .slideY(
          begin: 0.2,
          end: 0,
          duration: 600.ms,
          delay: Duration(milliseconds: delay),
          curve: Curves.easeOutQuad,
        )
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 600.ms,
          delay: Duration(milliseconds: delay),
          curve: Curves.easeOutQuad,
        );
  }
}
