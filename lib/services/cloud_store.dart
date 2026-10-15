import 'package:cloud_firestore/cloud_firestore.dart';

/// Everything stored for one user, as plain maps.
class CloudSnapshot {
  final List<Map<String, dynamic>> expenses;
  final List<Map<String, dynamic>> todos;
  final List<Map<String, dynamic>> goals;
  final Map<String, dynamic>? settings;

  const CloudSnapshot({
    required this.expenses,
    required this.todos,
    required this.goals,
    required this.settings,
  });
}

/// Reads and writes one signed-in user's data in Cloud Firestore.
///
/// Layout (every path starts with the user's own uid, and the security rules
/// only allow that user to touch it):
///   users/{uid}/expenses/{id}
///   users/{uid}/todos/{id}
///   users/{uid}/goals/{id}
///   users/{uid}/meta/settings
class CloudStore {
  CloudStore(this.uid, {FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  static const String expensesCollection = 'expenses';
  static const String todosCollection = 'todos';
  static const String goalsCollection = 'goals';

  final String uid;
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> get _userDoc => _db.collection('users').doc(uid);
  CollectionReference<Map<String, dynamic>> _collection(String name) => _userDoc.collection(name);
  DocumentReference<Map<String, dynamic>> get _settingsDoc => _userDoc.collection('meta').doc('settings');

  Future<CloudSnapshot> loadAll() async {
    final expensesFuture = _collection(expensesCollection).get();
    final todosFuture = _collection(todosCollection).get();
    final goalsFuture = _collection(goalsCollection).get();
    final settingsFuture = _settingsDoc.get();

    final expenses = await expensesFuture;
    final todos = await todosFuture;
    final goals = await goalsFuture;
    final settings = await settingsFuture;

    return CloudSnapshot(
      expenses: expenses.docs.map((doc) => doc.data()).toList(),
      todos: todos.docs.map((doc) => doc.data()).toList(),
      goals: goals.docs.map((doc) => doc.data()).toList(),
      settings: settings.data(),
    );
  }

  Future<void> saveItem(String collection, String id, Map<String, dynamic> data) {
    return _collection(collection).doc(id).set(data);
  }

  Future<void> deleteItem(String collection, String id) {
    return _collection(collection).doc(id).delete();
  }

  Future<void> saveSettings(Map<String, dynamic> settings) {
    return _settingsDoc.set(settings, SetOptions(merge: true));
  }

  /// Replaces every expense, task and goal with the given lists. Used by
  /// "Restore backup" and "Clear all data". Settings are written only when given.
  Future<void> replaceAll({
    required List<Map<String, dynamic>> expenses,
    required List<Map<String, dynamic>> todos,
    required List<Map<String, dynamic>> goals,
    Map<String, dynamic>? settings,
  }) async {
    await _replaceCollection(expensesCollection, expenses);
    await _replaceCollection(todosCollection, todos);
    await _replaceCollection(goalsCollection, goals);
    if (settings != null) {
      await saveSettings(settings);
    }
  }

  Future<void> _replaceCollection(String name, List<Map<String, dynamic>> items) async {
    final existing = await _collection(name).get();
    final operations = <void Function(WriteBatch batch)>[];

    for (final doc in existing.docs) {
      operations.add((batch) => batch.delete(doc.reference));
    }
    for (final item in items) {
      final id = item['id'] as String;
      operations.add((batch) => batch.set(_collection(name).doc(id), item));
    }

    // A Firestore batch holds at most 500 operations; stay well below that.
    const chunkSize = 400;
    for (var start = 0; start < operations.length; start += chunkSize) {
      final end = start + chunkSize < operations.length ? start + chunkSize : operations.length;
      final batch = _db.batch();
      for (final operation in operations.sublist(start, end)) {
        operation(batch);
      }
      await batch.commit();
    }
  }
}
