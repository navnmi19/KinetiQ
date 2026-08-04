import 'package:flutter/material.dart';
import 'package:gym_app/models/friend_model.dart';
import 'friend_profile_screen.dart';
import 'friends_controller.dart';
import '../../themes/theme_controller.dart';

class SearchPeopleScreen extends StatefulWidget {
  const SearchPeopleScreen({super.key});

  @override
  State<SearchPeopleScreen> createState() => _SearchPeopleScreenState();
}

class _SearchPeopleScreenState extends State<SearchPeopleScreen> {
  final TextEditingController _controller = TextEditingController();

  String query = "";

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        final bg = isDark ? const Color(0xFF0B0B0D) : Colors.white;
        final card = isDark ? const Color(0xFF1A1A1D) : const Color(0xFFF5F5F7);
        final accent =
            isDark ? const Color(0xFFFF7A1A) : const Color(0xFF22C55E);
        final textPrimary = isDark ? Colors.white : Colors.black87;
        final textSecondary = isDark ? Colors.white70 : Colors.grey.shade700;
        final textMuted = isDark ? Colors.white54 : Colors.grey.shade500;
        final chipInactive = isDark ? Colors.white24 : Colors.grey.shade300;

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            foregroundColor: textPrimary,
            title: const Text("Search People"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  onChanged: (v) => setState(() => query = v),
                  style: TextStyle(color: textPrimary),
                  decoration: InputDecoration(
                    hintText: "Search...",
                    hintStyle: TextStyle(color: textMuted),
                    filled: true,
                    fillColor: card,
                    prefixIcon: Icon(Icons.search, color: textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ValueListenableBuilder<List<Friend>>(
                    valueListenable: FriendsController.friends,
                    builder: (context, _, _) {
                      final filtered = FriendsController.discoverable.where((p) {
                        final q = query.toLowerCase();
                        return p.name.toLowerCase().contains(q) ||
                            p.username.toLowerCase().contains(q);
                      }).toList();

                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final p = filtered[index];
                          final requested = p.status == FriendStatus.pendingOutgoing;

                          return Card(
                            color: card,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FriendProfileScreen(friend: p),
                                ),
                              ),
                              leading: CircleAvatar(
                                backgroundColor: p.color,
                                child: Icon(p.icon, color: Colors.white),
                              ),
                              title: Text(
                                p.name,
                                style: TextStyle(color: textPrimary),
                              ),
                              subtitle: Text(
                                "${p.username} • ${p.mutualFriends} mutual friends",
                                style: TextStyle(color: textSecondary),
                              ),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: requested
                                      ? chipInactive
                                      : accent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: requested
                                    ? null
                                    : () => FriendsController.sendRequest(p.id),
                                child: Text(requested ? "Requested" : "Add"),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
