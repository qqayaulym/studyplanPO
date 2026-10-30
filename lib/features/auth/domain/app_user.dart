/// Пайдаланушы (Entity №1). Байланыс: User 1 — N Task.
class AppUser {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
  });

  AppUser copyWith({String? name}) => AppUser(
        id: id,
        name: name ?? this.name,
        email: email,
        passwordHash: passwordHash,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory AppUser.fromMap(Map<dynamic, dynamic> m) => AppUser(
        id: m['id'] as String,
        name: m['name'] as String,
        email: m['email'] as String,
        passwordHash: m['passwordHash'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(m['createdAt'] as int),
      );
}
