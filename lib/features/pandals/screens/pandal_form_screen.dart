import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:dio/dio.dart' as dio;
import '../models/place.dart';
import '../providers/pandal_provider.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';

class PandalFormScreen extends ConsumerStatefulWidget {
  final Place? pandal;
  
  const PandalFormScreen({super.key, this.pandal});

  @override
  ConsumerState<PandalFormScreen> createState() => _PandalFormScreenState();
}

class _PandalFormScreenState extends ConsumerState<PandalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _zoneController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _gmapLinkController;
  
  // Art & History
  late TextEditingController _themeController;
  late TextEditingController _artistController;
  late TextEditingController _designerController;
  late TextEditingController _historyController;
  
  // Live Status
  late TextEditingController _queueController;
  String? _crowdStatus;
  String? _rainStatus;
  
  // Facilities
  late TextEditingController _nearestBusController;
  late TextEditingController _nearestCafeController;
  late TextEditingController _nearestHospitalController;
  late TextEditingController _nearestParkingController;
  late TextEditingController _toiletController;
  
  List<String> _amenities = [];
  
  late String _type;
  bool _isPopular = false;
  bool _isActive = true;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  List<String> _existingImages = [];
  bool _isDragging = false;

  final List<String> _placeTypes = ['pandal', 'restaurant', 'cafe', 'metro', 'parking', 'toilet'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pandal?.name ?? '');
    _addressController = TextEditingController(text: widget.pandal?.address ?? '');
    _zoneController = TextEditingController(text: widget.pandal?.zone ?? '');
    _latController = TextEditingController(text: widget.pandal?.latitude.toString() ?? '');
    _lngController = TextEditingController(text: widget.pandal?.longitude.toString() ?? '');
    _gmapLinkController = TextEditingController(text: widget.pandal?.gmapLink ?? '');
    _type = widget.pandal?.type ?? 'pandal';
    _isPopular = widget.pandal?.isPopular ?? false;
    _isActive = widget.pandal?.isActive ?? true;
    _existingImages = List.from(widget.pandal?.imageUrls ?? []);
    
    _themeController = TextEditingController(text: widget.pandal?.theme2026 ?? '');
    _artistController = TextEditingController(text: widget.pandal?.idolArtist ?? '');
    _designerController = TextEditingController(text: widget.pandal?.pandalDesigner ?? '');
    _historyController = TextEditingController(text: widget.pandal?.historySummary ?? '');
    
    _queueController = TextEditingController(text: widget.pandal?.queueTimeMins?.toString() ?? '');
    _crowdStatus = widget.pandal?.crowdStatus;
    _rainStatus = widget.pandal?.rainStatus;
    
    _nearestBusController = TextEditingController(text: widget.pandal?.nearestBusStop ?? '');
    _nearestCafeController = TextEditingController(text: widget.pandal?.nearestCafe ?? '');
    _nearestHospitalController = TextEditingController(text: widget.pandal?.nearestHospital ?? '');
    _nearestParkingController = TextEditingController(text: widget.pandal?.nearestParking ?? '');
    _toiletController = TextEditingController(text: widget.pandal?.payAndUseToilet ?? '');
    
    _amenities = List.from(widget.pandal?.amenities ?? []);
  }

  Future<void> _pickImages() async {
    final int maxAllowed = 5 - (_existingImages.length + _selectedImages.length);
    if (maxAllowed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maximum 5 images allowed.')));
      return;
    }
    
    try {
      final List<XFile> picked = await _picker.pickMultiImage();
      if (picked.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(picked.take(maxAllowed));
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking images: $e')));
    }
  }

  Future<List<String>> _uploadImages() async {
    if (_selectedImages.isEmpty) return _existingImages;
    
    List<String> newUrls = [];
    final dioClient = ref.read(dioProvider);
    
    for (var file in _selectedImages) {
      try {
        final bytes = await file.readAsBytes();
        final formData = dio.FormData.fromMap({
          'file': dio.MultipartFile.fromBytes(bytes, filename: file.name),
        });
        
        final response = await dioClient.post(
          '/api/uploads/place_image', 
          data: formData,
          options: dio.Options(
            headers: {
              'Content-Type': 'multipart/form-data',
            },
          ),
        );
        
        // Extract URL safely
        final data = response.data;
        if (data is Map) {
          String returnedUrl = (data['url'] ?? data['file_url'] ?? data.values.first).toString();
          if (!returnedUrl.startsWith('http')) {
            returnedUrl = '${ApiConstants.baseUrl}$returnedUrl';
          }
          newUrls.add(returnedUrl);
        } else {
          String returnedUrl = data.toString();
          if (!returnedUrl.startsWith('http')) {
            returnedUrl = '${ApiConstants.baseUrl}$returnedUrl';
          }
          newUrls.add(returnedUrl);
        }
      } on dio.DioException catch (e) {
        debugPrint('Failed to upload image (DioException): ${e.message}');
        debugPrint('Backend response: ${e.response?.data}');
      } catch (e) {
        debugPrint('Failed to upload image: $e');
      }
    }
    
    // Ensure existing images are also absolute URLs
    final absoluteExistingImages = _existingImages.map((url) {
      if (!url.startsWith('http')) {
        return '${ApiConstants.baseUrl}$url';
      }
      return url;
    }).toList();
    
    return [...absoluteExistingImages, ...newUrls];
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    final place = Place(
      id: widget.pandal?.id ?? '',
      name: _nameController.text,
      type: _type,
      zone: _zoneController.text.isNotEmpty ? _zoneController.text : null,
      address: _addressController.text.isNotEmpty ? _addressController.text : null,
      latitude: double.tryParse(_latController.text) ?? 0.0,
      longitude: double.tryParse(_lngController.text) ?? 0.0,
      isPopular: _isPopular,
      isActive: _isActive,
      imageUrls: await _uploadImages(),
      theme2026: _themeController.text.isNotEmpty ? _themeController.text : null,
      idolArtist: _artistController.text.isNotEmpty ? _artistController.text : null,
      pandalDesigner: _designerController.text.isNotEmpty ? _designerController.text : null,
      historySummary: _historyController.text.isNotEmpty ? _historyController.text : null,
      queueTimeMins: int.tryParse(_queueController.text),
      crowdStatus: _crowdStatus,
      rainStatus: _rainStatus,
      nearestBusStop: _nearestBusController.text.isNotEmpty ? _nearestBusController.text : null,
      nearestCafe: _nearestCafeController.text.isNotEmpty ? _nearestCafeController.text : null,
      nearestHospital: _nearestHospitalController.text.isNotEmpty ? _nearestHospitalController.text : null,
      nearestParking: _nearestParkingController.text.isNotEmpty ? _nearestParkingController.text : null,
      payAndUseToilet: _toiletController.text.isNotEmpty ? _toiletController.text : null,
      gmapLink: _gmapLinkController.text.isNotEmpty ? _gmapLinkController.text : null,
      amenities: _amenities,
    );

    final notifier = ref.read(pandalProvider.notifier);
    bool success = false;
    
    if (widget.pandal == null) {
      success = await notifier.createPandal(place);
    } else {
      success = await notifier.updatePandal(place.id, place);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Success'),
              ],
            ),
            content: const Text('The place has been saved successfully!'),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  context.pop(); // Close form screen
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save pandal. Check inputs.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2), // Light cream background
      appBar: AppBar(
        title: Text(widget.pandal == null ? 'Add New Place' : 'Edit Place'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Place Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        
                        _buildImageGallery(),
                        const SizedBox(height: 32),
                        
                        Responsive.isDesktop(context) || Responsive.isTablet(context)
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildNameField()),
                                  const SizedBox(width: 24),
                                  Expanded(child: _buildTypeDropdown()),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildNameField(),
                                  const SizedBox(height: 16),
                                  _buildTypeDropdown(),
                                ],
                              ),
                        const SizedBox(height: 16),
                        
                        Responsive.isDesktop(context) || Responsive.isTablet(context)
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildAddressField()),
                                  const SizedBox(width: 24),
                                  Expanded(child: _buildZoneField()),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildAddressField(),
                                  const SizedBox(height: 16),
                                  _buildZoneField(),
                                ],
                              ),
                        
                        const SizedBox(height: 32),
                        Text('Coordinates', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildLatitudeField()),
                            const SizedBox(width: 24),
                            Expanded(child: _buildLongitudeField()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildGmapLinkField(),
                        
                        const SizedBox(height: 32),
                        Text('Status', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        
                        Container(
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: const Text('Popular Place', style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: const Text('Will be highlighted on the map', style: TextStyle(color: Colors.grey)),
                                value: _isPopular,
                                activeColor: AppTheme.secondaryColor,
                                onChanged: (val) => setState(() => _isPopular = val),
                              ),
                              const Divider(height: 1),
                              SwitchListTile(
                                title: const Text('Active Status', style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: const Text('Visible to end users', style: TextStyle(color: Colors.grey)),
                                value: _isActive,
                                activeColor: Colors.green,
                                onChanged: (val) => setState(() => _isActive = val),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        _buildArtAndHistoryCard(),
                        
                        const SizedBox(height: 32),
                        _buildLiveStatusCard(),
                        
                        const SizedBox(height: 32),
                        _buildNearbyFacilitiesCard(),
                        
                        const SizedBox(height: 32),
                        _buildAmenitiesCard(),
                        
                        const SizedBox(height: 48),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => context.pop(),
                              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                              child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: _isLoading 
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                                  : const Text('Save Place', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    final totalImages = _existingImages.length + _selectedImages.length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Images ($totalImages/5)', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: _isLoading ? null : _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Images'),
            )
          ],
        ),
        const SizedBox(height: 12),
        DropRegion(
          formats: Formats.standardFormats,
          onDropOver: (event) {
            if (!_isDragging) {
              setState(() {
                _isDragging = true;
              });
            }
            return DropOperation.copy;
          },
          onDropLeave: (event) {
            setState(() {
              _isDragging = false;
            });
          },
          onPerformDrop: (event) async {
            setState(() {
              _isDragging = false;
            });
            
            final maxAllowed = 5 - totalImages;
            if (maxAllowed <= 0) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maximum 5 images allowed')));
              return;
            }

            int addedCount = 0;
            for (final item in event.session.items) {
              if (addedCount >= maxAllowed) break;
              
              final reader = item.dataReader;
              if (reader == null) continue;

              void handleBytes(Uint8List? bytes, String name) {
                 if (bytes != null && mounted) {
                    setState(() {
                       _selectedImages.add(XFile.fromData(bytes, name: name));
                       addedCount++;
                    });
                 }
              }

              if (reader.canProvide(Formats.png)) {
                 reader.getFile(Formats.png, (file) async {
                    final bytes = await file.readAll();
                    handleBytes(bytes, 'image_\${DateTime.now().millisecondsSinceEpoch}.png');
                 });
              } else if (reader.canProvide(Formats.jpeg)) {
                 reader.getFile(Formats.jpeg, (file) async {
                    final bytes = await file.readAll();
                    handleBytes(bytes, 'image_\${DateTime.now().millisecondsSinceEpoch}.jpg');
                 });
              } else if (reader.canProvide(Formats.htmlText)) {
                 reader.getValue<String>(Formats.htmlText, (html) async {
                    if (html != null) {
                       final RegExp regex = RegExp(r'src="([^"]+)"');
                       final match = regex.firstMatch(html);
                       if (match != null && match.groupCount >= 1) {
                          final url = match.group(1);
                          if (url != null && (url.startsWith('http://') || url.startsWith('https://'))) {
                             try {
                                // Try downloading directly first
                                final response = await dio.Dio().get(url, options: dio.Options(responseType: dio.ResponseType.bytes));
                                handleBytes(response.data, 'image_\${DateTime.now().millisecondsSinceEpoch}.jpg');
                             } catch (e) {
                                // If it fails (likely due to CORS), try with a public proxy
                                try {
                                  final proxyUrl = 'https://api.allorigins.win/raw?url=\${Uri.encodeComponent(url)}';
                                  final response = await dio.Dio().get(proxyUrl, options: dio.Options(responseType: dio.ResponseType.bytes));
                                  handleBytes(response.data, 'image_\${DateTime.now().millisecondsSinceEpoch}.jpg');
                                } catch (proxyError) {
                                  debugPrint('Error downloading dropped html image via proxy: \$proxyError');
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load image. Please download it to your computer first.')));
                                }
                             }
                          }
                       }
                    }
                 });
              } else if (reader.canProvide(Formats.plainText)) {
                 reader.getValue<String>(Formats.plainText, (text) async {
                    if (text != null && (text.startsWith('http://') || text.startsWith('https://'))) {
                       try {
                          final response = await dio.Dio().get(text, options: dio.Options(responseType: dio.ResponseType.bytes));
                          handleBytes(response.data, 'image_\${DateTime.now().millisecondsSinceEpoch}.jpg');
                       } catch (e) {
                          try {
                            final proxyUrl = 'https://api.allorigins.win/raw?url=\${Uri.encodeComponent(text)}';
                            final response = await dio.Dio().get(proxyUrl, options: dio.Options(responseType: dio.ResponseType.bytes));
                            handleBytes(response.data, 'image_\${DateTime.now().millisecondsSinceEpoch}.jpg');
                          } catch (proxyError) {
                            debugPrint('Error downloading dropped url via proxy: \$proxyError');
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load image. Please download it to your computer first.')));
                          }
                       }
                    }
                 });
              }
            }
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: _isDragging 
                  ? Border.all(color: AppTheme.primaryColor, width: 2) 
                  : Border.all(color: Colors.transparent, width: 2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: totalImages == 0
                ? Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _isDragging ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.3), style: BorderStyle.solid),
                    ),
                    child: Center(
                      child: Text(
                        _isDragging ? 'Drop images here' : 'No images selected (Drag & drop here)', 
                        style: TextStyle(color: _isDragging ? AppTheme.primaryColor : Colors.grey)
                      ),
                    ),
                  )
                : SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ..._existingImages.asMap().entries.map((e) => _buildThumbnail(
                          url: e.value,
                          onRemove: () => setState(() => _existingImages.removeAt(e.key)),
                        )),
                        ..._selectedImages.asMap().entries.map((e) => _buildThumbnail(
                          xfile: e.value,
                          onRemove: () => setState(() => _selectedImages.removeAt(e.key)),
                        )),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail({String? url, XFile? xfile, required VoidCallback onRemove}) {
    return Stack(
      children: [
        if (url != null)
          Container(
            margin: const EdgeInsets.only(right: 12),
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                url.startsWith('http') ? url : '${ApiConstants.baseUrl}$url',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey, size: 40),
              ),
            ),
          )
        else if (xfile != null)
          FutureBuilder<Uint8List>(
            future: xfile.readAsBytes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: const Icon(Icons.error, color: Colors.red),
                );
              }
              return Container(
                margin: const EdgeInsets.only(right: 12),
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.insert_drive_file, color: Colors.grey, size: 40),
                        const SizedBox(height: 4),
                        Text(
                          xfile.name.length > 10 ? '${xfile.name.substring(0, 10)}...' : xfile.name,
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        Positioned(
          top: 4,
          right: 16,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black54),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: _inputDecoration('Place Name'),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      decoration: _inputDecoration('Full Address (Optional)'),
    );
  }

  Widget _buildZoneField() {
    return TextFormField(
      controller: _zoneController,
      decoration: _inputDecoration('Zone (e.g. South Kolkata)'),
    );
  }

  Widget _buildLatitudeField() {
    return TextFormField(
      controller: _latController,
      decoration: _inputDecoration('Latitude').copyWith(suffixIcon: const Icon(Icons.location_on, color: Colors.grey)),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (double.tryParse(value) == null) return 'Invalid number';
        return null;
      },
    );
  }

  Widget _buildLongitudeField() {
    return TextFormField(
      controller: _lngController,
      decoration: _inputDecoration('Longitude').copyWith(suffixIcon: const Icon(Icons.location_on, color: Colors.grey)),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (double.tryParse(value) == null) return 'Invalid number';
        return null;
      },
    );
  }

  Widget _buildGmapLinkField() {
    return TextFormField(
      controller: _gmapLinkController,
      decoration: _inputDecoration('Google Maps Link (Optional)')
          .copyWith(suffixIcon: const Icon(Icons.map, color: Colors.grey)),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _type,
      decoration: _inputDecoration('Place Type'),
      items: _placeTypes.map((type) => DropdownMenuItem(
        value: type,
        child: Text(type.toUpperCase()),
      )).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _type = val);
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.withValues(alpha: 0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1)),
    );
  }

  Widget _buildArtAndHistoryCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Art & History', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextFormField(controller: _themeController, decoration: _inputDecoration('Theme (2026)')),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: TextFormField(controller: _artistController, decoration: _inputDecoration('Idol Artist'))),
            const SizedBox(width: 16),
            Expanded(child: TextFormField(controller: _designerController, decoration: _inputDecoration('Pandal Designer'))),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _historyController, 
          decoration: _inputDecoration('History Summary'),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildLiveStatusCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Live Status', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _crowdStatus,
                decoration: _inputDecoration('Crowd Status'),
                items: ['Low', 'Moderate', 'High'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _crowdStatus = val),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _rainStatus,
                decoration: _inputDecoration('Rain Status'),
                items: ['Clear', 'Drizzle', 'Raining', 'Heavy rain'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _rainStatus = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _queueController,
          decoration: _inputDecoration('Queue Time (Mins)'),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildNearbyFacilitiesCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nearby Facilities', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: TextFormField(controller: _nearestBusController, decoration: _inputDecoration('Nearest Bus Stop'))),
            const SizedBox(width: 16),
            Expanded(child: TextFormField(controller: _nearestCafeController, decoration: _inputDecoration('Nearest Cafe'))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: TextFormField(controller: _nearestHospitalController, decoration: _inputDecoration('Nearest Hospital'))),
            const SizedBox(width: 16),
            Expanded(child: TextFormField(controller: _nearestParkingController, decoration: _inputDecoration('Nearest Parking'))),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(controller: _toiletController, decoration: _inputDecoration('Pay & Use Toilet (e.g. Near gate 2)')),
      ],
    );
  }

  Widget _buildAmenitiesCard() {
    final availableAmenities = ['VIP Entry', 'Wheelchair accessible', 'Food Stalls', 'Medical Camp', 'Drinking Water'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amenities', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableAmenities.map((amenity) {
            final isSelected = _amenities.contains(amenity);
            return FilterChip(
              label: Text(amenity),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _amenities.add(amenity);
                  } else {
                    _amenities.remove(amenity);
                  }
                });
              },
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }
}
