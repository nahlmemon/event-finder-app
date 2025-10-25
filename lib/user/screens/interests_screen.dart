import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/interest_provider.dart';
import '../widgets/event_card.dart';

class InterestsScreen extends StatelessWidget {
  const InterestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final interestProvider = context.watch<InterestsProvider>();
    final interestIds = interestProvider.interestIds;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Interests'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 206, 190, 233),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('client')
            .orderBy('date')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load events'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          // Filter events that are marked as interest
          final events = docs
              .map(
                (d) => {
                  'id': d.id,
                  ...Map<String, dynamic>.from(
                    d.data() as Map<String, dynamic>,
                  ),
                },
              )
              .where((e) => interestIds.contains(e['id']))
              .toList();

          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied,
                    size: 100,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No interested events yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          // Responsive Grid Layout
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              int crossAxisCount;
              double aspectRatio;

              if (width < 600) {
                crossAxisCount = 1;
                aspectRatio = 1.5;
              } else if (width < 900) {
                crossAxisCount = 2;
                aspectRatio = 1.8;
              } else {
                crossAxisCount = 4;
                aspectRatio = 1.4;
              }

              return Padding(
                padding: const EdgeInsets.all(8),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: aspectRatio,
                  ),
                  itemCount: events.length,
                  itemBuilder: (context, i) {
                    final e = events[i];
                    final date = e['date'] is Timestamp
                        ? (e['date'] as Timestamp).toDate()
                        : DateTime.now();
                    final isInterested = interestProvider.isInterested(e['id']);

                    return EventCard(
                      event: e,
                      date: date,
                      isInterested: isInterested,
                      onInterestToggle: () =>
                          interestProvider.toggleInterest(e['id']),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
