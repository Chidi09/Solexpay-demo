class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.tag,
    required this.phoneNumber,
    required this.school,
    required this.accountNumber,
    required this.walletId,
  });

  final String id;
  final String fullName;
  final String tag;
  final String phoneNumber;
  final String school;
  final String accountNumber;
  final String walletId;
}
