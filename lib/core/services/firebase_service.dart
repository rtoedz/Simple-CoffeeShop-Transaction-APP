import 'dart:io';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService extends GetxService {
  late FirebaseFirestore _firestore;
  late FirebaseAuth _auth;
  late FirebaseStorage _storage;
  
  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;
  FirebaseStorage get storage => _storage;
  
  @override
  void onInit() {
    super.onInit();
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
    _storage = FirebaseStorage.instance;
  }
  
  // Helper methods for common operations
  Future<DocumentSnapshot> getDocument(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).get();
  }
  
  Future<QuerySnapshot> getCollection(String collection) {
    return _firestore.collection(collection).get();
  }
  
  Future<void> setDocument(String collection, String docId, Map<String, dynamic> data) {
    return _firestore.collection(collection).doc(docId).set(data);
  }
  
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) {
    return _firestore.collection(collection).doc(docId).update(data);
  }
  
  Future<void> deleteDocument(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).delete();
  }

  // Storage methods
  Future<String> uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('images/$fileName');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }
}