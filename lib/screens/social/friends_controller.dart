import 'package:flutter/material.dart';
import 'package:gym_app/models/friend_model.dart';
import 'package:gym_app/screens/data/sample_friends.dart';

/// In-memory social state shared across the Friends/Search/Requests/My
/// Friends screens. Mirrors ThemeController's static ValueNotifier
/// pattern -- the app has no backend yet, so this resets on restart.
class FriendsController {
  FriendsController._();

  static final ValueNotifier<List<Friend>> friends =
      ValueNotifier<List<Friend>>(List.of(sampleFriends));

  static List<Friend> get myFriends =>
      friends.value.where((f) => f.status == FriendStatus.friend).toList();

  static List<Friend> get pendingIncoming => friends.value
      .where((f) => f.status == FriendStatus.pendingIncoming)
      .toList();

  /// People shown in "Suggested Friends" and Search -- not yet friends,
  /// including ones we've already sent a request to (shown as
  /// "Requested").
  static List<Friend> get discoverable => friends.value
      .where(
        (f) =>
            f.status == FriendStatus.suggested ||
            f.status == FriendStatus.pendingOutgoing,
      )
      .toList();

  static void sendRequest(String id) => _setStatus(id, FriendStatus.pendingOutgoing);

  static void acceptRequest(String id) => _setStatus(id, FriendStatus.friend);

  static void declineRequest(String id) {
    friends.value = friends.value.where((f) => f.id != id).toList();
  }

  static void _setStatus(String id, FriendStatus status) {
    friends.value = [
      for (final f in friends.value)
        if (f.id == id) f.copyWith(status: status) else f,
    ];
  }
}
