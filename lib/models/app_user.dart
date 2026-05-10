class AppUser {
  final String id;

  final String name;

  final String email;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
  });

  factory AppUser.fromRecord(dynamic record) {
    return AppUser(
      id: record.id,
      name:
          (record.data['name'] ?? '')
              .toString(),
      email:
          (record.data['email'] ?? '')
              .toString(),
    );
  }
}