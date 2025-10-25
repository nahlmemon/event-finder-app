import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_finder/admin/screens/add_events_screen.dart';
import 'package:event_finder/admin/widgets/admin_event_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Concert',
    'Workshop',
    'Sports',
    'Fair',
    'Community',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesFilter(Map<String, dynamic> event) {
    final title = (event['title'] ?? '').toString().toLowerCase();
    final desc = (event['description'] ?? '').toString().toLowerCase();
    final cat = (event['category'] ?? '').toString();
    final query = _searchQuery.trim().toLowerCase();
    final matchesSearch =
        query.isEmpty || title.contains(query) || desc.contains(query);
    final matchesCategory =
        _selectedCategory == 'All' || cat == _selectedCategory;
    return matchesSearch && matchesCategory;
  }

  DateTime _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;

            return Column(
              children: [
                _Header(isWide: isWide),

                // 🔹 Search bar + Add button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildSearchBar()),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddEventScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(110, 48),
                        ),
                      ),
                    ],
                  ),
                ),

                _buildCategoryChips(),

                // 🔹 Event grid
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('client')
                        .orderBy('date')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Failed to load events'),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;
                      final now = DateTime.now();

                      // 🔹 Delete expired events automatically
                      for (var doc in docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        final eventDate = data['date'] is Timestamp
                            ? (data['date'] as Timestamp).toDate()
                            : null;
                        if (eventDate != null && eventDate.isBefore(now)) {
                          FirebaseFirestore.instance
                              .collection('client')
                              .doc(doc.id)
                              .delete();
                        }
                      }

                      // 🔹 Valid (non-expired) events
                      final events = docs
                          .map(
                            (d) => {
                              'id': d.id,
                              ...Map<String, dynamic>.from(
                                d.data() as Map<String, dynamic>,
                              ),
                            },
                          )
                          .where(_matchesFilter)
                          .toList();

                      if (events.isEmpty) {
                        return const Center(child: Text('No events found'));
                      }

                      // 🔹 Responsive grid
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
                            aspectRatio = 1.5;
                          } else {
                            crossAxisCount = 4;
                            aspectRatio = 1.2;
                          }

                          return Padding(
                            padding: const EdgeInsets.all(12),
                            child: GridView.builder(
                              physics: const BouncingScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: aspectRatio,
                                  ),
                              itemCount: events.length,
                              itemBuilder: (context, i) {
                                final e = events[i];
                                final date = _toDateTime(e['date']);
                                return EventCard(event: e, date: date);
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (v) => setState(() => _searchQuery = v),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search events...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: categories.map((c) {
            final selected = c == _selectedCategory;
            return ChoiceChip(
              label: Text(c),
              selected: selected,
              onSelected: (_) => setState(() => _selectedCategory = c),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool isWide;
  const _Header({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(Icons.event, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Event Finder',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Text('Find your vibe or make it happen!'),
            ],
          ),
        ],
      ),
    );
  }
}
