
/// User entity representing a user in the system
class UserEntity {
  /// User ID
  final String id;

  /// User email
  final String email;

  /// User display name
  final String? displayName;

  /// User photo URL
  final String? photoUrl;

  /// Constructor
  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  /// Equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UserEntity &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl;
  }

  /// Hash code
  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        photoUrl.hashCode;
  }

  /// String representation
  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, displayName: $displayName, photoUrl: $photoUrl)';
  }
}