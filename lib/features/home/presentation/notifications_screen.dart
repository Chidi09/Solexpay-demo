import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/api_service.dart';
import '../../../../mock/demo_app_state.dart';
import '../../../../shared/models/notification_item.dart';
import '../../../../shared/widgets/demo_device_shell.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final apiService = context.read<ApiService>();
      final res = await apiService.getNotifications(page: 0, size: 20);
      final data = res['data'] as Map<String, dynamic>? ?? {};
      final list = data['content'] as List<dynamic>? ?? [];

      final List<NotificationItem> items = list.map((item) {
        final Map<String, dynamic> map = item as Map<String, dynamic>;
        return NotificationItem(
          id: map['id'] as String? ?? '',
          title: map['subject'] as String? ?? 'Notification',
          message: map['message'] as String? ?? '',
          createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : DateTime.now(),
          isUnread: map['readAt'] == null,
        );
      }).toList();

      if (mounted) {
        context.read<DemoAppState>().replaceNotifications(items);
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      final apiService = context.read<ApiService>();
      await apiService.markNotificationAsRead(id);
      await _loadNotifications();
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final DemoAppState appState = context.watch<DemoAppState>();
    final List<NotificationItem> notifications = appState.notifications;

    return Scaffold(
      body: DemoDeviceShell(
        child: Scaffold(
          backgroundColor: AppColors.shell,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadNotifications,
              color: AppColors.accent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Header with back button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 6, 16, 0),
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          onPressed: () => context.go('/home'),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Notifications',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Stay on top of wallet and savings activity.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // List
                  Expanded(
                    child: notifications.isEmpty
                        ? const Center(
                            child: Text(
                              'No notifications yet.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: notifications.length,
                            itemBuilder: (BuildContext context, int index) {
                              final NotificationItem item = notifications[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: GestureDetector(
                                  onTap: item.isUnread ? () => _markAsRead(item.id) : null,
                                  child: _NotifTile(item: item),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.item});
  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: item.isUnread
            ? AppColors.accentSoft.withValues(alpha: 0.45)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isUnread
              ? AppColors.accent.withValues(alpha: 0.25)
              : AppColors.outline.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.isUnread
                  ? AppColors.accentSoft
                  : AppColors.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item.isUnread
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              color: item.isUnread ? AppColors.accent : AppColors.textSecondary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: item.isUnread
                              ? FontWeight.w700
                              : FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd MMM').format(item.createdAt),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.message,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          if (item.isUnread) ...<Widget>[
            const SizedBox(width: 8),
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
