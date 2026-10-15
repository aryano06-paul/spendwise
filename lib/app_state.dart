import 'dart:convert';

import 'package:flutter/material.dart';

import 'models/expense.dart';
import 'models/goal.dart';
import 'models/todo.dart';
import 'services/cloud_store.dart';

class SpendWiseState extends ChangeNotifier {
  /// One instance per signed-in user. All data is read from and saved to that
  /// user's own area in Cloud Firestore through [store].
  // ignore: prefer_initializing_formals
  SpendWiseState({required CloudStore store}) : _store = store;

  final CloudStore _store;
  final Set<Future<void>> _pendingWrites = {};
  bool _disposed = false;

  /// Set when the latest cloud save failed; cleared when a later save works.
  String? syncError;

  /// Set when loading the user's data failed.
  String? loadError;

  final List<Expense> _expenses = [];
  final List<Todo> _todos = [];
  final List<Goal> _goals = [];

  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<Todo> get todos => List.unmodifiable(_todos);
  List<Goal> get goals => List.unmodifiable(_goals);

  double monthlyBudget = 25000;
  ThemeMode themeMode = ThemeMode.system;
  int accentColorValue = 0xFF675CF6;
  String currencyCode = 'INR';
  bool isLoaded = false;

  Color get accentColor => Color(accentColorValue);

  static const List<Color> accentOptions = [
    Color(0xFF675CF6),
    Color(0xFF4D83F5),
    Color(0xFF18A999),
    Color(0xFFF0A23B),
    Color(0xFFEF6487),
    Color(0xFFB05AE8),
  ];

  double get totalSpentThisMonth {
    final now = DateTime.now();
    return _expenses.where((e) => e.date.year == now.year && e.date.month == now.month).fold(0.0, (sum, e) => sum + e.amount);
  }

  double get totalSpentAllTime => _expenses.fold(0.0, (sum, e) => sum + e.amount);
  double get remainingBudget => monthlyBudget - totalSpentThisMonth;
  double get budgetProgress => monthlyBudget <= 0 ? 0 : (totalSpentThisMonth / monthlyBudget).clamp(0.0, 1.0).toDouble();
  int get pendingTodoCount => _todos.where((t) => !t.completed).length;
  int get completedTodoCount => _todos.where((t) => t.completed).length;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> load() async {
    loadError = null;
    isLoaded = false;
    notifyListeners();
    try {
      final snapshot = await _store.loadAll();
      _expenses
        ..clear()
        ..addAll(_decodeList(snapshot.expenses, Expense.fromJson));
      _expenses.sort((a, b) => b.date.compareTo(a.date));
      _todos
        ..clear()
        ..addAll(_decodeList(snapshot.todos, Todo.fromJson));
      _todos.sort(_compareTodos);
      _goals
        ..clear()
        ..addAll(_decodeList(snapshot.goals, Goal.fromJson));
      _goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final settings = snapshot.settings;
      if (settings != null) _applySettings(settings);
      isLoaded = true;
    } catch (error) {
      debugPrint('SpendWise load failed: $error');
      final text = error.toString();
      final code = RegExp(r'\[cloud_firestore/([a-z-]+)\]').firstMatch(text)?.group(1);
      if (code == 'permission-denied') {
        loadError = 'Firestore refused access (permission-denied). Publish the rules from firestore.rules in Firebase, Firestore Database, Rules.';
      } else if (code == 'not-found' || text.contains('database (default) does not exist')) {
        loadError = 'The Firestore database does not exist yet. Create it in Firebase, Firestore Database, Create database.';
      } else {
        loadError = 'We could not load your data${code == null ? '' : ' ($code)'}. Check your internet connection and try again.';
      }
    } finally {
      notifyListeners();
    }
  }

  void _applySettings(Map<String, dynamic> data) {
    monthlyBudget = (data['monthlyBudget'] as num?)?.toDouble() ?? monthlyBudget;
    accentColorValue = (data['accentColorValue'] as num?)?.toInt() ?? accentColorValue;
    currencyCode = data['currencyCode'] as String? ?? currencyCode;
    final themeName = data['themeMode'] as String?;
    if (themeName != null) {
      themeMode = ThemeMode.values.firstWhere((m) => m.name == themeName, orElse: () => ThemeMode.system);
    }
  }

  int _compareTodos(Todo a, Todo b) {
    if (a.completed != b.completed) return a.completed ? 1 : -1;
    if (a.dueDate == null && b.dueDate == null) return b.createdAt.compareTo(a.createdAt);
    if (a.dueDate == null) return 1;
    if (b.dueDate == null) return -1;
    return a.dueDate!.compareTo(b.dueDate!);
  }

  List<T> _decodeList<T>(dynamic source, T Function(Map<String, dynamic>) fromJson) {
    if (source is! List) return <T>[];
    final output = <T>[];
    for (final item in source) {
      if (item is Map) {
        try {
          output.add(fromJson(Map<String, dynamic>.from(item)));
        } catch (_) {
          // Skip a single malformed record rather than losing other records.
        }
      }
    }
    return output;
  }

  Map<String, dynamic> _toMap() => {
        'schemaVersion': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'expenses': _expenses.map((e) => e.toJson()).toList(),
        'todos': _todos.map((t) => t.toJson()).toList(),
        'goals': _goals.map((g) => g.toJson()).toList(),
        'monthlyBudget': monthlyBudget,
        'themeMode': themeMode.name,
        'accentColorValue': accentColorValue,
        'currencyCode': currencyCode,
      };

  Map<String, dynamic> _settingsMap() => {
        'monthlyBudget': monthlyBudget,
        'themeMode': themeMode.name,
        'accentColorValue': accentColorValue,
        'currencyCode': currencyCode,
        'updatedAt': DateTime.now().toIso8601String(),
      };

  void _changed() => notifyListeners();

  /// Sends one change to the cloud without blocking the screen. Failures are
  /// reported through [syncError] so the app can tell the user.
  void _write(Future<void> Function(CloudStore store) operation) {
    late final Future<void> future;
    future = Future<void>.sync(() => operation(_store)).then<void>((_) {
      if (syncError != null) {
        syncError = null;
        notifyListeners();
      }
    }).catchError((Object error) {
      syncError = 'Your latest changes could not be saved to your account. Check your internet connection.';
      notifyListeners();
    }).whenComplete(() {
      _pendingWrites.remove(future);
    });
    _pendingWrites.add(future);
  }

  void _saveExpense(Expense expense) => _write((store) => store.saveItem(CloudStore.expensesCollection, expense.id, expense.toJson()));
  void _saveTodo(Todo todo) => _write((store) => store.saveItem(CloudStore.todosCollection, todo.id, todo.toJson()));
  void _saveGoal(Goal goal) => _write((store) => store.saveItem(CloudStore.goalsCollection, goal.id, goal.toJson()));
  void _deleteRemote(String collection, String id) => _write((store) => store.deleteItem(collection, id));
  void _saveSettings() => _write((store) => store.saveSettings(_settingsMap()));

  Future<void> waitForSave() async {
    while (_pendingWrites.isNotEmpty) {
      await Future.wait(List<Future<void>>.of(_pendingWrites));
    }
  }

  void addExpense(Expense expense) {
    _expenses.insert(0, expense);
    _expenses.sort((a, b) => b.date.compareTo(a.date));
    _changed();
    _saveExpense(expense);
  }

  void updateExpense(Expense updated) {
    final index = _expenses.indexWhere((e) => e.id == updated.id);
    if (index < 0) return;
    _expenses[index] = updated;
    _expenses.sort((a, b) => b.date.compareTo(a.date));
    _changed();
    _saveExpense(updated);
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    _changed();
    _deleteRemote(CloudStore.expensesCollection, id);
  }

  void addTodo(Todo todo) {
    _todos.insert(0, todo);
    _changed();
    _saveTodo(todo);
  }

  void updateTodo(Todo updated) {
    final index = _todos.indexWhere((t) => t.id == updated.id);
    if (index < 0) return;
    _todos[index] = updated;
    _todos.sort(_compareTodos);
    _changed();
    _saveTodo(updated);
  }

  void toggleTodo(String id) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index < 0) return;
    final toggled = _todos[index].copyWith(completed: !_todos[index].completed);
    _todos[index] = toggled;
    _changed();
    _saveTodo(toggled);
  }

  void deleteTodo(String id) {
    _todos.removeWhere((t) => t.id == id);
    _changed();
    _deleteRemote(CloudStore.todosCollection, id);
  }

  void addGoal(Goal goal) {
    _goals.insert(0, goal);
    _changed();
    _saveGoal(goal);
  }

  void updateGoal(Goal updated) {
    final index = _goals.indexWhere((g) => g.id == updated.id);
    if (index < 0) return;
    _goals[index] = updated;
    _changed();
    _saveGoal(updated);
  }

  void contributeToGoal(String id, double amount) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index < 0 || amount <= 0) return;
    final contributed = _goals[index].copyWith(savedAmount: _goals[index].savedAmount + amount);
    _goals[index] = contributed;
    _changed();
    _saveGoal(contributed);
  }

  void deleteGoal(String id) {
    _goals.removeWhere((g) => g.id == id);
    _changed();
    _deleteRemote(CloudStore.goalsCollection, id);
  }

  void setMonthlyBudget(double amount) {
    if (amount <= 0) return;
    monthlyBudget = amount;
    _changed();
    _saveSettings();
  }

  void setThemeMode(ThemeMode value) {
    themeMode = value;
    _changed();
    _saveSettings();
  }

  void setAccentColor(Color value) {
    accentColorValue = value.toARGB32();
    _changed();
    _saveSettings();
  }

  void setCurrency(String value) {
    currencyCode = value;
    _changed();
    _saveSettings();
  }

  String exportExpensesCsv() {
    String escape(String value) {
      final escaped = value.replaceAll('"', '""');
      return '"$escaped"';
    }
    final rows = <String>['Date,Title,Category,Amount,Note'];
    for (final expense in _expenses) {
      rows.add([
        escape(expense.date.toIso8601String().split('T').first),
        escape(expense.title),
        escape(expense.category.label),
        expense.amount.toStringAsFixed(2),
        escape(expense.note),
      ].join(','));
    }
    return rows.join('\n');
  }

  String exportBackup() => const JsonEncoder.withIndent('  ').convert(_toMap());

  Future<void> importBackup(String content) async {
    final decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic>) throw const FormatException('Backup must be a JSON object.');
    if (!decoded.containsKey('expenses') || !decoded.containsKey('todos') || !decoded.containsKey('goals')) {
      throw const FormatException('This file does not look like a SpendWise backup.');
    }
    final expenses = _decodeList(decoded['expenses'], Expense.fromJson);
    final todos = _decodeList(decoded['todos'], Todo.fromJson);
    final goals = _decodeList(decoded['goals'], Goal.fromJson);
    _expenses
      ..clear()
      ..addAll(expenses);
    _todos
      ..clear()
      ..addAll(todos);
    _goals
      ..clear()
      ..addAll(goals);
    monthlyBudget = (decoded['monthlyBudget'] as num?)?.toDouble() ?? monthlyBudget;
    accentColorValue = (decoded['accentColorValue'] as num?)?.toInt() ?? accentColorValue;
    currencyCode = decoded['currencyCode'] as String? ?? currencyCode;
    final themeName = decoded['themeMode'] as String?;
    if (themeName != null) {
      themeMode = ThemeMode.values.firstWhere((m) => m.name == themeName, orElse: () => ThemeMode.system);
    }
    _changed();
    syncError = null;
    _write((store) => store.replaceAll(
          expenses: _expenses.map((e) => e.toJson()).toList(),
          todos: _todos.map((t) => t.toJson()).toList(),
          goals: _goals.map((g) => g.toJson()).toList(),
          settings: _settingsMap(),
        ));
    await waitForSave();
    if (syncError != null) {
      throw StateError('The restored data could not be saved to your account. Check your internet connection and try again.');
    }
  }

  void clearFinancialData() {
    _expenses.clear();
    _todos.clear();
    _goals.clear();
    _changed();
    _write((store) => store.replaceAll(expenses: const [], todos: const [], goals: const []));
  }
}
