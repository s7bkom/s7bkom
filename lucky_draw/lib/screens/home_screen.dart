import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucky_draw/models/draw.dart';
import 'package:lucky_draw/models/item.dart';
import 'package:lucky_draw/screens/profile_screen.dart';
import 'package:lucky_draw/services/firestore_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lucky Draw'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<Draw?>(
        stream: _firestoreService.getCurrentDraw(),
        builder: (context, drawSnapshot) {
          if (drawSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (drawSnapshot.hasError) {
            return Center(child: Text('Error: ${drawSnapshot.error}'));
          }
          if (!drawSnapshot.hasData || drawSnapshot.data == null) {
            return const Center(child: Text('No active lucky draw at the moment.'));
          }

          final currentDraw = drawSnapshot.data!;

          return FutureBuilder<Item?>(
            future: _firestoreService.getItem(currentDraw.itemId),
            builder: (context, itemSnapshot) {
              if (itemSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (itemSnapshot.hasError) {
                return Center(child: Text('Error: ${itemSnapshot.error}'));
              }
              if (!itemSnapshot.hasData || itemSnapshot.data == null) {
                return const Center(child: Text('Item for this draw not found.'));
              }

              final item = itemSnapshot.data!;

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome, ${user?.email ?? 'Guest'}!',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      if (item.imageUrl.isNotEmpty)
                        Image.network(
                          item.imageUrl,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      const SizedBox(height: 20),
                      Text(
                        'Item up for grabs: ${item.name}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Description: ${item.description}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Ticket Price: \$${item.ticketPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (user == null) {
                            Fluttertoast.showToast(
                              msg: 'Please log in to purchase a ticket.',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                            return;
                          }
                          try {
                            await _firestoreService.purchaseTicket(
                              currentDraw.id,
                              user.uid,
                              user.email!,
                              item.ticketPrice,
                            );
                            Fluttertoast.showToast(
                              msg: 'Ticket purchased successfully!',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          } catch (e) {
                            Fluttertoast.showToast(
                              msg: 'Failed to purchase ticket: ${e.toString()}',
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Buy Ticket'),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Tickets Sold: ${currentDraw.ticketCount}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      const SizedBox(height: 10),
                      Builder(
                        builder: (context) {
                          if (currentDraw.endTime != null && currentDraw.endTime!.isAfter(DateTime.now())) {
                            return CountdownTimer(
                              endTime: currentDraw.endTime!.millisecondsSinceEpoch,
                              onEnd: () {
                                Fluttertoast.showToast(
                                  msg: 'Draw has ended!',
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.blue,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                              },
                              widgetBuilder: (_, time) {
                                if (time == null) {
                                  return const Text('Draw has ended!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
                                }
                                return Text(
                                  'Countdown: ${time.days != null ? '${time.days}d ' : ''}${time.hours != null ? '${time.hours}h ' : ''}${time.min != null ? '${time.min}m ' : ''}${time.sec}s',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                );
                              },
                            );
                          } else if (currentDraw.status == 'active' && currentDraw.ticketCount < 10) {
                            return const Text(
                              'Waiting for 10 tickets to start countdown',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            );
                          } else {
                            return const Text(
                              'Countdown Timer: 00:00:00',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            );
                          }
                        },
                      ),
                      if (currentDraw.status == 'completed' && currentDraw.winnerEmail != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            'Winner: ${currentDraw.winnerEmail}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
