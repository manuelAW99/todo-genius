import 'package:flutter/material.dart';
import 'account.dart';
import 'projects.dart';
import '/models/profile.dart';
import 'package:provider/provider.dart';
import '/providers/profile_provider.dart';
import '/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late bool isProfileComplete;
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const ProjectsPage(),
    const AccountPage(),
  ];

  @override
  void initState() {
    super.initState();
    _checkUserProfile();
  }

  /// Handles navigation between the two tabs
  /// If the user tries to navigate to the Account tab without completing their profile,
  /// a snackbar will be displayed
  /// If the user tries to navigate to the Projects tab, the profile will be checked
  /// and if it is not complete, the user will be redirected to the Account tab
  /// and a snackbar will be displayed
  /// Otherwise, the user will be able to navigate to the Projects tab
  /// and the Account tab if their profile is complete
  void _onItemTapped(int index) async {
    if (_selectedIndex == index) {
      return;
    }
    if (_selectedIndex == 0) {
      setState(() {
        _selectedIndex = 1;
      });
    } else {
      await _checkUserProfile();
      setState(() {
        if (_selectedIndex == 1 && index == 0 && !isProfileComplete) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please complete your profile first.'),
            ),
          );
          return;
        }
        _selectedIndex = index;
      });
    }
  }

  /// Checks if the user has completed their profile
  Future<void> _checkUserProfile() async {
    final userId = supabase.auth.currentUser!.id;
    final profilesProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    await profilesProvider.fetchUsers();
    final profile = profilesProvider.profiles.firstWhere(
        (profile) => profile.id == userId,
        orElse: () => emptyProfile);
    if (profile.id == '' ||
        profile.username == '' ||
        profile.username == null) {
      _selectedIndex = 1;
      isProfileComplete = false;
    } else {
      isProfileComplete = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading profile'));
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Pro Genius',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color.fromARGB(255, 11, 171, 136),
                ),
              ),
            ),
            body: _pages[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Projects',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle),
                  label: 'Account',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.blue,
              onTap: _onItemTapped,
            ),
          );
        }
      },
    );
  }
}
