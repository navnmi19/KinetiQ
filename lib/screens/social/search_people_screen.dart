import 'package:flutter/material.dart';

class SearchPeopleScreen extends StatefulWidget {
  const SearchPeopleScreen({super.key});

  @override
  State<SearchPeopleScreen> createState() => _SearchPeopleScreenState();
}

class _SearchPeopleScreenState extends State<SearchPeopleScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> people = [
    {"name": "Aarav Sharma", "username": "@aarav", "mutual": 12},
    {"name": "Priya Verma", "username": "@priya", "mutual": 8},
    {"name": "Rohan Mehta", "username": "@rohan", "mutual": 20},
    {"name": "Ananya Singh", "username": "@ananya", "mutual": 4},
    {"name": "Kabir Jain", "username": "@kabir", "mutual": 16},
  ];

  String query = "";

  @override
  Widget build(BuildContext context) {
    final filtered = people.where((p) {
      return p["name"].toLowerCase().contains(query.toLowerCase()) ||
          p["username"].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0D),
        elevation: 0,
        title: const Text("Search People"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: (v) => setState(() => query = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search...",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1A1A1D),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final p = filtered[index];
                  return Card(
                    color: const Color(0xFF1A1A1D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFF7A1A),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        p["name"],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "${p["username"]} • ${p["mutual"]} mutual friends",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7A1A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text("Add"),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
