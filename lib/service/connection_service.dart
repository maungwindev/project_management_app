import 'package:cloud_firestore/cloud_firestore.dart';

class ConnectionService {
  final FirebaseFirestore firestore;

  ConnectionService({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _ref =>
      firestore.collection('connections');

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

    if (snap.exists) {
      final status = snap.data()!['status'];
      if (status == 'accepted' || status == 'pending') {
        throw Exception('Invite already exists');
      }
    }

    await docRef.set({
      'pairKey': key,
      'userA': fromUid,
      'userB': toUid,
      'invitedBy': fromUid,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
