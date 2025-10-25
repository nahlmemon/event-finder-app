import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final DateTime date;
  final bool isInterested;
  final VoidCallback onInterestToggle;

  const EventCard({
    super.key,
    required this.event,
    required this.date,
    required this.isInterested,
    required this.onInterestToggle,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(date);
    final formattedTime = DateFormat('h:mm a').format(date);
    final category = event['category'] ?? 'All';

    return InkWell(
      onTap: () => _showDetails(context),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Gradient header
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

            // 🔹 Details section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Text(
                    '$formattedDate • $formattedTime',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 6),
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
                      IconButton(
                        icon: Icon(
                          isInterested ? Icons.favorite : Icons.favorite_border,
                          color: isInterested ? Colors.red : Colors.grey,
                        ),
                        onPressed: onInterestToggle,
                        iconSize: 22,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
        return [Colors.grey.shade400, Colors.grey.shade500];
    }
  }

  void _showDetails(BuildContext context) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(date);
    final formattedTime = DateFormat('h:mm a').format(date);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.category, size: 18),
                    const SizedBox(width: 6),
                    Text(event['category'] ?? 'Unknown'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 6),
                    Text('$formattedDate at $formattedTime'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18),
                    const SizedBox(width: 6),
                    Expanded(child: Text(event['location'] ?? 'No location')),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(event['description'] ?? 'No description available'),
              ],
            ),
          ),
        );
      },
    );
  }
}
