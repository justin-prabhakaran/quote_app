import 'package:flutter/material.dart';

import 'pages/pages.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 30),
        children: [
          Container(
            margin: const EdgeInsets.only(left: 20, top: 30),
            child: const Text(
              'Random Quote',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
            ),
          ),
          const Divider(),
          const SizedBox(height: 10),
          ListTile(
            title: const Text('Stoic Quotes'),
            leading: const Icon(
              Icons.favorite,
              color: Colors.red,
            ),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const Stoic()));
            },
          ),
          ListTile(
            title: const Text('Random Jokes'),
            leading: const Icon(
              Icons.emoji_emotions,
              color: Colors.amber,
            ),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const Jokes()));
            },
          ),
          ListTile(
            title: const Text('Affirmations'),
            leading: const Icon(
              Icons.health_and_safety,
              color: Colors.green,
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Affirmation()));
            },
          ),
          ListTile(
            title: const Text('Advice Slip'),
            leading: const Icon(
              Icons.task_alt,
              color: Colors.blue,
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Advice()));
            },
          ),
          ListTile(
            title: const Text('Fact in Numbers'),
            leading: const Icon(
              Icons.onetwothree,
              color: Colors.pink,
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const FactNum()));
            },
          ),
          ListTile(
            title: const Text('Bookmarks'),
            leading: const Icon(
              Icons.bookmark,
              color: Colors.purpleAccent,
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const BookMarks()));
            },
          )
        ],
      ),
    );
  }
}
