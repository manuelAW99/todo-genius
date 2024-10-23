import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/models/profile.dart';

class ProfileProvider with ChangeNotifier {
  final SupabaseClient supabaseClient;
  List<Profile> _profiles = [];

  List<Profile> get profiles => _profiles;

  ProfileProvider(this.supabaseClient);

  /// Fetches all user profiles from the database.
  /// @return A boolean indicating whether the profiles were successfully fetched.
  Future<bool> fetchUsers() async {
    try {
      final response = await supabaseClient.from('profiles').select();
      _profiles =
          (response as List).map((data) => Profile.fromMap(data)).toList();
      notifyListeners();
      return true;
    } catch (error) {
      return false;
    }
  }

  /// Fetches user profiles by their IDs from the database.
  /// [profilesIds] The IDs of the profiles to be fetched.
  /// @return A list of profiles with the specified IDs.
  Future<List<Profile>> fetchUsersByIds(List<String> profilesIds) async {
    final response = await supabaseClient
        .from('profiles')
        .select()
        .inFilter('id', profilesIds);
    List<Profile> profiles =
        (response as List).map((data) => Profile.fromMap(data)).toList();
    return profiles;
  }

  /// Fetches a specific profile by its ID from the local list of profiles.
  /// [userId] The ID of the profile to be fetched.
  /// @return The profile object with the specified ID.
  Profile getProfile(String userId) {
    return _profiles.firstWhere((element) => element.id == userId);
  }
}
