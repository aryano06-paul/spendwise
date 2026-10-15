import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../utils/app_format.dart';
import '../widgets/controller_scope.dart';
import '../widgets/editor_sheets.dart';

class AppearanceScreen extends StatelessWidget {
  final SpendWiseState state;
  const AppearanceScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance & settings', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 26),
        children: [
          Text('Make it yours', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text('Your choices are saved to your account.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 20),
          _SectionCard(
            title: 'Account',
            subtitle: FirebaseAuth.instance.currentUser?.email ?? 'Signed in',
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _signOut(context),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign out'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Theme',
            subtitle: 'Choose how SpendWise appears',
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_rounded), label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_rounded), label: Text('Dark')),
                ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.settings_suggest_rounded), label: Text('System')),
              ],
              selected: {state.themeMode},
              onSelectionChanged: (value) => state.setThemeMode(value.first),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Accent color',
            subtitle: 'Updates highlights and active controls throughout the app',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: SpendWiseState.accentOptions.map((color) {
                final selected = color.toARGB32() == state.accentColorValue;
                return Semantics(
                  label: 'Select accent color',
                  button: true,
                  child: InkWell(
                    onTap: () => state.setAccentColor(color),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 47,
                      height: 47,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: selected ? Theme.of(context).colorScheme.onSurface : Colors.transparent, width: 2),
                      ),
                      child: Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                        child: selected ? const Icon(Icons.check_rounded, color: Colors.white) : null,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Currency',
            subtitle: 'Used for display only; changing currency does not convert amounts already entered.',
            child: DropdownButtonFormField<String>(
              initialValue: state.currencyCode,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.currency_exchange_rounded)),
              items: const [
                DropdownMenuItem(value: 'INR', child: Text('INR · Indian rupee (₹)')),
                DropdownMenuItem(value: 'USD', child: Text('USD · US dollar (\$)')),
                DropdownMenuItem(value: 'EUR', child: Text('EUR · Euro (€)')),
                DropdownMenuItem(value: 'GBP', child: Text('GBP · Pound sterling (£)')),
              ],
              onChanged: (value) { if (value != null) state.setCurrency(value); },
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Monthly budget',
            subtitle: 'Current budget: ${formatMoney(state.monthlyBudget, state.currencyCode)}',
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _editBudget(context),
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Change monthly budget'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Backup & restore',
            subtitle: 'Copy a JSON backup somewhere safe. Restoring will replace your current expenses, tasks, goals and settings.',
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: state.exportBackup()));
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup copied to clipboard')));
                    },
                    icon: const Icon(Icons.copy_all_rounded),
                    label: const Text('Copy backup to clipboard'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: state.exportExpensesCsv()));
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV transaction export copied to clipboard')));
                    },
                    icon: const Icon(Icons.table_chart_rounded),
                    label: const Text('Export transactions as CSV'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _restoreBackup(context),
                    icon: const Icon(Icons.restore_rounded),
                    label: const Text('Restore from JSON'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Data management',
            subtitle: 'Your data is saved to your private account and is not connected to your bank.',
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
                onPressed: () async {
                  final confirmed = await confirmDelete(
                    context,
                    title: 'Clear all data?',
                    message: 'This removes every expense, task, and goal from your account. Export a backup first if you may need it.',
                  );
                  if (confirmed) {
                    state.clearFinancialData();
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expenses, tasks, and goals cleared')));
                  }
                },
                icon: const Icon(Icons.delete_forever_rounded),
                label: const Text('Clear expenses, tasks & goals'),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(child: Text('SpendWise Aurora · Version 1.0.0', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
          const SizedBox(height: 5),
          Center(child: Text('Personal budgeting · No bank connection', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    // Close this screen first so no page of the old account stays open.
    Navigator.of(context).popUntil((route) => route.isFirst);
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _editBudget(BuildContext context) async {
    final controller = TextEditingController(text: state.monthlyBudget.toStringAsFixed(0));
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Monthly budget'),
        content: ControllerScope(
          controllers: [controller],
          child: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: 'Budget (${currencySymbol(state.currencyCode)})'),
            validator: (value) {
              final amount = double.tryParse(value?.trim() ?? '');
              if (amount == null || !amount.isFinite || amount <= 0) return 'Enter a budget greater than zero';
              return null;
            },
          ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              state.setMonthlyBudget(double.parse(controller.text.trim()));
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreBackup(BuildContext context) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final content = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore backup'),
        content: ControllerScope(
          controllers: [controller],
          child: Form(
          key: formKey,
          child: SizedBox(
            width: 480,
            child: TextFormField(
              controller: controller,
              minLines: 5,
              maxLines: 10,
              decoration: const InputDecoration(hintText: 'Paste the SpendWise JSON backup here'),
              validator: (value) => value == null || value.trim().isEmpty ? 'Paste the backup first' : null,
            ),
          ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              Navigator.pop(dialogContext, controller.text);
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (content == null || !context.mounted) return;

    final shouldReplace = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Replace current data?'),
        content: const Text('Restoring this backup replaces the current lists and settings in your account.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Replace data')),
        ],
      ),
    );
    if (shouldReplace != true || !context.mounted) return;

    try {
      await state.importBackup(content);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup restored successfully')));
    } catch (error) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not restore backup: $error')));
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _SectionCard({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 15),
          child,
        ],
      ),
    ),
  );
}
