import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../users/models/user.dart';
import '../../pandals/models/place.dart';
import '../../passes/models/user_voucher.dart';

class GlobalSearchDelegate extends SearchDelegate<String?> {
  final List<AppUser> users;
  final List<Place> pandals;
  final List<UserVoucher> vouchers;

  GlobalSearchDelegate({
    required this.users,
    required this.pandals,
    required this.vouchers,
  });

  @override
  String get searchFieldLabel => 'Search pandals, users, bookings...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Type to search...'));
    }
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final lowerQuery = query.toLowerCase();

    // Filter Users
    final matchedUsers = users.where((u) {
      return u.fullName.toLowerCase().contains(lowerQuery) ||
          u.email.toLowerCase().contains(lowerQuery) ||
          (u.phoneNumber != null && u.phoneNumber!.toLowerCase().contains(lowerQuery));
    }).toList();

    // Filter Pandals
    final matchedPandals = pandals.where((p) {
      return p.name.toLowerCase().contains(lowerQuery) ||
          p.type.toLowerCase().contains(lowerQuery) ||
          (p.zone != null && p.zone!.toLowerCase().contains(lowerQuery));
    }).toList();

    // Filter Bookings
    final matchedVouchers = vouchers.where((v) {
      return v.voucherCode.toLowerCase().contains(lowerQuery) ||
          (v.userName != null && v.userName!.toLowerCase().contains(lowerQuery)) ||
          (v.packageTitle != null && v.packageTitle!.toLowerCase().contains(lowerQuery));
    }).toList();

    if (matchedUsers.isEmpty && matchedPandals.isEmpty && matchedVouchers.isEmpty) {
      return const Center(child: Text('No results found.'));
    }

    return ListView(
      children: [
        if (matchedPandals.isNotEmpty) ...[
          _buildSectionHeader('Pandals (${matchedPandals.length})'),
          ...matchedPandals.map((p) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.temple_hindu_rounded)),
                title: Text(p.name),
                subtitle: Text('${p.type} • ${p.zone ?? "Unknown Zone"}'),
                onTap: () {
                  close(context, null);
                  context.go('/pandals');
                },
              )),
          const Divider(),
        ],
        if (matchedUsers.isNotEmpty) ...[
          _buildSectionHeader('Users (${matchedUsers.length})'),
          ...matchedUsers.map((u) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(u.fullName),
                subtitle: Text(u.email),
                onTap: () {
                  close(context, null);
                  context.go('/users');
                },
              )),
          const Divider(),
        ],
        if (matchedVouchers.isNotEmpty) ...[
          _buildSectionHeader('Bookings (${matchedVouchers.length})'),
          ...matchedVouchers.map((v) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.receipt_long_rounded)),
                title: Text(v.voucherCode),
                subtitle: Text('${v.userName ?? "Unknown"} • ${v.packageTitle ?? "Unknown Package"}'),
                trailing: Text(v.status.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                onTap: () {
                  close(context, null);
                  context.go('/passes');
                },
              )),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }
}
