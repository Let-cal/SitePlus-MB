import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:siteplus_mb/pages/TaskPage/components/task_card.dart';
import 'package:siteplus_mb/service/api_service.dart';
import 'package:siteplus_mb/utils/TaskPage/task_api_model.dart';

class VerticalTaskList extends StatelessWidget {
  final void Function(int? filterTaskId)? onNavigateToTaskTabWithFilter;

  const VerticalTaskList({super.key, this.onNavigateToTaskTabWithFilter});

  @override
  Widget build(BuildContext context) {
    final ApiService apiService = ApiService();

    return FutureBuilder(
      future: apiService.getTasks(page: 1, pageSize: 5),
      builder: (context, snapshot) {
        // Trường hợp đang tải
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Trường hợp có lỗi
        if (snapshot.hasError) {
          return _buildErrorWidget(
            context,
            'Failed to load tasks: ${snapshot.error}',
            onRetry: () {
              // Gọi lại Future để thử tải lại
              (context as Element).markNeedsBuild();
            },
          );
        }

        // Kiểm tra dữ liệu trả về
        if (!snapshot.hasData || snapshot.data == null) {
          return _buildErrorWidget(
            context,
            'No task data available',
            onRetry: () {
              (context as Element).markNeedsBuild();
            },
          );
        }

        // Kiểm tra cấu trúc dữ liệu
        final data = snapshot.data as Map<String, dynamic>;
        if (!data.containsKey('data') ||
            data['data'] == null ||
            !data['data'].containsKey('listData')) {
          return _buildErrorWidget(
            context,
            'Invalid data format',
            onRetry: () {
              (context as Element).markNeedsBuild();
            },
          );
        }

        // Lấy danh sách tasks
        final tasks =
            (data['data']['listData'] as List<dynamic>)
                .map<Task>((json) => Task.fromJson(json))
                .toList();

        // Nếu danh sách rỗng
        if (tasks.isEmpty) {
          return _buildErrorWidget(
            context,
            'No tasks found',
            onRetry: () {
              (context as Element).markNeedsBuild();
            },
          );
        }

        // Hiển thị danh sách tasks
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            final delayMs = 100 + (index * 100);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TaskCard(
                    task: task,
                    onTap: () {
                      if (onNavigateToTaskTabWithFilter != null) {
                        onNavigateToTaskTabWithFilter!(task.id);
                      }
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
            );
          },
        );
      },
    );
  }

  // Widget hiển thị lỗi
  Widget _buildErrorWidget(context, message, {required VoidCallback onRetry}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 48,
          ).animate().shakeX(amount: 0.2, duration: 700.ms),
          const SizedBox(height: 8),
          Text(
            'Unable to load tasks',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Try Again'),
          ).animate().scale(delay: 300.ms),
        ],
      ),
    );
  }
}
