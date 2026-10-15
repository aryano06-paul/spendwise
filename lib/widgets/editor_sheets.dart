import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models/expense.dart';
import '../models/goal.dart';
import '../models/todo.dart';
import '../utils/app_format.dart';
import 'controller_scope.dart';

String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

Future<void> showExpenseEditor(BuildContext context, SpendWiseState state, {Expense? existing}) async {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController(text: existing?.title ?? '');
  final amountController = TextEditingController(text: existing == null ? '' : existing.amount.toStringAsFixed(2));
  final noteController = TextEditingController(text: existing?.note ?? '');
  var category = existing?.category ?? ExpenseCategory.food;
  var date = existing?.date ?? DateTime.now();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) => ControllerScope(
      controllers: [titleController, amountController, noteController],
      child: StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(existing == null ? 'Add expense' : 'Edit expense', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 18),
                TextFormField(controller: titleController, autofocus: true, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'What did you spend on?', prefixIcon: Icon(Icons.edit_note_rounded)), validator: (value) => value == null || value.trim().isEmpty ? 'Enter a name for this expense' : null),
                const SizedBox(height: 12),
                TextFormField(controller: amountController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'Amount (${currencySymbol(state.currencyCode)})', prefixIcon: const Icon(Icons.payments_outlined)), validator: (value) { final amount = double.tryParse(value?.trim() ?? ''); if (amount == null || !amount.isFinite || amount <= 0) return 'Enter an amount greater than zero'; return null; }),
                const SizedBox(height: 12),
                DropdownButtonFormField<ExpenseCategory>(initialValue: category, decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category_outlined)), items: ExpenseCategory.values.map((item) => DropdownMenuItem(value: item, child: Text(item.label))).toList(), onChanged: (value) { if (value != null) setSheetState(() => category = value); }),
                const SizedBox(height: 12),
                OutlinedButton.icon(onPressed: () async { final today = DateTime.now(); final safeInitialDate = date.isAfter(today) ? today : date; final picked = await showDatePicker(context: context, initialDate: safeInitialDate, firstDate: DateTime(1900), lastDate: today); if (picked != null) setSheetState(() => date = picked); }, icon: const Icon(Icons.calendar_month_rounded), label: Text('Date: ${formatDate(date)}')),
                const SizedBox(height: 12),
                TextFormField(controller: noteController, maxLines: 2, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Note (optional)', prefixIcon: Icon(Icons.notes_rounded))),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () { if (!(formKey.currentState?.validate() ?? false)) return; final entry = Expense(id: existing?.id ?? _newId(), title: titleController.text.trim(), amount: double.parse(amountController.text.trim()), category: category, date: date, note: noteController.text.trim()); if (existing == null) { state.addExpense(entry); } else { state.updateExpense(entry); } Navigator.of(sheetContext).pop(); }, icon: const Icon(Icons.check_rounded), label: Text(existing == null ? 'Save expense' : 'Save changes'))),
              ]),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> showTodoEditor(BuildContext context, SpendWiseState state, {Todo? existing}) async {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController(text: existing?.title ?? '');
  final notesController = TextEditingController(text: existing?.notes ?? '');
  var priority = existing?.priority ?? TodoPriority.medium;
  var dueDate = existing?.dueDate;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) => ControllerScope(controllers: [titleController, notesController], child: StatefulBuilder(builder: (context, setSheetState) => Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(child: Form(key: formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(existing == null ? 'New task' : 'Edit task', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 18),
        TextFormField(controller: titleController, autofocus: true, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Task title', prefixIcon: Icon(Icons.checklist_rounded)), validator: (value) => value == null || value.trim().isEmpty ? 'Enter a task title' : null),
        const SizedBox(height: 12),
        TextFormField(controller: notesController, textCapitalization: TextCapitalization.sentences, maxLines: 2, decoration: const InputDecoration(labelText: 'Details (optional)', prefixIcon: Icon(Icons.notes_rounded))),
        const SizedBox(height: 12),
        DropdownButtonFormField<TodoPriority>(initialValue: priority, decoration: const InputDecoration(labelText: 'Priority', prefixIcon: Icon(Icons.flag_outlined)), items: TodoPriority.values.map((value) => DropdownMenuItem(value: value, child: Text(value.label))).toList(), onChanged: (value) { if (value != null) setSheetState(() => priority = value); }),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [OutlinedButton.icon(onPressed: () async { final today = DateTime.now(); final maxDate = today.add(const Duration(days: 3650)); final proposedDate = dueDate ?? today; final safeInitialDate = proposedDate.isAfter(maxDate) ? maxDate : proposedDate; final picked = await showDatePicker(context: context, initialDate: safeInitialDate, firstDate: DateTime(1900), lastDate: maxDate); if (picked != null) setSheetState(() => dueDate = picked); }, icon: const Icon(Icons.calendar_month_rounded), label: Text(dueDate == null ? 'Set due date' : formatDate(dueDate!))), if (dueDate != null) TextButton.icon(onPressed: () => setSheetState(() => dueDate = null), icon: const Icon(Icons.close_rounded), label: const Text('Clear date'))]),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () { if (!(formKey.currentState?.validate() ?? false)) return; final todo = Todo(id: existing?.id ?? _newId(), title: titleController.text.trim(), notes: notesController.text.trim(), createdAt: existing?.createdAt ?? DateTime.now(), dueDate: dueDate, priority: priority, completed: existing?.completed ?? false); if (existing == null) { state.addTodo(todo); } else { state.updateTodo(todo); } Navigator.of(sheetContext).pop(); }, icon: const Icon(Icons.check_rounded), label: Text(existing == null ? 'Create task' : 'Save task'))),
      ]))),
    ))),
  );
}

Future<void> showGoalEditor(BuildContext context, SpendWiseState state, {Goal? existing}) async {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController(text: existing?.title ?? '');
  final descriptionController = TextEditingController(text: existing?.description ?? '');
  final targetController = TextEditingController(text: existing == null ? '' : existing.targetAmount.toStringAsFixed(0));
  var deadline = existing?.deadline;
  var iconKey = existing?.iconKey ?? 'savings';
  const iconChoices = <String, String>{'savings': 'Savings', 'travel': 'Travel', 'laptop': 'Laptop', 'home': 'Home', 'education': 'Education', 'emergency': 'Emergency fund'};
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) => ControllerScope(controllers: [titleController, descriptionController, targetController], child: StatefulBuilder(builder: (context, setSheetState) => Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(child: Form(key: formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(existing == null ? 'Create a goal' : 'Edit goal', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 18),
        TextFormField(controller: titleController, autofocus: true, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Goal name', prefixIcon: Icon(Icons.flag_rounded)), validator: (value) => value == null || value.trim().isEmpty ? 'Enter a goal name' : null),
        const SizedBox(height: 12),
        TextFormField(controller: targetController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'Target amount (${currencySymbol(state.currencyCode)})', prefixIcon: const Icon(Icons.savings_outlined)), validator: (value) { final amount = double.tryParse(value?.trim() ?? ''); if (amount == null || !amount.isFinite || amount <= 0) return 'Enter a target greater than zero'; return null; }),
        const SizedBox(height: 12),
        TextFormField(controller: descriptionController, maxLines: 2, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Why is this important? (optional)', prefixIcon: Icon(Icons.notes_rounded))),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(initialValue: iconKey, decoration: const InputDecoration(labelText: 'Goal type', prefixIcon: Icon(Icons.interests_rounded)), items: iconChoices.entries.map((item) => DropdownMenuItem(value: item.key, child: Text(item.value))).toList(), onChanged: (value) { if (value != null) setSheetState(() => iconKey = value); }),
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: [OutlinedButton.icon(onPressed: () async { final today = DateTime.now(); final todayDate = DateTime(today.year, today.month, today.day); final proposedDate = deadline ?? todayDate.add(const Duration(days: 90)); final maxDate = todayDate.add(const Duration(days: 3650)); final safeInitialDate = proposedDate.isBefore(todayDate) ? todayDate : (proposedDate.isAfter(maxDate) ? maxDate : proposedDate); final picked = await showDatePicker(context: context, initialDate: safeInitialDate, firstDate: todayDate, lastDate: maxDate); if (picked != null) setSheetState(() => deadline = picked); }, icon: const Icon(Icons.event_rounded), label: Text(deadline == null ? 'Optional deadline' : formatDate(deadline!))), if (deadline != null) TextButton(onPressed: () => setSheetState(() => deadline = null), child: const Text('Clear'))]),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () { if (!(formKey.currentState?.validate() ?? false)) return; final target = double.parse(targetController.text.trim()); final goal = Goal(id: existing?.id ?? _newId(), title: titleController.text.trim(), description: descriptionController.text.trim(), targetAmount: target, savedAmount: existing?.savedAmount ?? 0, createdAt: existing?.createdAt ?? DateTime.now(), deadline: deadline, iconKey: iconKey); if (existing == null) { state.addGoal(goal); } else { state.updateGoal(goal); } Navigator.of(sheetContext).pop(); }, icon: const Icon(Icons.check_rounded), label: Text(existing == null ? 'Create goal' : 'Save goal'))),
      ]))),
    ))),
  );
}

Future<void> showGoalContributionDialog(BuildContext context, SpendWiseState state, Goal goal) async {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  await showDialog<void>(context: context, builder: (dialogContext) => ControllerScope(controllers: [controller], child: AlertDialog(
    title: Text('Add to ${goal.title}'),
    content: Form(key: formKey, child: TextFormField(controller: controller, autofocus: true, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'Amount (${currencySymbol(state.currencyCode)})'), validator: (value) { final amount = double.tryParse(value?.trim() ?? ''); if (amount == null || !amount.isFinite || amount <= 0) return 'Enter an amount greater than zero'; return null; })),
    actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')), FilledButton(onPressed: () { if (!(formKey.currentState?.validate() ?? false)) return; state.contributeToGoal(goal.id, double.parse(controller.text.trim())); Navigator.pop(dialogContext); }, child: const Text('Add savings'))],
  )));
}

Future<bool> confirmDelete(BuildContext context, {required String title, required String message}) async {
  final result = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete'))],
  ));
  return result ?? false;
}