class UserVoucher {
  final String id;
  final String userId;
  final String packageId;
  final String voucherCode;
  final String? paymentReference;
  final String status;
  final String? redeemedAt;
  final String? redeemedByCounter;
  final String createdAt;
  
  // Extra fields for Admin UI display (we'll fetch/mock these)
  final String? userName;
  final String? userPhone;
  final String? packageTitle;

  UserVoucher({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.voucherCode,
    this.paymentReference,
    required this.status,
    this.redeemedAt,
    this.redeemedByCounter,
    required this.createdAt,
    this.userName,
    this.userPhone,
    this.packageTitle,
  });

  factory UserVoucher.fromJson(Map<String, dynamic> json) {
    return UserVoucher(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      packageId: json['package_id'] ?? '',
      voucherCode: json['voucher_code'] ?? '',
      paymentReference: json['payment_reference'],
      status: json['status'] ?? 'issued',
      redeemedAt: json['redeemed_at'],
      redeemedByCounter: json['redeemed_by_counter'],
      createdAt: json['created_at'] ?? '',
      userName: json['user_name'], // the backend might not return this yet
      userPhone: json['user_phone'], 
      packageTitle: json['package_title'],
    );
  }
}
