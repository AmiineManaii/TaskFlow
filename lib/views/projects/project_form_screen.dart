import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/project_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../models/project_model.dart';

class ProjectFormScreen extends ConsumerStatefulWidget {
  final String userId;
  final ProjectModel? project;

  const ProjectFormScreen({
    super.key,
    required this.userId,
    this.project,
  });

  @override
  ConsumerState<ProjectFormScreen> createState() =>
      _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late String _selectedColor;
  bool _loading = false;

  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.project?.name ?? '');
    _descCtrl =
        TextEditingController(text: widget.project?.description ?? '');
    _selectedColor = widget.project?.color ?? '#2563EB';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final notifier =
        ref.read(projectControllerProvider(widget.userId).notifier);

    if (_isEditing) {
      await notifier.updateProject(widget.project!.copyWith(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        color: _selectedColor,
      ));
    } else {
      await notifier.addProject(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        color: _selectedColor,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
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
              // Handle bar
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
                _isEditing ? 'Modifier le projet' : 'Nouveau projet',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Nom du projet'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _descCtrl,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 20),

              Text('Couleur',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: AppColors.projectColors.map((color) {
                  final hex = _colorToHex(color);
                  final selected = _selectedColor == hex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = hex),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(
                                color: theme.colorScheme.onSurface,
                                width: 3)
                            : null,
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                    color: color.withOpacity(0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2))
                              ]
                            : null,
                      ),
                      child: selected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
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
                          : Text(_isEditing ? 'Mettre à jour' : 'Créer'),
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
