class AppUser {
  final String id;
  final String email;
  final String fullName;
  final String? profileImageUrl;
  final String? phoneNumber;
  final String role;
  final bool isActive;
  final int pujaPoints;
  final bool hasPujaPass;
  final int adsWatchedToday;

  AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.profileImageUrl,
    this.phoneNumber,
    required this.role,
    required this.isActive,
    required this.pujaPoints,
    required this.hasPujaPass,
    required this.adsWatchedToday,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? 'Unknown',
      profileImageUrl: json['profile_image_url'],
      phoneNumber: json['phone_number'],
      role: json['role'] ?? 'customer',
      isActive: json['is_active'] ?? true,
      pujaPoints: json['puja_points'] ?? 0,
      hasPujaPass: json['has_puja_pass'] ?? false,
      adsWatchedToday: json['ads_watched_today'] ?? 0,
    );
  }
}
