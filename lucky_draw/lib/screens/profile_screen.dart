import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucky_draw/models/user_profile.dart';
import 'package:lucky_draw/models/ticket.dart';
import 'package:lucky_draw/models/draw.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Please log in to view your profile.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User profile not found.'));
          }

          final userProfile = UserProfile.fromFirestore(snapshot.data!);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email: ${userProfile.email}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text(
                  'My Tickets:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                userProfile.purchasedTickets.isEmpty
                    ? const Text('No tickets purchased yet.')
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: userProfile.purchasedTickets.length,
                        itemBuilder: (context, index) {
                          final ticketId = userProfile.purchasedTickets[index];
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection('tickets').doc(ticketId).get(),
                            builder: (context, ticketSnapshot) {
                              if (ticketSnapshot.connectionState == ConnectionState.waiting) {
                                return const ListTile(title: Text('Loading ticket...'));
                              }
                              if (ticketSnapshot.hasError || !ticketSnapshot.hasData || !ticketSnapshot.data!.exists) {
                                return ListTile(title: Text('Error loading ticket $ticketId'));
                              }
                              final ticket = Ticket.fromFirestore(ticketSnapshot.data!);
                              return ListTile(
                                title: Text('Ticket ID: ${ticket.id}'),
                                subtitle: Text('Draw ID: ${ticket.drawId}'),
                              );
                            },
                          );
                        },
                      ),
                const SizedBox(height: 20),
                const Text(
                  'My Wins:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                userProfile.wonDraws.isEmpty
                    ? const Text('No wins yet.')
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: userProfile.wonDraws.length,
                        itemBuilder: (context, index) {
                          final drawId = userProfile.wonDraws[index];
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection('draws').doc(drawId).get(),
                            builder: (context, drawSnapshot) {
                              if (drawSnapshot.connectionState == ConnectionState.waiting) {
                                return const ListTile(title: Text('Loading draw...'));
                              }
                              if (drawSnapshot.hasError || !drawSnapshot.hasData || !drawSnapshot.data!.exists) {
                                return ListTile(title: Text('Error loading draw $drawId'));
                              }
                              final draw = Draw.fromFirestore(drawSnapshot.data!);
                              return Column(
                                children: [
                                  ListTile(
                                    title: Text('Won Draw ID: ${draw.id}'),
                                    subtitle: Text('Item: ${draw.itemId}'), // Will fetch item name later
                                  ),
                                  if (draw.status == 'completed' && draw.winnerId == user.uid)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Rate your experience:'),
                                          RatingBar.builder(
                                            initialRating: 3,
                                            minRating: 1,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                            itemBuilder: (context, _) => const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            onRatingUpdate: (rating) {
                                              // TODO: Implement rating submission logic
                                              print(rating);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              );
                            },
                          );
                        },
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
