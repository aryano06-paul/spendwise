import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/expense.dart';
import 'models/goal.dart';
import 'models/todo.dart';

class SpendWiseState extends ChangeNotifier {
  static const String _storageKey = 'spendwise_data_v1';
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  Future<void> _saveQueue = Future<void>.value();

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

  Future<void> load() async {
    try {
      final raw = await _preferences.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _expenses
            ..clear()
            ..addAll(_decodeList(decoded['expenses'], Expense.fromJson));
          _todos
            ..clear()
            ..addAll(_decodeList(decoded['todos'], Todo.fromJson));
          _goals
            ..clear()
            ..addAll(_decodeList(decoded['goals'], Goal.fromJson));
          monthlyBudget = (decoded['monthlyBudget'] as num?)?.toDouble() ?? 25000;
          accentColorValue = (decoded['accentColorValue'] as num?)?.toInt() ?? 0xFF675CF6;
          currencyCode = decoded['currencyCode'] as String? ?? 'INR';
          final themeName = decoded['themeMode'] as String? ?? 'system';
          themeMode = ThemeMode.values.firstWhere((m) => m.name == themeName, orElse: () => ThemeMode.system);
        }
      }
    } catch (_) {
      // A damaged local cache should not prevent the app from launching.
      _expenses.clear();
      _todos.clear();
      _goals.clear();
    } finally {
      isLoaded = true;
      notifyListeners();
    }
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

  void _changed() {
    notifyListeners();
    final payload = jsonEncode(_toMap());
    _saveQueue = _saveQueue.then((_) => _preferences.setString(_storageKey, payload)).catchError((Object _) {});
  }

  Future<void> waitForSave() => _saveQueue;

  void addExpense(Expense expense) {
    _expenses.insert(0, expense);
    _expenses.sort((a, b) => b.date.compareTo(a.date));
    _changed();
  }

  void updateExpense(Expense updated) {
    final index = _expenses.indexWhere((e) => e.id == updated.id);
    if (index < 0) return;
    _expenses[index] = updated;
    _expenses.sort((a, b) => b.date.compareTo(a.date));
    _changed();
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    _changed();
  }

  void addTodo(Todo todo) {
    _todos.insert(0, todo);
    _changed();
  }

  void updateTodo(Todo updated) {
    final index = _todos.indexWhere((t) => t.id == updated.id);
    if (index < 0) return;
    _todos[index] = updated;
    _todos.sort((a, b) {
      if (a.completed != b.completed) return a.completed ? 1 : -1;
      if (a.dueDate == null && b.dueDate == null) return b.createdAt.compareTo(a.createdAt);
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    _changed();
  }

  void toggleTodo(String id) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index < 0) return;
    _todos[index] = _todos[index].copyWith(completed: !_todos[index].completed);
    _changed();
  }

  void deleteTodo(String id) {
    _todos.removeWhere((t) => t.id == id);
    _changed();
  }

  void addGoal(Goal goal) {
    _goals.insert(0, goal);
    _changed();
  }

  void updateGoal(Goal updated) {
    final index = _goals.indexWhere((g) => g.id == updated.id);
    if (index < 0) return;
    _goals[index] = updated;
    _changed();
  }

  void contributeToGoal(String id, double amount) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index < 0 || amount <= 0) return;
    _goals[index] = _goals[index].copyWith(savedAmount: _goals[index].savedAmount + amount);
    _changed();
  }

  void deleteGoal(String id) {
    _goals.removeWhere((g) => g.id == id);
    _changed();
  }

  void setMonthlyBudget(double amount) {
    if (amount <= 0) return;
    monthlyBudget = amount;
    _changed();
  }

  void setThemeMode(ThemeMode value) {
    themeMode = value;
    _changed();
  }

  void setAccentColor(Color value) {
    accentColorValue = value.toARGB32();
    _changed();
  }

  void setCurrency(String value) {
    currencyCode = value;
    _changed();
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
    await waitForSave();
  }

  void clearFinancialData() {
    _expenses.clear();
    _todos.clear();
    _goals.clear();
    _changed();
  }
}
