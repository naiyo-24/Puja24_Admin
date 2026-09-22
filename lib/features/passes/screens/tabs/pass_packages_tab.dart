import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/pass_package.dart';
import '../../notifiers/pass_notifier.dart';
import '../../../pandals/notifiers/pandal_notifier.dart';
import '../../../pandals/providers/pandal_provider.dart';

class PassPackagesTab extends ConsumerWidget {
  const PassPackagesTab({super.key});

  void _showPackageDialog(BuildContext context, WidgetRef ref, [PassPackage? package]) {
    final pandalState = ref.watch(pandalProvider);
    final titleController = TextEditingController(text: package?.title);
    final descriptionController = TextEditingController(text: package?.description);
    final priceController = TextEditingController(text: package?.price.toString());
    final capacityController = TextEditingController(text: package?.personCapacity.toString() ?? '3');
    final venueController = TextEditingController(text: package?.collectionVenue);
    final gmapLinkController = TextEditingController(text: package?.collectionVenueGmapLink);
    final venue2Controller = TextEditingController(text: package?.collectionVenue2);
    final gmapLink2Controller = TextEditingController(text: package?.collectionVenueGmapLink2);
    final noteController = TextEditingController(text: package?.collectionNote);
    bool isActive = package?.isActive ?? true;
    List<String> selectedPandalIds = List.from(package?.includedPandalIds ?? []);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(package == null ? 'Create Pass Package' : 'Edit Pass Package'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: capacityController,
                  decoration: const InputDecoration(labelText: 'Person Capacity (e.g. 3)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: venueController,
                  decoration: const InputDecoration(labelText: 'Collection Venue', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: gmapLinkController,
                  decoration: const InputDecoration(
                    labelText: 'Collection Venue Map URL (Google Maps Link)', 
                    border: OutlineInputBorder(),
                    hintText: 'https://goo.gl/maps/...',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: venue2Controller,
                  decoration: const InputDecoration(labelText: 'Collection Venue 2 (Optional)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: gmapLink2Controller,
                  decoration: const InputDecoration(
                    labelText: 'Collection Venue 2 Map URL', 
                    border: OutlineInputBorder(),
                    hintText: 'https://goo.gl/maps/...',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Important Note (e.g. N.B: Sunday Closed)', 
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Is Active'),
                  value: isActive,
                  onChanged: (val) => setState(() => isActive = val),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                const Text('Included Pandals', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (pandalState.pandals.isEmpty)
                  const Text('No pandals available. Please add pandals first.', style: TextStyle(color: Colors.grey))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: pandalState.pandals.where((p) => p.type == 'pandal').map((pandal) {
                      final isSelected = selectedPandalIds.contains(pandal.id);
                      return FilterChip(
                        label: Text(pandal.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              if (pandal.id != null) selectedPandalIds.add(pandal.id!);
                            } else {
                              selectedPandalIds.remove(pandal.id);
                            }
                          });
                        },
                        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                        checkmarkColor: AppTheme.primaryColor,
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newPackage = PassPackage(
                  id: package?.id,
                  title: titleController.text,
                  description: descriptionController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  personCapacity: int.tryParse(capacityController.text) ?? 3,
                  collectionVenue: venueController.text,
                  collectionVenueGmapLink: gmapLinkController.text.isNotEmpty ? gmapLinkController.text : null,
                  collectionVenue2: venue2Controller.text.isNotEmpty ? venue2Controller.text : null,
                  collectionVenueGmapLink2: gmapLink2Controller.text.isNotEmpty ? gmapLink2Controller.text : null,
                  collectionNote: noteController.text.isNotEmpty ? noteController.text : null,
                  isActive: isActive,
                  includedPandalIds: selectedPandalIds,
                );

                final success = package == null
                    ? await ref.read(passProvider.notifier).createPackage(newPackage)
                    : await ref.read(passProvider.notifier).updatePackage(package.id!, newPackage);

                if (success && ctx.mounted) {
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(passProvider);
    final pandalState = ref.watch(pandalProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Active Pass Offerings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('New Pass Package'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
                onPressed: () => _showPackageDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: state.packages.isEmpty
                ? const Center(child: Text('No pass packages found.'))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: state.packages.length,
                    itemBuilder: (context, index) {
                      final pkg = state.packages[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(pkg.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  ),
                                  Switch(
                                    value: pkg.isActive,
                                    activeColor: AppTheme.primaryColor,
                                    onChanged: (val) {
                                      // Toggle status logic
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('₹${pkg.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('Capacity: ${pkg.personCapacity} Persons', style: const TextStyle(color: Colors.grey)),
                              Text('Venue: ${pkg.collectionVenue}', style: const TextStyle(color: Colors.grey)),
                              if (pkg.collectionVenue2 != null)
                                Text('Venue 2: ${pkg.collectionVenue2}', style: const TextStyle(color: Colors.grey)),
                              if (pkg.collectionNote != null)
                                Text('Note: ${pkg.collectionNote}', style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                              if (pkg.includedPandalIds.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                const Text('Included Pandals:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 4),
                                Expanded(
                                  child: Text(
                                    pkg.includedPandalIds.map((id) {
                                      final match = pandalState.pandals.where((p) => p.id == id);
                                      return match.isNotEmpty ? match.first.name : 'Unknown Pandal';
                                    }).join(' • '),
                                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ] else
                                const Spacer(),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: TextButton.icon(
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit'),
                                  onPressed: () => _showPackageDialog(context, ref, pkg),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
