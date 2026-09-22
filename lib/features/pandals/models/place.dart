class Place {
  final String id;
  final String name;
  final String type;
  final String? subCategory;
  final String? zone;
  final String? address;
  final String? nearestMetro;
  final String? contactPhone;
  final double latitude;
  final double longitude;
  final bool isPopular;
  final bool isActive;
  final List<String> imageUrls;
  final int totalReviews;
  final int visits;
  
  // Metadata fields
  final String? theme2026;
  final String? idolArtist;
  final String? pandalDesigner;
  final String? historySummary;
  final String? crowdStatus;
  final int? queueTimeMins;
  final String? rainStatus;
  final String? nearestBusStop;
  final String? nearestCafe;
  final String? nearestHospital;
  final String? nearestParking;
  final String? payAndUseToilet;
  final String? gmapLink;
  final List<String> amenities;

  Place({
    required this.id,
    required this.name,
    required this.type,
    this.subCategory,
    this.zone,
    this.address,
    this.nearestMetro,
    this.contactPhone,
    required this.latitude,
    required this.longitude,
    required this.isPopular,
    required this.isActive,
    this.totalReviews = 0,
    this.visits = 0,
    this.imageUrls = const [],
    this.theme2026,
    this.idolArtist,
    this.pandalDesigner,
    this.historySummary,
    this.crowdStatus,
    this.queueTimeMins,
    this.rainStatus,
    this.nearestBusStop,
    this.nearestCafe,
    this.nearestHospital,
    this.nearestParking,
    this.payAndUseToilet,
    this.gmapLink,
    this.amenities = const [],
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    final meta = json['place_metadata'] as Map<String, dynamic>? ?? {};
    final imagesList = meta['images'] as List<dynamic>?;
    final amenitiesList = meta['amenities'] as List<dynamic>?;
    
    return Place(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      type: json['type'] ?? 'pandal',
      subCategory: json['sub_category'],
      zone: json['zone'],
      address: json['address'],
      nearestMetro: json['nearest_metro'],
      contactPhone: json['contact_phone'],
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      isPopular: json['is_popular'] ?? false,
      isActive: json['is_active'] ?? true,
      totalReviews: json['total_reviews'] ?? 0,
      visits: json['visits'] ?? 0,
      imageUrls: imagesList?.map((e) => e.toString()).toList() ?? [],
      theme2026: meta['theme2026'],
      idolArtist: meta['idolArtist'],
      pandalDesigner: meta['pandalDesigner'],
      historySummary: meta['historySummary'],
      crowdStatus: meta['crowdStatus'],
      queueTimeMins: meta['queueTimeMins'],
      rainStatus: meta['rainStatus'],
      nearestBusStop: meta['nearestBusStop'],
      nearestCafe: meta['nearestCafe'],
      nearestHospital: meta['nearestHospital'],
      nearestParking: meta['nearestParking'],
      payAndUseToilet: meta['payAndUseToilet'],
      gmapLink: meta['gmapLink'],
      amenities: amenitiesList?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'sub_category': subCategory,
      'zone': zone,
      'address': address,
      'nearest_metro': nearestMetro,
      'contact_phone': contactPhone,
      'latitude': latitude,
      'longitude': longitude,
      'is_popular': isPopular,
      'is_active': isActive,
      'total_reviews': totalReviews,
      'visits': visits,
      'place_metadata': {
        if (imageUrls.isNotEmpty) 'images': imageUrls,
        if (theme2026 != null) 'theme2026': theme2026,
        if (idolArtist != null) 'idolArtist': idolArtist,
        if (pandalDesigner != null) 'pandalDesigner': pandalDesigner,
        if (historySummary != null) 'historySummary': historySummary,
        if (crowdStatus != null) 'crowdStatus': crowdStatus,
        if (queueTimeMins != null) 'queueTimeMins': queueTimeMins,
        if (rainStatus != null) 'rainStatus': rainStatus,
        if (nearestBusStop != null) 'nearestBusStop': nearestBusStop,
        if (nearestCafe != null) 'nearestCafe': nearestCafe,
        if (nearestHospital != null) 'nearestHospital': nearestHospital,
        if (nearestParking != null) 'nearestParking': nearestParking,
        if (payAndUseToilet != null) 'payAndUseToilet': payAndUseToilet,
        if (gmapLink != null) 'gmapLink': gmapLink,
        if (amenities.isNotEmpty) 'amenities': amenities,
      },
    };
  }
}
