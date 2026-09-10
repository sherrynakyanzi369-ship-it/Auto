class AppUser {
  final String uid;
  final String name;
  final String email;
  final String phone;

  const AppUser({
    this.uid = '',
    required this.name,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        uid: json['uid'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
      );
}