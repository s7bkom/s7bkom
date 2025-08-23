import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double ticketPrice;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.ticketPrice,
  });

  factory Item.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Item(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      ticketPrice: (data['ticketPrice'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'ticketPrice': ticketPrice,
    };
  }
}
