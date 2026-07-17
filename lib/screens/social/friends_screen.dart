import 'package:flutter/material.dart';
import 'search_people_screen.dart';
import 'friend_requests_screen.dart';
import 'friend_profile_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final Color green = const Color(0xFF22C55E);

  final List<Map<String, dynamic>> suggested = [
    {
      "name": "Sophia",
      "goal": "5 Day Streak",
      "color": Colors.green,
      "icon": Icons.directions_run_rounded,
    },
    {
      "name": "Daniel",
      "goal": "Strength",
      "color": Colors.blue,
      "icon": Icons.fitness_center,
    },
    {
      "name": "Emma",
      "goal": "Yoga",
      "color": Colors.orange,
      "icon": Icons.self_improvement,
    },
    {
      "name": "James",
      "goal": "Cycling",
      "color": Colors.purple,
      "icon": Icons.directions_bike,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD1FAE5),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),

                Text(
                  "Friends",
                  style: TextStyle(
                    fontSize: width < 360 ? 30 : 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Stay connected with your fitness partners.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 28),

                _ActionCard(
                  icon: Icons.person_search_rounded,
                  title: "Find Friends",
                  subtitle: "Discover new workout partners nearby.",
                  color: green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchPeopleScreen()),
                    );
                  },
                ),

                const SizedBox(height: 18),

                _ActionCard(
                  icon: Icons.groups_rounded,
                  title: "My Friends",
                  subtitle: "View your fitness circle and activity.",
                  color: green,
                ),

                const SizedBox(height: 18),

                _ActionCard(
                  icon: Icons.mark_email_unread_rounded,
                  title: "Friend Requests",
                  subtitle: "2 pending requests waiting for you.",
                  color: green,
                  badge: "2",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FriendRequestsScreen()),
                    );
                  },
                ),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Text(
                      "Suggested Friends",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                SizedBox(
                  height: 210,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: suggested.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (_, index) {
                      final item = suggested[index];

                      return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const FriendProfileScreen()),
                            );
                          },
                          child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                        width: 170,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.05),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                radius: 34,
                                backgroundColor:
                                (item["color"] as Color).withOpacity(.15),
                                child: Icon(
                                  item["icon"],
                                  color: item["color"],
                                  size: 34,
                                ),
                              ),

                              Column(
                                children: [
                                  Text(
                                    item["name"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item["goal"],
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),

                              InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Friend request sent to ${item["name"]}!")),
                                  );
                                },
                                child: AnimatedContainer(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOut,
                                height: 42,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: green,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Add",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ))
                            ],
                          ),
                        ),
                      ));
                    },
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? badge;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.badge,
    this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => pressed = true),
      onTapUp: (_) => setState(() => pressed = false),
      onTapCancel: () => setState(() => pressed = false),
      child: AnimatedScale(
        scale: pressed ? .98 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              if (widget.badge != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    widget.badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
        ),
      ),
    );
  }
}