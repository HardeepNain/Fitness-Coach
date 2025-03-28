import 'package:flutter/material.dart';
import 'package:myapp/screens/chat_screen.dart';
import 'package:myapp/screens/fitness_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/login_screen.dart';

class NavDrawer extends StatefulWidget {
  final int selectedIndex;
  const NavDrawer({super.key, required this.selectedIndex});

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  @override
  Widget build(BuildContext context) {
    final Map<int, Widget> screens = {
      0: ChatScreen(chatSessionId: '',), // Replace with actual screen widgets
      1: ChatScreen(chatSessionId: '',),
      2: FitnessListScreen(),
      // 3 is for log out action, not a screen
    };
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface, // Light Gray
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary, // Light Blue
            ),
            child: Text(
              'Options',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary, // Dark blue
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Image.asset(
              'assets/images/gym.png',
              width: 24,
              height: 24,
              color:
                  widget.selectedIndex == 0
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSecondary,
            ),
            title: Text(
              'AI fitness Counselling',
              style: TextStyle(
                color:
                    widget.selectedIndex == 0
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            selected: widget.selectedIndex == 0, // Highlight if selected
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => screens[0]!),
              );
            },
          ),
          ListTile(
            leading: Image.asset(
              'assets/images/workout (1).png',
              width: 24,
              height: 24,
              color:
                  widget.selectedIndex == 1
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSecondary,
            ),
            title: Text(
              'Workout Plan',
              style: TextStyle(
                color:
                    widget.selectedIndex == 1
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            selected: widget.selectedIndex == 1, // Highlight if selected
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => screens[1]!),
              );
            },
          ),
          ListTile(
            leading: Image.asset(
              'assets/images/healthy-food.png',
              width: 24,
              height: 24,
              color:
                  widget.selectedIndex == 2
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSecondary,
            ),
            title: Text(
              'Diet Plan',
              style: TextStyle(
                color:
                    widget.selectedIndex == 2
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            selected: widget.selectedIndex == 2, // Highlight if selected
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => screens[2]!),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              color:
                  widget.selectedIndex == 3
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSecondary,
            ),
            title: Text(
              'Log Out',
              style: TextStyle(
                color:
                    widget.selectedIndex == 3
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            selected: widget.selectedIndex == 3, // Highlight if selected
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.remove("userId");
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LogInScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}