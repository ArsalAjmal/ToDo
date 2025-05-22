class User {
  final int? id;
  final String name;
  final String? profileImageBase64;

  User({this.id, required this.name, this.profileImageBase64});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'profileImageBase64': profileImageBase64,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      profileImageBase64: map['profileImageBase64'] as String?,
    );
  }
}
