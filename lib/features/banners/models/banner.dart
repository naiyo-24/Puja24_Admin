class AppBanner {
  final String id;
  final String title;
  final String? subtitle;
  final String bannerType;
  final String imageUrl;
  final String actionType;
  final String? actionPayload;
  final int displayOrder;
  final bool isActive;

  AppBanner({
    required this.id,
    required this.title,
    this.subtitle,
    required this.bannerType,
    required this.imageUrl,
    required this.actionType,
    this.actionPayload,
    required this.displayOrder,
    required this.isActive,
  });

  factory AppBanner.fromJson(Map<String, dynamic> json) {
    return AppBanner(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      bannerType: json['banner_type'] ?? 'hero_carousel',
      imageUrl: json['image_url'] ?? '',
      actionType: json['action_type'] ?? 'none',
      actionPayload: json['action_payload'],
      displayOrder: json['display_order'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'banner_type': bannerType,
      'image_url': imageUrl,
      'action_type': actionType,
      'action_payload': actionPayload,
      'display_order': displayOrder,
      'is_active': isActive,
    };
  }
}
