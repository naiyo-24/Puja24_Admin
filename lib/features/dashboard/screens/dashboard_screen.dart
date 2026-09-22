import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../search/global_search_delegate.dart';
import '../../users/models/user.dart';
import '../../../core/utils/responsive.dart';
import '../../users/providers/user_provider.dart';
import '../../pandals/providers/pandal_provider.dart';
import '../../passes/notifiers/pass_notifier.dart';
import '../../passes/models/user_voucher.dart';
import '../../passes/models/pass_package.dart';
import '../../pandals/models/place.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final pandalState = ref.watch(pandalProvider);
    final passState = ref.watch(passProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2), // Light cream background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(
                context,
                userState.users,
                pandalState.pandals,
                passState.vouchers,
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildWelcomeBanner(context),
                    const SizedBox(height: 24),
                    _buildStatCards(
                      context, 
                      userState.users.length, 
                      passState.packages.length, 
                      pandalState.pandals.where((p) => p.type.toLowerCase() == 'pandal').length, 
                      passState.vouchers.length,
                      passState.packages,
                      passState.vouchers,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildBookingsChart(context, passState.vouchers)),
                        const SizedBox(width: 24),
                        Expanded(flex: 1, child: _buildPassUsageChart(context, passState.vouchers)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildRecentBookings(context, passState.vouchers)),
                        const SizedBox(width: 24),
                        Expanded(flex: 1, child: _buildTopPandals(context, pandalState.pandals)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, List<AppUser> users, List<Place> pandals, List<UserVoucher> vouchers) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Search Bar
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                readOnly: true,
                onTap: () {
                  showSearch(
                    context: context,
                    delegate: GlobalSearchDelegate(
                      users: users,
                      pandals: pandals,
                      vouchers: vouchers,
                    ),
                  );
                },
                decoration: const InputDecoration(
                  hintText: 'Search pandals, users, bookings...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // User Profile
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: Text('A', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Administrator', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text('Admin', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFFAF5ED),
        image: const DecorationImage(
          image: AssetImage('assets/images/durga_maa_banner.jpg'),
          fit: BoxFit.cover,
          alignment: Alignment.centerRight,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [const Color(0xFFFAF5ED), const Color(0xFFFAF5ED).withValues(alpha: 0.6), Colors.transparent],
            stops: const [0.4, 0.6, 1.0],
          ),
        ),
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome Back, Sayar!', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 32)),
            const SizedBox(height: 8),
            Text('Manage pandals, passes and create a seamless Puja experience for everyone.', 
                 style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, int totalUsers, int totalPasses, int totalPandals, int totalBookings, List<PassPackage> packages, List<UserVoucher> vouchers) {
    
    String _calcChange(int thisWeek, int lastWeek) {
      if (lastWeek == 0) return thisWeek > 0 ? '+100%' : '0%';
      final pct = ((thisWeek - lastWeek) / lastWeek * 100).round();
      return pct > 0 ? '+$pct%' : '$pct%';
    }

    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    final twoWeeksAgo = now.subtract(const Duration(days: 14));

    int passesThisWeek = packages.where((p) => p.createdAt != null && DateTime.tryParse(p.createdAt!)?.isAfter(oneWeekAgo) == true).length;
    int passesLastWeek = packages.where((p) => p.createdAt != null && DateTime.tryParse(p.createdAt!)?.isAfter(twoWeeksAgo) == true && DateTime.tryParse(p.createdAt!)?.isBefore(oneWeekAgo) == true).length;
    
    int bookingsThisWeek = vouchers.where((v) => v.createdAt.isNotEmpty && DateTime.tryParse(v.createdAt)?.isAfter(oneWeekAgo) == true).length;
    int bookingsLastWeek = vouchers.where((v) => v.createdAt.isNotEmpty && DateTime.tryParse(v.createdAt)?.isAfter(twoWeeksAgo) == true && DateTime.tryParse(v.createdAt)?.isBefore(oneWeekAgo) == true).length;

    return Row(
      children: [
        Expanded(child: _buildSingleStatCard('Total Users', totalUsers.toString(), null, Icons.people_alt_rounded, AppTheme.primaryColor)),
        const SizedBox(width: 16),
        Expanded(child: _buildSingleStatCard('Total Passes', totalPasses.toString(), _calcChange(passesThisWeek, passesLastWeek), Icons.confirmation_number_rounded, AppTheme.secondaryColor)),
        const SizedBox(width: 16),
        Expanded(child: _buildSingleStatCard('Total Pandals', totalPandals.toString(), null, Icons.temple_hindu_rounded, Colors.blue)),
        const SizedBox(width: 16),
        Expanded(child: _buildSingleStatCard('Total Bookings', totalBookings.toString(), _calcChange(bookingsThisWeek, bookingsLastWeek), Icons.calendar_today_rounded, Colors.green)),
      ],
    );
  }

  Widget _buildSingleStatCard(String title, String value, String? change, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      color: color.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                if (change != null)
                  Row(
                    children: [
                      Icon(change.startsWith('-') ? Icons.arrow_downward : Icons.arrow_upward, size: 12, color: change == '0%' ? Colors.grey : (change.startsWith('-') ? Colors.red : Colors.green)),
                      Text('$change vs last week', style: TextStyle(fontSize: 12, color: change == '0%' ? Colors.grey : (change.startsWith('-') ? Colors.red : Colors.green))),
                    ],
                  )
                else
                  const SizedBox(height: 14), // Maintain height so all cards align perfectly
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsChart(BuildContext context, List<UserVoucher> vouchers) {
    final now = DateTime.now();
    final dates = List.generate(7, (i) => DateFormat('MMM d').format(now.subtract(Duration(days: 6 - i))));
    
    // Calculate real daily counts
    final dailyCounts = List<int>.filled(7, 0);
    for (var v in vouchers) {
      if (v.createdAt.isEmpty) continue;
      final dt = DateTime.tryParse(v.createdAt);
      if (dt == null) continue;
      
      final daysDiff = DateTime(now.year, now.month, now.day).difference(DateTime(dt.year, dt.month, dt.day)).inDays;
      if (daysDiff >= 0 && daysDiff < 7) {
        dailyCounts[6 - daysDiff]++;
      }
    }
    
    final spots = List.generate(7, (i) => FlSpot(i.toDouble(), dailyCounts[i].toDouble()));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bar_chart, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Bookings Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Last 7 Days', style: TextStyle(fontSize: 12)),
                )
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1, // Prevent overlapping labels by forcing interval to 1
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < dates.length) {
                            return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(dates[value.toInt()], style: const TextStyle(fontSize: 10, color: Colors.grey)));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppTheme.primaryColor,
                      barWidth: 2,
                      dotData: const FlDotData(show: true),
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

  Widget _buildPassUsageChart(BuildContext context, List<UserVoucher> vouchers) {
    int used = vouchers.where((v) => v.status == 'redeemed').length;
    int notUsed = vouchers.where((v) => v.status == 'issued').length;
    int expired = vouchers.where((v) => v.status == 'expired' || v.status == 'cancelled').length;
    int total = vouchers.length;

    double usedPct = total == 0 ? 0 : (used / total) * 100;
    double notUsedPct = total == 0 ? 0 : (notUsed / total) * 100;
    double expiredPct = total == 0 ? 0 : (expired / total) * 100;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.pie_chart, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Pass Usage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                  child: const Text('All Time', style: TextStyle(fontSize: 12)),
                )
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 150,
                    child: total == 0 
                      ? const Center(child: Text('No Data'))
                      : PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 50,
                        sections: [
                          PieChartSectionData(color: Colors.green, value: used.toDouble(), title: '', radius: 20),
                          PieChartSectionData(color: Colors.orange, value: notUsed.toDouble(), title: '', radius: 20),
                          PieChartSectionData(color: Colors.red, value: expired.toDouble(), title: '', radius: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendItem(color: Colors.green, label: 'Used', value: '$used (${usedPct.toStringAsFixed(0)}%)'),
                    const SizedBox(height: 16),
                    _LegendItem(color: Colors.orange, label: 'Not Used', value: '$notUsed (${notUsedPct.toStringAsFixed(0)}%)'),
                    const SizedBox(height: 16),
                    _LegendItem(color: Colors.red, label: 'Expired', value: '$expired (${expiredPct.toStringAsFixed(0)}%)'),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBookings(BuildContext context, List<UserVoucher> vouchers) {
    final recent = List<UserVoucher>.from(vouchers);
    recent.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return DateTime.parse(b.createdAt!).compareTo(DateTime.parse(a.createdAt!));
    });
    final displayVouchers = recent.take(5).toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.receipt_long_rounded, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Recent Bookings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                TextButton(style: TextButton.styleFrom(padding: EdgeInsets.zero), onPressed: () => context.go('/passes'), child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 16),
            if (displayVouchers.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: Text('No bookings found')),
              )
            else
              DataTable(
                headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                columns: const [
                  DataColumn(label: Text('Code')),
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Pass Type')),
                  DataColumn(label: Text('Booking Date')),
                  DataColumn(label: Text('Status')),
                ],
                rows: displayVouchers.map((v) {
                  final initial = v.userName?.isNotEmpty == true ? v.userName![0].toUpperCase() : '?';
                  final dateStr = v.createdAt != null ? DateFormat('d MMM yyyy, h:mm a').format(DateTime.parse(v.createdAt!)) : 'N/A';
                  final color = v.status == 'redeemed' ? Colors.grey : (v.status == 'issued' ? Colors.green : Colors.red);
                  
                  return DataRow(cells: [
                    DataCell(Text(v.voucherCode.length > 8 ? '${v.voucherCode.substring(0, 8)}...' : v.voucherCode)),
                    DataCell(Row(children: [CircleAvatar(radius: 12, child: Text(initial, style: const TextStyle(fontSize: 10))), const SizedBox(width: 8), Text(v.userName ?? 'Unknown')])),
                    DataCell(Text(v.packageTitle ?? 'Unknown Package')),
                    DataCell(Text(dateStr)),
                    DataCell(_StatusBadge(status: v.status.toUpperCase(), color: color)),
                  ]);
                }).toList(),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildTopPandals(BuildContext context, List<Place> pandals) {
    final sortedPandals = List<Place>.from(pandals.where((p) => p.type.toLowerCase() == 'pandal'));
    sortedPandals.sort((a, b) => b.visits.compareTo(a.visits));
    final top = sortedPandals.take(3).toList();
    final maxVisits = top.isNotEmpty ? (top.first.visits > 0 ? top.first.visits : 1) : 1;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bar_chart, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Top Pandals (by Visits)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                TextButton(style: TextButton.styleFrom(padding: EdgeInsets.zero), onPressed: () => context.go('/pandals'), child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 16),
            if (top.isEmpty)
              const Center(child: Text('No pandals found'))
            else
              ...List.generate(top.length, (index) {
                final p = top[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildPandalBar((index + 1).toString(), p.name, p.visits.toString(), p.visits / maxVisits),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildPandalBar(String rank, String name, String visits, double fraction) {
    return Row(
      children: [
        Text(rank, style: const TextStyle(color: Colors.grey)),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Text(name, overflow: TextOverflow.ellipsis),
        ),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Text(visits, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: fraction,
                  backgroundColor: Colors.grey[200],
                  color: AppTheme.primaryColor.withValues(alpha: fraction),
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  
  const _LegendItem({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        )
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  
  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
