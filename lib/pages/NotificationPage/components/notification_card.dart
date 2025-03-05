import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:siteplus_mb/utils/NotificationModel/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isCompact;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;

  const NotificationCard({
    super.key,
    required this.notification,
    this.isCompact = false,
    this.onTap,
    this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Container
            Align(
              alignment: const AlignmentDirectional(-1, -1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0x4D9489F5),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6F61EF), width: 2),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    LucideIcons.clipboardList,
                    color: Color(0xFF6F61EF),
                    size: 20,
                  ),
                ),
              ),
            ),

            // Content Column
            Flexible(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notification Header
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        0,
                        0,
                        0,
                        12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: RichText(
                              textScaler: MediaQuery.of(context).textScaler,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${notification.notificationName}: ',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: const Color(0xFF6F61EF),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: notification.description,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: const Color(0xFF15161E),
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' ${notification.taskId}',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Color(0xFF6F61EF),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Task Details Container
                    if (!isCompact || notification.taskDescription.isNotEmpty)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeInOut,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0x4D9489F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF6F61EF),
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Task Name
                              Text(
                                notification.taskName,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: const Color(0xFF6F61EF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              // Task Description
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                  0,
                                  4,
                                  0,
                                  0,
                                ),
                                child: Text(
                                  notification.taskDescription,
                                  style: theme.textTheme.labelMedium,
                                ),
                              ),

                              // City/District - only in full view
                              if (!isCompact &&
                                  notification.cityDistrict.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                    0,
                                    8,
                                    0,
                                    0,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        LucideIcons.mapPin,
                                        size: 14,
                                        color: Color(0xFF606A85),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        notification.cityDistrict,
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              color: const Color(0xFF606A85),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Deadline - only in full view
                              if (!isCompact &&
                                  notification.taskDeadline != null)
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                    0,
                                    8,
                                    0,
                                    0,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        LucideIcons.clock,
                                        size: 14,
                                        color: Color(0xFF606A85),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Hạn: ${DateFormat('dd/MM/yyyy').format(notification.taskDeadline!)}',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              color: const Color(0xFF606A85),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                    // Creation Date
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                      child: Text(
                        DateFormat(
                          'dd/MM/yyyy \'lúc\' HH:mm',
                        ).format(notification.createdAt),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: const Color(0xFF606A85),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
