import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

/// Page to display list of notifications
class NotificationsListPage extends StatefulWidget {
  const NotificationsListPage({super.key});

  @override
  State<NotificationsListPage> createState() => _NotificationsListPageState();
}

class _NotificationsListPageState extends State<NotificationsListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load notifications on init
    context.read<NotificationBloc>().add(const LoadNotifications(refresh: true));
    
    // Setup infinite scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<NotificationBloc>().add(const LoadMoreNotifications());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        elevation: 0,
        actions: [
          // Mark all as read button
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Marcar todas como leídas',
            onPressed: () {
              context.read<NotificationBloc>().add(const MarkAllNotificationsAsRead());
            },
          ),
          // Delete all button
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Eliminar todas',
            onPressed: () => _showDeleteAllDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AllNotificationsMarkedAsRead) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Todas las notificaciones marcadas como leídas'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AllNotificationsDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Todas las notificaciones eliminadas'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading && state is! NotificationsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(const LoadNotifications(refresh: true));
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                itemCount: state.hasMore 
                    ? state.notifications.length + 1 
                    : state.notifications.length,
                itemBuilder: (context, index) {
                  if (index >= state.notifications.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final notification = state.notifications[index];
                  return _buildNotificationCard(context, notification);
                },
              ),
            );
          }

          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes notificaciones',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las notificaciones aparecerán aquí',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationEntity notification) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: notification.isRead ? 0 : 2,
      color: notification.isRead ? Colors.grey[50] : Colors.white,
      child: InkWell(
        onTap: () => _onNotificationTap(context, notification),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon based on notification type
              _buildNotificationIcon(notification.type),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: notification.isRead 
                            ? FontWeight.normal 
                            : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Body
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Time and actions
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(notification.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        // Delete button
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: Colors.grey[600],
                          onPressed: () => _showDeleteDialog(context, notification),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Unread indicator
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.promotionNearby:
        icon = Icons.location_on;
        color = Colors.green;
        break;
      case NotificationType.promotionExpiring:
        icon = Icons.access_time;
        color = Colors.orange;
        break;
      case NotificationType.promotionNew:
        icon = Icons.new_releases;
        color = Colors.blue;
        break;
      case NotificationType.badgeUnlocked:
        icon = Icons.emoji_events;
        color = Colors.amber;
        break;
      case NotificationType.levelUp:
        icon = Icons.trending_up;
        color = Colors.purple;
        break;
      case NotificationType.commerceNew:
        icon = Icons.store;
        color = Colors.teal;
        break;
      case NotificationType.system:
        icon = Icons.info;
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('dd/MM/yy').format(dateTime);
    }
  }

  void _onNotificationTap(BuildContext context, NotificationEntity notification) {
    // Mark as read if not already
    if (!notification.isRead) {
      context.read<NotificationBloc>().add(MarkNotificationAsRead(notification.id));
    }

    // Handle navigation based on notification type and data
    // TODO: Implement navigation to relevant screens
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notificación: ${notification.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, NotificationEntity notification) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar notificación'),
        content: const Text('¿Estás seguro de que quieres eliminar esta notificación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<NotificationBloc>().add(DeleteNotification(notification.id));
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar todas'),
        content: const Text('¿Estás seguro de que quieres eliminar todas las notificaciones?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<NotificationBloc>().add(const DeleteAllNotifications());
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Eliminar todas', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Made with Bob