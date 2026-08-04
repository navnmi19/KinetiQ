import 'package:flutter/material.dart';
import 'package:gym_app/models/friend_model.dart';
import 'friend_profile_screen.dart';
import 'friends_controller.dart';
import '../../themes/theme_controller.dart';

class MyFriendsScreen extends StatelessWidget {
  const MyFriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        final bg = isDark ? const Color(0xFF0B0B0D) : Colors.white;
        final card = isDark ? const Color(0xFF1A1A1D) : const Color(0xFFF5F5F7);
        final textPrimary = isDark ? Colors.white : Colors.black87;
        final textSecondary = isDark ? Colors.white70 : Colors.grey.shade700;

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            foregroundColor: textPrimary,
            title: const Text("My Friends"),
          ),
          body: ValueListenableBuilder<List<Friend>>(
            valueListenable: FriendsController.friends,
            builder: (context, _, _) {
              final friends = FriendsController.myFriends;

              if (friends.isEmpty) {
                return Center(
                  child: Text(
                    "No friends yet — find people to add!",
                    style: TextStyle(color: textSecondary),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final f = friends[index];
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
                          builder: (_) => FriendProfileScreen(friend: f),
                        ),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: f.color,
                        child: Icon(f.icon, color: Colors.white),
                      ),
                      title: Text(
                        f.name,
                        style: TextStyle(color: textPrimary),
                      ),
                      subtitle: Text(
                        "${f.username} • ${f.streak} day streak",
                        style: TextStyle(color: textSecondary),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: textSecondary,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
