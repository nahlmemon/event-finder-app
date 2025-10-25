import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_finder/admin/screens/add_events_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// ---------------- Event Card ----------------
class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final DateTime date;
  const EventCard({required this.event, required this.date, super.key});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(date);
    final formattedTime = DateFormat('h:mm a').format(date);

    final category = event['category'] ?? 'All';

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Padding(
          padding: const EdgeInsets.only(
            bottom: 15,
          ), // small inner padding for safety
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // let content decide height dynamically
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Gradient Header
              Container(
                height: 75,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getCategoryGradient(category),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(category),
                    size: 38,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ),

              // 🔹 Details Section
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔸 Title
                    Text(
                      event['title'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // 🔸 Date & Time
                    Text(
                      '$formattedDate • $formattedTime',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // 🔸 Location Row
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            event['location'] ?? 'Unknown',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 🔹 Edit / Delete Row — moved upward
                    const SizedBox(height: 0), // reduced gap
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 0,
                        ), // pushes icons slightly up
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              iconSize:
                                  19, // ↓ slightly smaller to prevent overflow
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 32,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEventScreen(
                                      eventId: event['id'],
                                      existingData: event,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              iconSize: 21, // ↓ same adjustment
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Delete Event'),
                                    content: const Text(
                                      'Are you sure you want to delete this event?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await FirebaseFirestore.instance
                                      .collection('client')
                                      .doc(event['id'])
                                      .delete();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Concert':
        return Icons.music_note;
      case 'Workshop':
        return Icons.work;
      case 'Sports':
        return Icons.sports_soccer;
      case 'Fair':
        return Icons.festival;
      case 'Community':
        return Icons.people;
      default:
        return Icons.event;
    }
  }

  List<Color> _getCategoryGradient(String category) {
    switch (category) {
      case 'Concert':
        return [Colors.purple.shade400, Colors.pink.shade400];
      case 'Workshop':
        return [Colors.blue.shade400, Colors.cyan.shade400];
      case 'Sports':
        return [Colors.orange.shade400, Colors.red.shade400];
      case 'Fair':
        return [Colors.green.shade400, Colors.teal.shade400];
      case 'Community':
        return [Colors.indigo.shade400, Colors.purple.shade400];
      default:
        return [Colors.deepPurple.shade400, Colors.purple.shade400];
    }
  }
}
