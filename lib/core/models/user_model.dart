class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // 'admin', 'cashier', 'manager'
  final String? phoneNumber;
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phoneNumber,
    this.avatarUrl,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'cashier',
      phoneNumber: map['phoneNumber'],
      avatarUrl: map['avatarUrl'],
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  // Copy with method for updates
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? phoneNumber,
    String? avatarUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, role: $role, isActive: $isActive)';
  }
}