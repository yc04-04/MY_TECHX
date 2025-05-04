import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String title;
  final String objective;
  final String details;
  final String userId;
  final String username;
  final DateTime timestamp;
  final int likes;
  final int donations;
  final double donationAmount;
  final double donationGoal;
  final List<String> savedBy;
  final List<String> likedBy;

  PostModel({
    required this.id,
    required this.title,
    required this.objective,
    required this.details,
    required this.userId,
    required this.username,
    required this.timestamp,
    required this.likes,
    required this.donations,
    required this.donationAmount,
    required this.donationGoal,
    required this.savedBy,
    required this.likedBy,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'objective': objective,
    'details': details,
    'userId': userId,
    'username': username,
    'timestamp': timestamp,
    'likes': likes,
    'donations': donations,
    'donationAmount': donationAmount,
    'donationGoal': donationGoal,
    'savedBy': savedBy,
    'likedBy': likedBy,
  };

  factory PostModel.fromMap(String id, Map<String, dynamic> data) {
    return PostModel(
      id: id,
      title: data['title'] ?? '',
      objective: data['objective'] ?? '',
      details: data['details'] ?? '',
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      likes: data['likes'] ?? 0,
      donations: data['donations'] ?? 0,
      donationAmount: data['donationAmount'] ?? 0,
      donationGoal: (data['donationGoal'] ?? 0.0).toDouble(),
      savedBy: List<String>.from(data['savedBy'] ?? []),
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }
}