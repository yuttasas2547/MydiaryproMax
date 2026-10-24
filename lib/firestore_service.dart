import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final CollectionReference<Map<String, dynamic>> _diaries =
      FirebaseFirestore.instance.collection('diaries');

  static String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('ต้องเข้าสู่ระบบก่อนจัดการบันทึก');
    }
    return uid;
  }

  static Future<void> add(
    String title,
    String content,
    String date,
    String mood,
  ) async {
    await _diaries.add({
      'title': title,
      'content': content,
      'date': date,
      'mood': mood,
      'userId': _uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyDiaries() {
    return _diaries.where('userId', isEqualTo: _uid).snapshots();
  }

  static Future<void> update(
    String docId,
    String title,
    String content,
    String date,
    String mood,
  ) async {
    await _diaries.doc(docId).update({
      'title': title,
      'content': content,
      'date': date,
      'mood': mood,
    });
  }

  static Future<void> delete(String docId) async {
    await _diaries.doc(docId).delete();
  }
}
