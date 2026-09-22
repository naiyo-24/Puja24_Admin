class PassPackage {
  final String? id;
  final String title;
  final String? description;
  final double price;
  final int personCapacity;
  final String collectionVenue;
  final String? collectionVenueGmapLink;
  final String? collectionVenue2;
  final String? collectionVenueGmapLink2;
  final String? collectionNote;
  final bool isActive;
  final String? createdAt;
  final List<String> includedPandalIds;

  PassPackage({
    this.id,
    required this.title,
    this.description,
    required this.price,
    this.personCapacity = 3,
    required this.collectionVenue,
    this.collectionVenueGmapLink,
    this.collectionVenue2,
    this.collectionVenueGmapLink2,
    this.collectionNote,
    this.isActive = true,
    this.createdAt,
    this.includedPandalIds = const [],
  });

  factory PassPackage.fromJson(Map<String, dynamic> json) {
    return PassPackage(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0.0).toDouble(),
      personCapacity: json['person_capacity'] ?? 3,
      collectionVenue: json['collection_venue'] ?? '',
      collectionVenueGmapLink: json['collection_venue_gmap_link'],
      collectionVenue2: json['collection_venue_2'],
      collectionVenueGmapLink2: json['collection_venue_gmap_link_2'],
      collectionNote: json['collection_note'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'],
      includedPandalIds: (json['included_pandal_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'price': price,
      'person_capacity': personCapacity,
      'collection_venue': collectionVenue,
      'collection_venue_gmap_link': collectionVenueGmapLink,
      'collection_venue_2': collectionVenue2,
      'collection_venue_gmap_link_2': collectionVenueGmapLink2,
      'collection_note': collectionNote,
      'is_active': isActive,
      'included_pandal_ids': includedPandalIds,
    };
  }
}
