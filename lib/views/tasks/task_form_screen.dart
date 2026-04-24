import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../controllers/task_controller.dart';
import '../../core/database/database_helper.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../widgets/user_avatar.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String creatorId;
  final TaskModel? task;

  const TaskFormScreen({
    super.key,
    required this.projectId,
    required this.creatorId,
    this.task,
  });

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late TaskPriority _priority;
  String? _assigneeId;
  DateTime? _dueDate;
  bool _loading = false;
  List<UserModel> _users = [];

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task?.title ?? '');
    _descCtrl = TextEditingController(text: widget.task?.description ?? '');
    _priority = widget.task?.priority ?? TaskPriority.medium;
    _assigneeId = widget.task?.assigneeId;
    _dueDate = widget.task?.dueDate;
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await DatabaseHelper.instance.getAllUsers();
    if (mounted) setState(() => _users = users);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final notifier =
        ref.read(taskControllerProvider(widget.projectId).notifier);

    if (_isEditing) {
      await notifier.updateTask(widget.task!.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        priority: _priority,
        assigneeId: _assigneeId,
        dueDate: _dueDate,
        clearAssignee: _assigneeId == null,
        clearDueDate: _dueDate == null,
      ));
    } else {
      await notifier.addTask(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        priority: _priority,
        creatorId: widget.creatorId,
        assigneeId: _assigneeId,
        dueDate: _dueDate,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                _isEditing ? l10n.editTask : l10n.addTask,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),

              // Titre
              TextFormField(
                controller: _titleCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: '${l10n.taskTitle} *'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: 14),

              // Description
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: l10n.taskDescription),
              ),
              const SizedBox(height: 18),

              // Priorité
              Text(l10n.priority,
                  style: theme.textTheme.labelMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SegmentedButton<TaskPriority>(
                segments: [
                  ButtonSegment(
                      value: TaskPriority.low, label: Text(l10n.priority_low)),
                  ButtonSegment(
                      value: TaskPriority.medium,
                      label: Text(l10n.priority_medium)),
                  ButtonSegment(
                      value: TaskPriority.high,
                      label: Text(l10n.priority_high)),
                ],
                selected: {_priority},
                onSelectionChanged: (s) => setState(() => _priority = s.first),
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(height: 18),

              // Assigner à
              Text(l10n.assignTo,
                  style: theme.textTheme.labelMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (_users.isEmpty)
                Text(l10n.noUsersAvailable, style: theme.textTheme.bodySmall)
              else
                SizedBox(
                  height: 56,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final u = _users[index];
                      final isSelected = _assigneeId == u.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () => setState(
                              () => _assigneeId = isSelected ? null : u.id),
                          child: Stack(
                            children: [
                              UserAvatar(
                                user: u,
                                size: 48,
                                backgroundColor: isSelected
                                    ? theme.colorScheme.primary
                                    : null,
                              ),
                              if (isSelected)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: theme.scaffoldBackgroundColor,
                                          width: 2),
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: const Icon(Icons.check,
                                        size: 10, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 18),

              // Date d'échéance
              Text(l10n.dueDate,
                  style: theme.textTheme.labelMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        _dueDate == null
                            ? l10n.noDateSet
                            : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      if (_dueDate != null)
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(() => _dueDate = null),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(_isEditing ? l10n.update : l10n.create),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
