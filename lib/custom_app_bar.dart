import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siteplus_mb/pages/LoginPage/pages/login_page.dart';
import 'package:siteplus_mb/pages/NotificationPage/pages/notification_page.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String? description;
  final List<Widget>? additionalActions;
  final int notificationCount;
  final VoidCallback? onNavigateToNotificationsTab;

  const CustomAppBar({
    super.key,
    this.title = 'Staff',
    this.description,
    this.additionalActions,
    this.notificationCount = 0,
    this.onNavigateToNotificationsTab,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}

class _CustomAppBarState extends State<CustomAppBar> {
  String _username = 'User';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? 'User';
      setState(() => _username = username);
    } catch (e) {
      debugPrint('Error loading username: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Logout'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout successful !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false, // Xóa tất cả các màn hình khỏi stack
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      elevation: 2,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(
                width: 8,
              ), // Tạo khoảng cách giữa title và user info
              _isLoading
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : _buildUserInfo(theme),
            ],
          ),
          const SizedBox(height: 3),
          if (widget.description !=
              null) // Đặt phần mô tả dưới title và user info
            Text(
              widget.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimary.withOpacity(0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ).animate().fadeIn(duration: 400.ms),
        ],
      ),
      actions: [
        // Notification Bell icon with badge
        // Hiển thị bell icon chỉ khi không có back button
        badges.Badge(
          position: badges.BadgePosition.topEnd(top: 8, end: 8),
          showBadge: widget.notificationCount > 0,
          badgeContent: Text(
            widget.notificationCount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          badgeStyle: const badges.BadgeStyle(
            badgeColor: Color(0xFF6F61EF),
            padding: EdgeInsets.all(4),
          ),
          child: IconButton(
            icon: const Icon(LucideIcons.bell),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => CompactNotificationDialog(
                      onNavigateToNotificationsTab:
                          widget.onNavigateToNotificationsTab,
                    ),
              );
            },
          ),
        ),
        if (widget.additionalActions != null) ...widget.additionalActions!,
        IconButton(
          icon: const Icon(LucideIcons.logOut),
          tooltip: 'Logout',
          onPressed: _handleLogout,
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildUserInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.user, size: 16, color: theme.colorScheme.onPrimary),
          const SizedBox(width: 6),
          Text(
            _username,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2, end: 0);
  }
}
