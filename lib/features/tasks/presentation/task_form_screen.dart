import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/picker_form_field.dart';
import '../../subjects/data/subject_repository.dart';
import '../data/task_repository.dart';
import '../domain/task.dart';

/// Жаңа тапсырма қосу және өңдеу (task == null → жаңа). Міндетті өрістер тексеріледі.
class TaskFormScreen extends StatefulWidget {
  final Task? task;
  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  String? _subjectId;
  bool _saving = false;
  DateTime? _deadline;
  late String _reminder;

  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _title = TextEditingController(text: t?.title ?? '');
    _description = TextEditingController(text: t?.description ?? '');
    _subjectId = t?.subjectId;
    _deadline = t?.deadline;
    _reminder = t?.reminder ?? AppStrings.reminderOptions.first;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  String? _validateDate(DateTime? v) {
    if (v == null) return AppStrings.chooseDate;
    // Жаңа тапсырмада өткен күнге мерзім қоюға болмайды
    if (!_isEdit && dateOnly(v).isBefore(dateOnly(DateTime.now()))) {
      return AppStrings.pastDate;
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    final repo = TaskRepository.instance;
    final old = widget.task;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final bool ok;
    if (old == null) {
      ok = await repo.create(
        title: _title.text,
        subjectId: _subjectId!,
        deadline: _deadline!,
        description: _description.text,
        reminder: _reminder,
      );
    } else {
      ok = await repo.update(old.copyWith(
        title: _title.text.trim(),
        subjectId: _subjectId,
        deadline: _deadline,
        description: _description.text.trim(),
        reminder: _reminder,
      ));
    }
    if (!mounted) return;
    if (!ok) {
      // Қате хабарламасы көрсетілді, форма ашық қалады — деректер жоғалмайды
      setState(() => _saving = false);
      return;
    }
    navigator.pop();
    messenger.showSnackBar(SnackBar(
        content: Text(_isEdit ? AppStrings.taskUpdated : AppStrings.taskAdded)));
  }

  @override
  Widget build(BuildContext context) {
    final repoSubjects = SubjectRepository.instance;
    final subjects = repoSubjects.all;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? AppStrings.editTask : AppStrings.newTask),
      ),
      body: SafeArea(
        child: ContentWidth(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: AppStrings.taskTitle,
                    controller: _title,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        Validators.required(v, AppStrings.enterTitle),
                  ),
                  const SizedBox(height: 12),
                  PickerFormField(
                    label: AppStrings.subject,
                    icon: Icons.menu_book_outlined,
                    items: subjects.map((s) => s.name).toList(),
                    initialValue:
                        _subjectId == null ? null : repoSubjects.nameOf(_subjectId!),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? AppStrings.chooseSubject : null,
                    onSelected: (v) => _subjectId = repoSubjects.byName(v)?.id,
                  ),
                  const SizedBox(height: 12),
                  DateFormField(
                    label: AppStrings.deadline,
                    initialValue: _deadline,
                    validator: _validateDate,
                    onSelected: (v) => _deadline = v,
                  ),
                  const SizedBox(height: 12),
                  PickerFormField(
                    label: AppStrings.reminder,
                    icon: Icons.notifications_none,
                    items: AppStrings.reminderOptions,
                    initialValue: _reminder,
                    onSelected: (v) => _reminder = v,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: AppStrings.description,
                    controller: _description,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: AppStrings.save,
                    onPressed: _saving ? null : _save,
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: AppStrings.cancel,
                    type: AppButtonType.secondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
