import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'screens/home/home_screen.dart';
import 'screens/tracker/tracker_screen.dart';
import 'screens/schedule/schedule_screen.dart';
import 'screens/alerts/alerts_screen.dart';
import 'screens/profiles/profile_screen.dart';
import 'services/location_service.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'models/user_model.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String? _focusBusId;

  // Cached once in initState (not read inside build) so this Stream keeps
  // a stable identity across rebuilds -- same reasoning as ProfileScreen's
  // _userStream: a fresh Stream instance on every build would make any
  // StreamBuilder listening to it flicker back to ConnectionState.waiting.
  Stream<UserModel>? _userStream;

  @override
  void initState() {
    super.initState();
    _seedLocationsIfNeeded();
    final uid = AuthService().currentUser?.uid;
    if (uid != null) {
      _userStream = UserService().getUserStream(uid);
    }
  }

  Future<void> _seedLocationsIfNeeded() async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('liveLocations')
          .get();

      if (!snapshot.exists) {
        debugPrint('🔄 No live locations found, seeding sample data...');
        await LocationService().seedSampleBusLocations();
      } else {
        debugPrint('✅ Live locations already exist, skipping seed');
      }
    } catch (e) {
      debugPrint('❌ Error checking liveLocations: $e');
    }
  }

  void _goToTracker({String? busId}) {
    setState(() {
      _currentIndex = 1; // Tracker tab
      _focusBusId = busId;
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      // reset the focus target whenever the user manually
      // navigates tabs, so it doesn't re-trigger on next Tracker visit
      if (index != 1) _focusBusId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel>(
      stream: _userStream,
      builder: (context, userSnapshot) {
        // Defaults to true (alerts visible) while the user doc is still
        // loading or if there's no logged-in user -- only flips to the
        // empty state once we know for sure the switch is off.
        final alertsEnabled = userSnapshot.data?.notificationsEnabled ?? true;

        final screens = [
          HomeScreen(
            onSeeMap: () => _goToTracker(),
            onBusTap: (busId) => _goToTracker(busId: busId),
            notificationsEnabled: alertsEnabled,
            onSeeAlerts: () => _onTabTapped(3),
          ),
          TrackerScreen(focusBusId: _focusBusId),
          const ScheduleScreen(),
          AlertsScreen(alertsEnabled: alertsEnabled),
          ProfileScreen(onSeeAlerts: () => _onTabTapped(3)),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map),
                label: 'Tracker',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'Schedule',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined),
                activeIcon: Icon(Icons.notifications),
                label: 'Alerts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}