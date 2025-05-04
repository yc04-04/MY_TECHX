// === firestore_service.dart ===

import 'package:cloud_firestore/cloud_firestore.dart';
import 'discussion/post_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<List<PostModel>> fetchPosts({String orderBy = 'timestamp'}) async {
    final snapshot = await _db
        .collection('posts')
        .orderBy(orderBy, descending: true)
        .get();
    return snapshot.docs
        .map((doc) => PostModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<PostModel>> streamPosts({String orderBy = 'timestamp'}) {
    return _db
        .collection('posts')
        .orderBy(orderBy, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PostModel.fromMap(doc.id, doc.data()))
        .toList());
  }

  Future<void> addPost(PostModel post) async {
    await _db.collection('posts').add(post.toMap());
  }

  Future<void> updatePost(String id, Map<String, dynamic> data) async {
    await _db.collection('posts').doc(id).update(data);
  }

  Future<void> deletePost(String id) async {
    await _db.collection('posts').doc(id).delete();
  }
}
