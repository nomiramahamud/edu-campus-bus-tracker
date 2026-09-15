import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:bus_app/services/auth_service.dart';
import 'package:bus_app/services/user_service.dart';
import 'package:bus_app/services/route_service.dart';
import 'package:bus_app/models/user_model.dart';
import 'package:bus_app/models/route_model.dart';
import 'package:bus_app/screens/login_screen.dart';
import 'package:bus_app/screens/route_guide_screen.dart';

class ProfileScreen extends StatefulWidget {
  // Called when the Notifications row is tapped. MainScreen wires this to
  // switch the bottom nav bar over to the Alerts tab, so it always lands
  // on the same AlertsScreen instance the tab bar shows.
  final VoidCallback? onSeeAlerts;

  const ProfileScreen({super.key, this.onSeeAlerts});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Created once (not inside build) so the Stream objects keep the same
  // identity across rebuilds. Firestore's snapshots() fires more than once
  // per change (cache, then server), and every one of those was previously
  // re-triggering `build()`; because the old code called
  // `RouteService().getSavedRoutes(uid)` directly inside build(), each
  // rebuild handed the nested StreamBuilder a brand-new Stream instance,
  // which resets it back to ConnectionState.waiting -- so it kept showing
  // the spinner and could look permanently stuck. Caching the streams here
  // fixes that.
  String? _uid;
  Stream<UserModel>? _userStream;
  Stream<List<RouteModel>>? _savedRoutesStream;
  Stream<List<RouteModel>>? _allRoutesStream;

  @override
  void initState() {
    super.initState();
    _uid = AuthService().currentUser?.uid;
    if (_uid != null) {
      _userStream = UserService().getUserStream(_uid!);
      _savedRoutesStream = RouteService().getSavedRoutes(_uid!);
      _allRoutesStream = RouteService().getAllRoutes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = _uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: StreamBuilder<UserModel>(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Could not load profile.'));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(user),
                const SizedBox(height: 20),
                _buildSavedRoutes(context, user, uid),
                const SizedBox(height: 20),
                _buildPreferences(context, user, uid),
                const SizedBox(height: 20),
                _buildSupport(context),
                const SizedBox(height: 20),
                _buildLogoutButton(context),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(UserModel user) {
    final initials = _getInitials(user.name);

    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2DD4BF), Color(0xFF0EA5E9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name.isNotEmpty ? user.name : 'No name set',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user.department} ${user.year}\n${user.studentId}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatBox('${user.totalTrips}', 'Trips'),
              const SizedBox(width: 12),
              StreamBuilder<List<RouteModel>>(
                stream: _savedRoutesStream,
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  return _buildStatBox('$count', 'Saved Routes');
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _buildStatBox(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedRoutes(BuildContext context, UserModel user, String uid) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SAVED ROUTES',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<RouteModel>>(
            stream: _savedRoutesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final savedRoutes = snapshot.data ?? <RouteModel>[];

              if (savedRoutes.isEmpty) {
                return GestureDetector(
                  onTap: () => _showSavedRoutesDialog(context, user, uid),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'No saved routes yet. Tap to add one.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (int i = 0; i < savedRoutes.length; i++)
                    _buildRoutePill(
                      savedRoutes[i].name,
                      '${savedRoutes[i].stops.length} stops',
                      _colorForIndex(i),
                      onRemove: () async {
                        await RouteService().removeSavedRoute(uid, savedRoutes[i].routeId);
                      },
                    ),
                  // "Add route" pill so users can add more from the same row.
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showSavedRoutesDialog(context, user, uid),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.3),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 18, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            'Add',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentYellow.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_active_outlined, color: AppTheme.accentYellow, size: 20),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Push Notifications',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Delays & schedule alerts',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: user.notificationsEnabled,
                    onChanged: (val) async {
                      await UserService().toggleNotifications(uid, val);
                    },
                    activeThumbColor: AppTheme.accentGreen,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForIndex(int i) {
    const colors = [
      AppTheme.accentGreen,
      AppTheme.accentBlue,
      AppTheme.accentYellow,
      AppTheme.accentPurple,
    ];
    return colors[i % colors.length];
  }

  Widget _buildRoutePill(
      String name,
      String stops,
      Color color, {
        VoidCallback? onRemove,
      }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.directions_bus, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                stops,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onRemove,
              child: const Icon(Icons.close, size: 16, color: Colors.grey),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildPreferences(BuildContext context, UserModel user, String uid) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PREFERENCES',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                InkWell(
                  onTap: widget.onSeeAlerts,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentYellow.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_outlined, color: AppTheme.accentYellow, size: 20),
                    ),
                    title: const Text(
                      'Notifications',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      user.notificationsEnabled ? 'Delays, schedule updates' : 'Turned off',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  ),
                ),
                const Divider(height: 1, indent: 60),
                // "Saved Routes" now behaves like "Home Stop": tapping it
                // opens a dialog listing every route, where you can tap to
                // add or remove it from your saved list.
                InkWell(
                  onTap: () => _showSavedRoutesDialog(context, user, uid),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star_border, color: AppTheme.accentPurple, size: 20),
                    ),
                    title: const Text(
                      'Saved Routes',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: StreamBuilder<List<RouteModel>>(
                      stream: _savedRoutesStream,
                      builder: (context, snapshot) {
                        final count = snapshot.data?.length ?? 0;
                        return Text(
                          '$count routes saved',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        );
                      },
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  ),
                ),
                const Divider(height: 1, indent: 60),
                InkWell(
                  onTap: () => _showHomeStopDialog(context, user, uid),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on_outlined, color: AppTheme.accentBlue, size: 20),
                    ),
                    title: const Text(
                      'Home Stop',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      user.homeStop.isNotEmpty ? user.homeStop : 'Not set',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showHomeStopDialog(BuildContext context, UserModel user, String uid) {
    // cSpell:ignore Halishahar Patenga Chawkbazar
    const homeStops = [
      'Halishahar',
      'GEC Circle',
      'Agrabad',
      'Patenga',
      'Chawkbazar',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Home Stop'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final stop in homeStops)
              ListTile(
                title: Text(stop),
                trailing: user.homeStop == stop
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () async {
                  await UserService().updateHomeStop(uid, stop);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  // Mirrors _showHomeStopDialog: lists every route and lets the user tap to
  // toggle it in/out of their saved routes. Backed by the same
  // _savedRoutesStream used elsewhere on this screen, so the pills up top
  // and the dot next to "Saved Routes" stay in sync automatically.
  void _showSavedRoutesDialog(BuildContext context, UserModel user, String uid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saved Routes'),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<List<RouteModel>>(
            stream: _allRoutesStream,
            builder: (context, allSnapshot) {
              if (allSnapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (allSnapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('Could not load routes.'),
                );
              }

              final allRoutes = allSnapshot.data ?? <RouteModel>[];

              if (allRoutes.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('No routes available.'),
                );
              }

              return StreamBuilder<List<RouteModel>>(
                stream: _savedRoutesStream,
                builder: (context, savedSnapshot) {
                  final savedIds = (savedSnapshot.data ?? <RouteModel>[])
                      .map((r) => r.routeId)
                      .toSet();

                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final route in allRoutes)
                          ListTile(
                            title: Text(route.name),
                            subtitle: Text('${route.stops.length} stops'),
                            trailing: savedIds.contains(route.routeId)
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : const Icon(Icons.add_circle_outline, color: Colors.grey),
                            onTap: () async {
                              try {
                                if (savedIds.contains(route.routeId)) {
                                  await RouteService().removeSavedRoute(uid, route.routeId);
                                } else {
                                  await RouteService().saveRoute(uid, route);
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed: $e')),
                                  );
                                }
                              }
                            },
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildSupport(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SUPPORT',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                _buildListTile(
                  icon: Icons.phone_outlined,
                  iconColor: AppTheme.accentGreen,
                  title: 'Contact Transport Office',
                  subtitle: '+880 1683-149127',
                ),
                const Divider(height: 1, indent: 60),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RouteGuideScreen()),
                    );
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.menu_book_outlined, color: AppTheme.accentBlue, size: 20),
                    ),
                    title: const Text(
                      'Route Guide',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: const Text(
                      'View all bus routes and stops',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.logout, color: Colors.red, size: 20),
          ),
          title: const Text(
            'Log Out',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
          ),
          onTap: () async {
            await AuthService().signOut();
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }
}