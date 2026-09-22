import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'tabs/pass_packages_tab.dart';
import 'tabs/purchasers_tab.dart';

class PassManagementScreen extends StatelessWidget {
  const PassManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F7F2),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: Colors.white,
            child: Row(
              children: [
                const Text(
                  'Pass Management',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TabBar(
                  isScrollable: true,
                  indicatorColor: AppTheme.primaryColor,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'VIP Pass Packages'),
                    Tab(text: 'Purchasers & Redemptions'),
                  ],
                ),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                PassPackagesTab(),
                PurchasersTab(),
              ],
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }
}
