import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

/// SolexPay App Header - Consistent across all screens
class AppHeader extends StatelessWidget {
  const AppHeader.home({super.key, this.onProfileTap, this.unreadCount = 0})
    : showBackButton = false,
      onBack = null,
      title = null,
      subtitle = null,
      trailing = null;

  const AppHeader.withBack({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
  }) : showBackButton = true,
       onProfileTap = null,
       unreadCount = 0;

  final bool showBackButton;
  final VoidCallback? onBack;
  final String? title;
  final String? subtitle;
  final Widget? trailing;

  // Home-specific
  final VoidCallback? onProfileTap;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    if (!showBackButton) {
      return _buildHomeHeader(context);
    }
    return _buildBackHeader(context);
  }

  Widget _buildHomeHeader(BuildContext context) {
    return Row(
      children: <Widget>[
        // Logo/Profile
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryFixed,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Brand name
        const Text(
          'SolexPay',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const Spacer(),
        // Notification bell
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: <Widget>[
                const Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackHeader(BuildContext context) {
    return Row(
      children: <Widget>[
        // Back button
        IconButton(
          onPressed:
              onBack ??
              () {
                if (Navigator.of(context).canPop()) {
                  context.pop();
                }
              },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.onSurface,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
        const SizedBox(width: 8),
        // Title section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (title != null)
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        // Optional trailing widget
        trailing ?? const SizedBox.shrink(),
      ],
    );
  }
}
