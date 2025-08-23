import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucky_draw/models/item.dart';
import 'package:lucky_draw/models/draw.dart';
import 'package:lucky_draw/models/user_profile.dart';
import 'package:lucky_draw/models/ticket.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Item operations
  Stream<List<Item>> getItems() {
    return _db.collection('items').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Item.fromFirestore(doc)).toList());
  }

  Future<Item?> getItem(String itemId) async {
    final doc = await _db.collection('items').doc(itemId).get();
    return doc.exists ? Item.fromFirestore(doc) : null;
  }

  Future<void> addItem(Item item) {
    return _db.collection('items').add(item.toFirestore());
  }

  // Draw operations
  Stream<List<Draw>> getDraws() {
    return _db.collection('draws').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Draw.fromFirestore(doc)).toList());
  }

  Stream<Draw?> getCurrentDraw() {
    return _db
        .collection('draws')
        .where('status', isEqualTo: 'active')
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return Draw.fromFirestore(snapshot.docs.first);
      }
      return null;
    });
  }

  Future<void> updateDraw(Draw draw) {
    return _db.collection('draws').doc(draw.id).update(draw.toFirestore());
  }

  // UserProfile operations
  Stream<UserProfile?> getUserProfile(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) =>
        doc.exists ? UserProfile.fromFirestore(doc) : null);
  }

  Future<void> createUserProfile(UserProfile userProfile) async {
    await _db.collection('users').doc(userProfile.id).set(userProfile.toFirestore());
  }

  Future<void> updateUserProfile(UserProfile userProfile) async {
    await _db.collection('users').doc(userProfile.id).update(userProfile.toFirestore());
  }

  Future<void> updateFCMToken(String userId, String? token) async {
    await _db.collection('users').doc(userId).update({'fcmToken': token});
  }

  // Ticket operations
  Future<void> addTicket(Ticket ticket) async {
    await _db.collection('tickets').add(ticket.toFirestore());
  }

  Stream<List<Ticket>> getUserTickets(String userId) {
    return _db.collection('tickets').where('userId', isEqualTo: userId).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Ticket.fromFirestore(doc)).toList());
  }

  Future<void> purchaseTicket(String drawId, String userId, String userEmail, double ticketPrice) async {
    final drawRef = _db.collection('draws').doc(drawId);
    final userProfileRef = _db.collection('users').doc(userId);

    await _db.runTransaction((transaction) async {
      final drawSnapshot = await transaction.get(drawRef);
      final userProfileSnapshot = await transaction.get(userProfileRef);

      if (!drawSnapshot.exists) {
        throw Exception("Draw does not exist!");
      }

      Draw currentDraw = Draw.fromFirestore(drawSnapshot);

      if (currentDraw.status != 'active' && currentDraw.ticketCount >= 10) {
        throw Exception("Draw is not active or already has enough tickets!");
      }

      // Generate a unique ticket number (simple example, could be more robust)
      final String ticketNumber = '${currentDraw.ticketCount + 1}-${DateTime.now().millisecondsSinceEpoch}';

      // Create new ticket
      final newTicketRef = _db.collection('tickets').doc(); // Let Firestore generate ID
      final newTicket = Ticket(
        id: newTicketRef.id,
        drawId: drawId,
        userId: userId,
        ticketNumber: ticketNumber,
        purchaseDate: DateTime.now(),
      );
      transaction.set(newTicketRef, newTicket.toFirestore());

      // Update draw ticket count
      int newTicketCount = currentDraw.ticketCount + 1;
      transaction.update(drawRef, {'ticketCount': newTicketCount});

      // Update user profile with purchased ticket
      UserProfile userProfile;
      if (userProfileSnapshot.exists) {
        userProfile = UserProfile.fromFirestore(userProfileSnapshot);
        userProfile.purchasedTickets.add(newTicket.id);
        transaction.update(userProfileRef, {'purchasedTickets': userProfile.purchasedTickets});
      } else {
        userProfile = UserProfile(
          id: userId,
          email: userEmail,
          purchasedTickets: [newTicket.id],
        );
        transaction.set(userProfileRef, userProfile.toFirestore());
      }

      // If 10 tickets are sold, start countdown (this logic will be refined with Cloud Functions)
      if (newTicketCount == 10 && currentDraw.status == 'pending') {
        transaction.update(drawRef, {
          'status': 'active',
          'endTime': DateTime.now().add(const Duration(minutes: 5)), // 5-minute countdown
        });
      }
    });
  }
}
