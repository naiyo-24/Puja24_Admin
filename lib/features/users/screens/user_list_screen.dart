import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../models/user.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  String _searchQuery = '';

  void _showUserDialog(BuildContext context, AppUser user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.surfaceHighlight,
              backgroundImage: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty 
                ? NetworkImage(user.profileImageUrl!) 
                : null,
              onBackgroundImageError: (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty) ? (_, __) {} : null, // Catch 429 Too Many Requests
              child: user.profileImageUrl == null || user.profileImageUrl!.isEmpty
                  ? Text(user.fullName[0].toUpperCase(), style: const TextStyle(color: AppTheme.primaryColor))
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(user.email, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Phone Number'),
                subtitle: Text(user.phoneNumber ?? 'Not provided'),
              ),
              ListTile(
                leading: const Icon(Icons.verified_user),
                title: const Text('Role'),
                subtitle: Text(user.role.toUpperCase()),
              ),
              ListTile(
                leading: const Icon(Icons.stars),
                title: const Text('Puja Points'),
                subtitle: Text('${user.pujaPoints} pts'),
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('Ads Watched Today'),
                subtitle: Text('${user.adsWatchedToday}'),
              ),
              if (user.hasPujaPass)
                const ListTile(
                  leading: Icon(Icons.confirmation_number, color: Colors.green),
                  title: Text('VIP Pass Holder', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);

    final filteredUsers = userState.users.where((u) {
      final query = _searchQuery.toLowerCase();
      return u.fullName.toLowerCase().contains(query) ||
          u.email.toLowerCase().contains(query) ||
          (u.phoneNumber != null && u.phoneNumber!.toLowerCase().contains(query));
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(userProvider.notifier).fetchUsers(),
            tooltip: 'Refresh Users',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, or phone...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
              ),
              Expanded(
                child: userState.isLoading && userState.users.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : userState.error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    userState.error!,
                                    style: const TextStyle(color: AppTheme.primaryColor),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => ref.read(userProvider.notifier).fetchUsers(),
                                  child: const Text('Retry'),
                                )
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            onTap: () => _showUserDialog(context, user),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.surfaceHighlight,
                                backgroundImage: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty 
                                  ? NetworkImage(user.profileImageUrl!) 
                                  : null,
                                onBackgroundImageError: (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty) ? (_, __) {} : null, // Catch 429 Too Many Requests
                                child: user.profileImageUrl == null || user.profileImageUrl!.isEmpty
                                    ? Text(user.fullName[0].toUpperCase(), style: const TextStyle(color: AppTheme.primaryColor))
                                    : null,
                              ),
                              title: Text(
                              user.fullName,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.email),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _buildBadge(context, user.role.toUpperCase(), AppTheme.secondaryColor),
                                    const SizedBox(width: 8),
                                    if (user.hasPujaPass)
                                      _buildBadge(context, 'PASS HOLDER', Colors.green),
                                    const SizedBox(width: 8),
                                    Text('Pts: ${user.pujaPoints}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Switch(
                              value: user.isActive,
                              activeColor: AppTheme.primaryColor,
                              onChanged: (val) {
                                ref.read(userProvider.notifier).toggleUserStatus(user.id, user.isActive);
                              },
                            ),
                            ),
                          ),
                        );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
