import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siteplus_mb/components/SectionHeader.dart';
import 'package:siteplus_mb/components/pagination_component.dart';
import 'package:siteplus_mb/pages/TaskPage/components/task_card.dart';
import 'package:siteplus_mb/pages/TaskPage/components/task_detail_popup.dart';
import 'package:siteplus_mb/pages/TaskPage/components/task_filter_tab.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/TaskPage/task_api_model.dart';
import 'package:siteplus_mb/utils/constants.dart';

enum FilterUIType { chip, tab }

class TasksPage extends StatefulWidget {
  final void Function(int? filterSiteId)? onNavigateToSiteTab;
  final void Function(int? filterTaskId)? onNavigateToTaskTab;
  final int? filterTaskId;
  const TasksPage({
    super.key,
    this.onNavigateToSiteTab,
    this.onNavigateToTaskTab,
    this.filterTaskId,
  });
  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ApiService _apiService = ApiService();

  Map<String, int> statusApiMap = Map.from(STATUS_API_MAP);
  Map<int, String> apiStatusMap = Map.from(API_STATUS_MAP);

  String selectedStatus = 'Tất Cả';
  String selectedPriority = 'Tất Cả';
  String taskTypeFilter = 'Tất cả';
  int? selectedStatusId;
  int? selectedPriorityId;
  FilterUIType currentFilterUI = FilterUIType.chip;

  int currentPage = 1;
  int totalPages = 1;
  int pageSize = 5;
  int totalRecords = 0;

  List<Task> tasks = [];
  bool isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    selectedStatusId = null;
    selectedPriorityId = null;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _loadTaskStatuses().then((_) => _loadTasks());
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _animationController.forward();
    });
  }

  @override
  void didUpdateWidget(TasksPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filterTaskId != oldWidget.filterTaskId) {
      _loadTasks();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTaskStatuses() async {
    try {
      final result = await _apiService.getTaskStatuses();
      if (result['success'] == true) {
        final statusData = result['data']['statuses'] as List<dynamic>;
        Map<String, int> newStatusMap = {};
        Map<int, String> newStatusIdToNameMap = {};
        for (var status in statusData) {
          final int id = status['id'];
          final String name = status['name'];
          String uiName;
          switch (name) {
            case 'Chưa nhận':
              uiName = STATUS_CHUA_NHAN;
              break;
            case 'Đã nhận':
              uiName = STATUS_DA_NHAN;
              break;
            case 'Đợi duyệt':
              uiName = STATUS_CHO_PHE_DUYET;
              break;
            case 'Hoàn thành':
              uiName = STATUS_HOAN_THANH;
              break;
            default:
              uiName = name;
          }
          newStatusMap[uiName] = id;
          newStatusIdToNameMap[id] = uiName;
        }
        setState(() {
          STATUS_API_MAP = newStatusMap;
          API_STATUS_MAP = newStatusIdToNameMap;
          statusApiMap = Map.from(STATUS_API_MAP);
          apiStatusMap = Map.from(API_STATUS_MAP);
        });
      }
    } catch (e) {
      print("Error loading task statuses: $e");
    }
  }

  Future<void> _loadTasks() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final result = await _apiService.getTasks(
        status: selectedStatusId,
        priority: selectedPriorityId,
        page:
            widget.filterTaskId != null
                ? 1
                : currentPage, // Đảm bảo page luôn có giá trị
        pageSize: widget.filterTaskId != null ? 1 : pageSize,
        search: widget.filterTaskId?.toString(),
      );
      if (result['success'] == true) {
        final TaskResponse response = TaskResponse.fromJson(result);
        if (mounted) {
          setState(() {
            tasks = response.listData.take(pageSize).toList();
            totalPages = (response.totalRecords / pageSize).ceil();
            totalRecords = response.totalRecords;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
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
      }
    } catch (e) {
      print("Error loading tasks: $e");
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi: ${e.toString()}')),
        );
      }
    }
  }

  void _changePage(int page) {
    if (page < 1 || page > totalPages || page == currentPage) return;
    setState(() {
      currentPage = page;
    });
    _loadTasks();
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
        setState(() => currentPage = 1);
        await _loadTasks();
      },
      child: CustomScrollView(
        slivers: [
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
                  TaskFilterTab(
                        availableStatuses: apiStatusMap,
                        selectedStatusId: selectedStatusId,
                        selectedPriorityId: selectedPriorityId,
                        onFilterChanged: (selections) {
                          setState(() {
                            selectedStatusId = selections['status'];
                            selectedPriorityId = selections['priority'];
                            currentPage = 1;
                          });
                          _loadTasks();
                        },
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
              padding: const EdgeInsets.symmetric(horizontal: 10),
              sliver: _buildTaskList(),
            ),
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
        final delayMs = 100 + (index * 100);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Hero(
            tag: 'task-card-${task.id.toString()}',
            child: Material(
              color: Colors.transparent,
              child: TaskCard(
                    task: task,
                    onTap: () async {
                      final result = await ViewDetailTask.show(
                        context,
                        task,
                        onNavigateToSiteTab: widget.onNavigateToSiteTab,
                        onUpdateSuccess: () async {
                          if (mounted) await _loadTasks();
                        },
                      );
                      if (result == true && mounted) await _loadTasks();
                    },
                  )
                  .animate()
                  .fadeIn(
                    duration: 600.ms,
                    delay: Duration(milliseconds: delayMs),
                    curve: Curves.easeOutQuad,
                  )
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 600.ms,
                    delay: Duration(milliseconds: delayMs),
                    curve: Curves.easeOutQuad,
                  )
                  .scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    delay: Duration(milliseconds: delayMs),
                    curve: Curves.easeOutQuad,
                  ),
            ),
          ),
        );
      }, childCount: tasks.length),
    );
  }
}
