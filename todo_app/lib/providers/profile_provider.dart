import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/models/profile.dart';

class ProfileProvider with ChangeNotifier {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  List<Profile> _profiles = [];

  List<Profile> get profiles => _profiles;

  Future<void> fetchUsers() async {
    final response = await _supabaseClient.from('profiles').select();
    _profiles =
        (response as List).map((data) => Profile.fromMap(data)).toList();
    notifyListeners();
  }

  Future<List<Profile>> fetchUsersByIds(List<String> profilesIds) async {
    final response = await _supabaseClient
        .from('profiles')
        .select()
        .inFilter('id', profilesIds);
    List<Profile> profiles =
        (response as List).map((data) => Profile.fromMap(data)).toList();
    print("\n\n\n");
    print(profiles);
    print("\n\n\n");
    return profiles;
  }

  Profile getProfile(String userId) {
    return _profiles.firstWhere((element) => element.id == userId);
  }
}
