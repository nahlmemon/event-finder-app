import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/interest_provider.dart';
import '../widgets/event_card.dart';
import 'interests_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
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
    final interestProvider = context.watch<InterestsProvider>();
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            UserHeader(isWide: isWide),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: _buildSearchBar(),
            ),

            //  Category Chips
            _buildCategoryChips(),

            //  Event Grid with StreamBuilder
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
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
                  final now = DateTime.now();

                  // 🔹 Auto-delete expired events
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

                  // 🔹 Filter valid events
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

                  // 🔹 Responsive grid layout
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

                      return GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: aspectRatio,
                        ),
                        itemCount: events.length,
                        itemBuilder: (context, i) {
                          final e = events[i];
                          final date = _toDateTime(e['date']);
                          final isInterested = interestProvider.isInterested(
                            e['id'],
                          );
                          return EventCard(
                            event: e,
                            date: date,
                            isInterested: isInterested,
                            onInterestToggle: () =>
                                interestProvider.toggleInterest(e['id']),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
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
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8, // Horizontal space between chips
          runSpacing: 8, // Vertical space when wrapping
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

class UserHeader extends StatelessWidget {
  final bool isWide;
  const UserHeader({required this.isWide, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left section: title + subtitle
          Row(
            children: [
              Icon(Icons.event, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event Finder',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text('Find Your Vibe 👀'),
                ],
              ),
            ],
          ),

          // Right section: Interests button
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InterestsScreen()),
              );
            },
            icon: const Icon(
              Icons.favorite,
              color: Color.fromARGB(255, 255, 205, 229),
            ),
            label: const Text(
              'Interests',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
