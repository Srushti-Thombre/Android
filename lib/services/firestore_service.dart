class FirestoreService {
  Future<void> setDocument(
    String collection,
    String doc,
    Map<String, dynamic> data,
  ) async {}

  Future<void> updateDocument(
    String collection,
    String doc,
    Map<String, dynamic> data,
  ) async {}

  Future<void> deleteDocument(
    String collection,
    String doc,
  ) async {}

  Future<dynamic> getDocument(
    String collection,
    String doc,
  ) async {
    return null;
  }

  Stream<dynamic> getDocumentStream(
    String collection,
    String doc,
  ) async* {}

  Future<dynamic> getCollection(
    String collection,
  ) async {
    return null;
  }

  Stream<dynamic> getCollectionStream(
    String collection,
  ) async* {}

  Future<dynamic> query(
    String collection, {
    String? field,
    dynamic isEqualTo,
    List<dynamic>? arrayContains,
    dynamic isGreaterThan,
    dynamic isLessThan,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    return null;
  }

  Stream<dynamic> queryStream(
    String collection, {
    String? field,
    dynamic isEqualTo,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async* {}

  Future<void> batch(List operations) async {}
}