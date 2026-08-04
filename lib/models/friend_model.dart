import 'package:flutter/material.dart';

enum FriendStatus {
  /// Discoverable person we haven't sent a request to yet.
  suggested,

  /// We sent them a request; waiting on them to accept.
  pendingOutgoing,

  /// They sent us a request; waiting on our Accept/Decline.
  pendingIncoming,

  /// Mutually connected.
  friend,
}

class Friend {
  final String id;
  final String name;
  final String username;
  final IconData icon;
  final Color color;
  final int mutualFriends;
  final String activityTag;
  final FriendStatus status;
  final int friendsCount;
  final int workoutsCount;
  final int streak;
  final String about;

  const Friend({
    required this.id,
    required this.name,
    required this.username,
    required this.icon,
    required this.color,
    this.mutualFriends = 0,
    this.activityTag = '',
    this.status = FriendStatus.suggested,
    this.friendsCount = 0,
    this.workoutsCount = 0,
    this.streak = 0,
    this.about = '',
  });

  Friend copyWith({FriendStatus? status}) {
    return Friend(
      id: id,
      name: name,
      username: username,
      icon: icon,
      color: color,
      mutualFriends: mutualFriends,
      activityTag: activityTag,
      status: status ?? this.status,
      friendsCount: friendsCount,
      workoutsCount: workoutsCount,
      streak: streak,
      about: about,
    );
  }
}
