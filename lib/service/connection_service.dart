import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pm_app/models/response_models/user_model.dart';

class ConnectionService {
  final FirebaseFirestore firestore;

  ConnectionService({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _ref =>
      firestore.collection('connections');

  CollectionReference<Map<String, dynamic>> get _userRef =>
      firestore.collection('users');

  String _pairKey(String a, String b) {
    final list = [a, b]..sort();
    return '${list[0]}_${list[1]}';
  }

  Future<void> createInvite({
    required String fromUid,
    required String toUid,
  }) async {
    final key = _pairKey(fromUid, toUid);
    final docRef = _ref.doc(key);
    final snap = await docRef.get();
    final query =
          await _userRef.where(FieldPath.documentId, isEqualTo: fromUid).limit(1).get();

    final user = UserResponseModel.fromFirestore(
          query.docs.first.data(), query.docs.first.id);
    if (snap.exists) {
      final status = snap.data()!['status'];
      if (status == 'accepted' || status == 'pending') {
        throw Exception('Invite already exists');
      }
      // If rejected, update it to pending again
      await docRef.update({
        'invitedBy': fromUid,
        'invitedByName':user.name,
        'status': 'pending',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    // Create new invite
    await docRef.set({
      'pairKey': key,
      'userA': fromUid,
      'userB': toUid,
      'invitedBy': fromUid,
      'invitedByName':user.name,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> fetchPendingInvites(String currentUid) {
    return FirebaseFirestore.instance
        .collection('connections')
        .where('status', isEqualTo: 'pending')
        .where('userB', isEqualTo: currentUid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()..['id'] = doc.id).toList());
  }

  Future<void> respondToInvite({
  required String pairKey,
  required bool accept,
}) async {
  final docRef = FirebaseFirestore.instance.collection('connections').doc(pairKey);

  // 1️⃣ Update invite status
  await docRef.update({
    'status': accept ? 'accepted' : 'rejected',
    'updatedAt': FieldValue.serverTimestamp(),
  });

  // 2️⃣ If accepted, update team_members of both users
  if (accept) {
    final inviteSnap = await docRef.get();
    final data = inviteSnap.data()!;
    final userA = data['userA'];
    final userB = data['userB'];

    final userRef = FirebaseFirestore.instance.collection('users');

    // Update A's team_members to include B
    await userRef.doc(userA).update({
      'team_members': FieldValue.arrayUnion([userB]),
    });

    // Update B's team_members to include A
    await userRef.doc(userB).update({
      'team_members': FieldValue.arrayUnion([userA]),
    });
  }
}

}
