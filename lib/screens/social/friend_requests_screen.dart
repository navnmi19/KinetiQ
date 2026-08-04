import 'package:flutter/material.dart';
import 'package:gym_app/models/friend_model.dart';
import 'friends_controller.dart';
import '../../themes/theme_controller.dart';

class FriendRequestsScreen extends StatelessWidget {
  const FriendRequestsScreen({super.key});

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
        final divider = isDark ? Colors.white24 : Colors.grey.shade400;

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            foregroundColor: textPrimary,
            title: const Text("Friend Requests"),
          ),
          body: ValueListenableBuilder<List<Friend>>(
            valueListenable: FriendsController.friends,
            builder: (context, _, _) {
              final requests = FriendsController.pendingIncoming;

              if (requests.isEmpty) {
                return Center(
                  child: Text(
                    "No pending requests.",
                    style: TextStyle(color: textSecondary),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final r = requests[index];
                  return Card(
                    color: card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: r.color,
                                child: Icon(r.icon, color: Colors.white),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.name,
                                      style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${r.mutualFriends} mutual friends",
                                      style: TextStyle(color: textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  onPressed: () =>
                                      FriendsController.acceptRequest(r.id),
                                  child: const Text("Accept"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: divider),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  onPressed: () =>
                                      FriendsController.declineRequest(r.id),
                                  child: Text(
                                    "Decline",
                                    style: TextStyle(color: textPrimary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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
