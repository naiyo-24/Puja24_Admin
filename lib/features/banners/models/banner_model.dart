class BannerModel {
  final String id;
  final String imageUrl;
  final String? linkUrl;
  final bool isActive;
  final String createdAt;

  BannerModel({
    required this.id,
    required this.imageUrl,
    this.linkUrl,
    this.isActive = true,
    required this.createdAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      imageUrl: json['image_url'],
      linkUrl: json['link_url'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'link_url': linkUrl,
      'is_active': isActive,
      'created_at': createdAt,
    };
  }
}
