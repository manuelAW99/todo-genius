/// Profile model class.
/// Used to store user profile information.
class Profile {
  final String id;
  final Object? updated_at;
  final String? username;
  final String? full_name;
  final String? avatar_url;
  final String? email;

  Profile({
    required this.id,
    required this.updated_at,
    required this.username,
    required this.full_name,
    required this.avatar_url,
    required this.email,
  });

  /// Convert a profile object to a map.
  /// The map is used to store the profile in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'updated_at': updated_at,
      'username': username,
      'full_name': full_name,
      'avatar_url': avatar_url,
      'email': email,
    };
  }

  /// Convert a map to a profile object.
  /// The map is used to store the profile in the database.
  factory Profile.fromMap(Map<String, dynamic> map) {
    final profile = Profile(
      id: map['id'],
      updated_at: map['updated_at'],
      username: map['username'],
      full_name: map['full_name'],
      avatar_url: map['avatar_url'],
      email: map['email'],
    );
    return profile;
  }

  /// Override the toString method to give a string representation of the profile object.
  @override
  String toString() {
    return 'Profile {id: $id, name: $username, full_name: $full_name, avatar_url: $avatar_url}';
  }
}

/// An empty profile object.
/// Used to check if the user has a profile or not.
Profile emptyProfile = Profile(
  id: '',
  updated_at: '',
  username: '',
  full_name: '',
  avatar_url: '',
  email: '',
);
