import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InterestsProvider extends ChangeNotifier {
  Set<String> _interestIds = {};

  Set<String> get interestIds => _interestIds;

  InterestsProvider() {
    _loadInterests();
  }

  Future<void> _loadInterests() async {
    final doc = await FirebaseFirestore.instance
        .collection('interests')
        .doc('user1')
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      _interestIds = Set<String>.from(data['eventIds'] ?? []);
      notifyListeners();
    }
  }

  Future<void> toggleInterest(String eventId) async {
    if (_interestIds.contains(eventId)) {
      _interestIds.remove(eventId);
    } else {
      _interestIds.add(eventId);
    }
    notifyListeners();
    await FirebaseFirestore.instance.collection('interests').doc('user1').set({
      'eventIds': _interestIds.toList(),
    });
  }

  bool isInterested(String eventId) {
    return _interestIds.contains(eventId);
  }
}
