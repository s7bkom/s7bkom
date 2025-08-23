import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemDescriptionController = TextEditingController();
  final TextEditingController _itemImageUrlController = TextEditingController();
  final TextEditingController _itemTicketPriceController = TextEditingController();

  Future<void> _addItem() async {
    if (_itemNameController.text.isEmpty ||
        _itemDescriptionController.text.isEmpty ||
        _itemImageUrlController.text.isEmpty ||
        _itemTicketPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all item fields.')),
      );
      return;
    }

    try {
      await _firestore.collection('items').add({
        'name': _itemNameController.text,
        'description': _itemDescriptionController.text,
        'imageUrl': _itemImageUrlController.text,
        'ticketPrice': double.parse(_itemTicketPriceController.text),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item added successfully!')),
      );
      _itemNameController.clear();
      _itemDescriptionController.clear();
      _itemImageUrlController.clear();
      _itemTicketPriceController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add item: ${e.toString()}')),
      );
    }
  }

  Future<void> _startNewDraw(String itemId) async {
    try {
      await _firestore.collection('draws').add({
        'itemId': itemId,
        'ticketCount': 0,
        'status': 'pending',
        'endTime': null,
        'winnerId': null,
        'winnerEmail': null,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New draw started successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start new draw: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Item',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _itemNameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _itemDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Item Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _itemImageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Item Image URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _itemTicketPriceController,
                decoration: const InputDecoration(
                  labelText: 'Ticket Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _addItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Add Item'),
              ),
              const Divider(height: 40, thickness: 2),
              const Text(
                'Manage Draws',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('items').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('No items available to start a draw.');
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: snapshot.data!.docs.map((doc) {
                      final item = doc.data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(item['name'])),
                            ElevatedButton(
                              onPressed: () => _startNewDraw(doc.id),
                              child: const Text('Start New Draw'),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const Divider(height: 40, thickness: 2),
              const Text(
                'Active/Completed Draws',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('draws').orderBy('endTime', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('No draws available.');
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final draw = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Draw ID: ${snapshot.data!.docs[index].id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('Item ID: ${draw['itemId']}'),
                              Text('Tickets Sold: ${draw['ticketCount']}'),
                              Text('Status: ${draw['status']}'),
                              if (draw['endTime'] != null)
                                Text('End Time: ${DateTime.fromMillisecondsSinceEpoch(draw['endTime'].millisecondsSinceEpoch)}'),
                              if (draw['winnerEmail'] != null)
                                Text('Winner: ${draw['winnerEmail']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
