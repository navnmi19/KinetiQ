import 'package:flutter/material.dart';
import 'package:gym_app/models/friend_model.dart';

/// Seed data for the social feature. In-memory only, mirrors the rest of
/// the app (no backend yet) -- resets on restart. All four social screens
/// (Friends, Search, Requests, My Friends) read through
/// FriendsController rather than keeping their own local lists.
final List<Friend> sampleFriends = [
  // Already friends.
  const Friend(
    id: 'aarav',
    name: 'Aarav Sharma',
    username: '@aarav',
    icon: Icons.person,
    color: Color(0xFFFF7A1A),
    status: FriendStatus.friend,
    friendsCount: 248,
    workoutsCount: 93,
    streak: 21,
    about:
        'Fitness enthusiast who enjoys strength training, running, and '
        'healthy living. Loves competing with friends and maintaining '
        'workout streaks.',
  ),
  const Friend(
    id: 'vikram',
    name: 'Vikram Rao',
    username: '@vikram',
    icon: Icons.sports_gymnastics,
    color: Color(0xFF22C55E),
    status: FriendStatus.friend,
    friendsCount: 132,
    workoutsCount: 61,
    streak: 9,
    about: 'Calisthenics and mobility work. Early morning gym sessions.',
  ),

  // Incoming requests -- waiting on our Accept/Decline.
  const Friend(
    id: 'rahul',
    name: 'Rahul Gupta',
    username: '@rahulg',
    icon: Icons.person,
    color: Color(0xFFFF7A1A),
    mutualFriends: 10,
    status: FriendStatus.pendingIncoming,
  ),
  const Friend(
    id: 'sneha',
    name: 'Sneha Kapoor',
    username: '@sneha',
    icon: Icons.person,
    color: Color(0xFFFF7A1A),
    mutualFriends: 6,
    status: FriendStatus.pendingIncoming,
  ),
  const Friend(
    id: 'arjun',
    name: 'Arjun Patel',
    username: '@arjunp',
    icon: Icons.person,
    color: Color(0xFFFF7A1A),
    mutualFriends: 14,
    status: FriendStatus.pendingIncoming,
  ),
  const Friend(
    id: 'meera',
    name: 'Meera Joshi',
    username: '@meera',
    icon: Icons.person,
    color: Color(0xFFFF7A1A),
    mutualFriends: 3,
    status: FriendStatus.pendingIncoming,
  ),

  // Discoverable -- shown in Suggested Friends + Search People.
  const Friend(
    id: 'sophia',
    name: 'Sophia Turner',
    username: '@sophia',
    icon: Icons.directions_run_rounded,
    color: Colors.green,
    mutualFriends: 5,
    activityTag: '5 Day Streak',
  ),
  const Friend(
    id: 'daniel',
    name: 'Daniel Kim',
    username: '@daniel',
    icon: Icons.fitness_center,
    color: Colors.blue,
    mutualFriends: 2,
    activityTag: 'Strength',
  ),
  const Friend(
    id: 'emma',
    name: 'Emma Wilson',
    username: '@emma',
    icon: Icons.self_improvement,
    color: Colors.orange,
    mutualFriends: 7,
    activityTag: 'Yoga',
  ),
  const Friend(
    id: 'james',
    name: 'James Patel',
    username: '@james',
    icon: Icons.directions_bike,
    color: Colors.purple,
    mutualFriends: 1,
    activityTag: 'Cycling',
  ),
  const Friend(
    id: 'priya',
    name: 'Priya Verma',
    username: '@priya',
    icon: Icons.pool,
    color: Colors.teal,
    mutualFriends: 8,
    activityTag: 'Swimming',
  ),
  const Friend(
    id: 'rohan',
    name: 'Rohan Mehta',
    username: '@rohan',
    icon: Icons.fitness_center,
    color: Colors.indigo,
    mutualFriends: 20,
    activityTag: 'Powerlifting',
  ),
  const Friend(
    id: 'ananya',
    name: 'Ananya Singh',
    username: '@ananya',
    icon: Icons.directions_run_rounded,
    color: Colors.pink,
    mutualFriends: 4,
    activityTag: 'Running',
  ),
  const Friend(
    id: 'kabir',
    name: 'Kabir Jain',
    username: '@kabir',
    icon: Icons.sports_martial_arts,
    color: Colors.brown,
    mutualFriends: 16,
    activityTag: 'Martial Arts',
  ),
];
