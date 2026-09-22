import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/pandal_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';

class PandalListScreen extends ConsumerStatefulWidget {
  const PandalListScreen({super.key});

  @override
  ConsumerState<PandalListScreen> createState() => _PandalListScreenState();
}

class _PandalListScreenState extends ConsumerState<PandalListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final pandalState = ref.watch(pandalProvider);
    final filteredPandals = pandalState.pandals.where((p) {
      if (p.type.toLowerCase() != 'pandal') return false;
      
      final query = _searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(query) ||
          (p.zone?.toLowerCase().contains(query) ?? false);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2), // Light cream background
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: pandalState.isLoading && pandalState.pandals.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                    : pandalState.error != null
                        ? _buildErrorState(pandalState.error!)
                        : _buildDataTable(context, filteredPandals),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Pandals & Places',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.black),
                tooltip: 'Refresh Data',
                onPressed: () {
                  ref.read(pandalProvider.notifier).fetchPandals();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Refreshing data...'), duration: Duration(seconds: 1)),
                  );
                },
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => context.push('/pandals/new'),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add New Pandal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.primaryColor),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: AppTheme.primaryColor)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(pandalProvider.notifier).fetchPandals(),
            child: const Text('Retry'),
          )
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, List<dynamic> pandals) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, zone or type...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 24),
            // Data Table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                columns: const [
                  DataColumn(label: SizedBox(width: 100, child: Text('Name'))),
                  DataColumn(label: SizedBox(width: 80, child: Text('Type'))),
                  DataColumn(label: SizedBox(width: 100, child: Text('Zone'))),
                  DataColumn(label: SizedBox(width: 80, child: Text('Status'))),
                  DataColumn(label: SizedBox(width: 80, child: Text('Popular'))),
                  DataColumn(label: SizedBox(width: 100, child: Text('Actions'))),
                ],
                rows: pandals.map((pandal) {
                  return DataRow(
                    cells: [
                      DataCell(Text(pandal.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(
                        FittedBox(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                            child: Text(pandal.type.toUpperCase(), style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: bold)),
                          ),
                        )
                      ),
                      DataCell(Text(pandal.zone ?? 'N/A')),
                      DataCell(
                        FittedBox(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: (pandal.isActive ? Colors.green : Colors.grey).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                            child: Text(pandal.isActive ? 'Active' : 'Inactive', style: TextStyle(color: pandal.isActive ? Colors.green : Colors.grey, fontSize: 12, fontWeight: bold)),
                          ),
                        )
                      ),
                      DataCell(
                        Icon(pandal.isPopular ? Icons.star : Icons.star_border, color: pandal.isPopular ? Colors.orange : Colors.grey, size: 20)
                      ),
                      DataCell(FittedBox(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                              tooltip: 'Edit',
                              onPressed: () => context.push('/pandals/edit', extra: pandal),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppTheme.primaryColor),
                              tooltip: 'Delete',
                              onPressed: () => _showDeleteDialog(context, pandal.id),
                            ),
                          ],
                        ),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Place?'),
        content: const Text('Are you sure you want to deactivate this place? This action will hide it from the map.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              ref.read(pandalProvider.notifier).deletePandal(id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

const bold = FontWeight.bold;
