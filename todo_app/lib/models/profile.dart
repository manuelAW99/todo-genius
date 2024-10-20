class Profile {
  final String id;
  final Object updated_at;
  final String username;
  final String? full_name;
  final String avatar_url;
  final String website;

  Profile({
    required this.id,
    required this.updated_at,
    required this.username,
    required this.full_name,
    required this.avatar_url,
    required this.website,
  });

  // Convert a User into a Map. The keys must correspond to the names of the
  // fields in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'updated_at': updated_at,
      'username': username,
      'full_name': full_name,
      'avatar_url': avatar_url,
      'website': website,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      updated_at: map['updated_at'],
      username: map['username'],
      full_name: map['full_name'],
      avatar_url: map['avatar_url'],
      website: map['website'],
    );
  }

  @override
  String toString() {
    return 'Profile {id: $id, name: $username, full_name: $full_name, avatar_url: $avatar_url, website: $website}';
  }
}
