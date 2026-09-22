import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/user_voucher.dart';
import '../../notifiers/pass_notifier.dart';

class PurchasersTab extends ConsumerWidget {
  const PurchasersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(passProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text('Error: ${state.error}', style: const TextStyle(color: Colors.red)));
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Purchased Passes & Redemptions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                ],
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                  columns: const [
                    DataColumn(label: Text('Purchaser', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Pass Type', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Voucher Code', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Redeemed At', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Purchase Date', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: state.vouchers.map((voucher) {
                    return DataRow(
                      cells: [
                        DataCell(Text(voucher.userName ?? 'Unknown')),
                        DataCell(Text(voucher.userPhone ?? '-')),
                        DataCell(Text(voucher.packageTitle ?? '-')),
                        DataCell(Text(voucher.voucherCode, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: voucher.status == 'redeemed' ? Colors.blue[100] : Colors.green[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              voucher.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: voucher.status == 'redeemed' ? Colors.blue[800] : Colors.green[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(
                          voucher.redeemedAt != null 
                            ? DateFormat('MMM d, yyyy h:mm a').format(DateTime.parse(voucher.redeemedAt!))
                            : '-',
                        )),
                        DataCell(Text(
                          DateFormat('MMM d, yyyy h:mm a').format(DateTime.parse(voucher.createdAt))
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
