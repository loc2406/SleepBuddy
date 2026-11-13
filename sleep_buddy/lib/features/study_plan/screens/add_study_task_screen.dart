import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_buddy/core/config/app_style.dart';
import 'package:sleep_buddy/core/utils/responsive.dart';
import 'package:sleep_buddy/features/study_plan/cubit/add_new_study_plan_cubit.dart';
import 'package:sleep_buddy/features/study_plan/cubit/add_new_study_plan_state.dart';

import '../model/models.dart';

class AddStudyTaskScreen extends StatefulWidget {
  const AddStudyTaskScreen({super.key});

  @override
  State<AddStudyTaskScreen> createState() => _AddStudyTaskScreenState();
}

class _AddStudyTaskScreenState extends State<AddStudyTaskScreen> {
  static const double _subjectControlHeight = 52;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectNameController = TextEditingController();
  late final AddNewStudyPlanCubit _cubit;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _cubit = context.read<AddNewStudyPlanCubit>();
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final currentDate = _cubit.state.lessonDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate.isBefore(today) ? today : currentDate,
      firstDate: today,
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: AppStyle.modalBuilder,
    );
    if (picked != null && mounted) {
      _cubit.selectLessonDate(picked);
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _cubit.state.startTime : _cubit.state.endTime,
      builder: AppStyle.modalBuilder,
    );
    if (picked != null && mounted) {
      if (isStart) {
        _cubit.selectStartTime(picked);
      } else {
        _cubit.selectEndTime(picked);
      }
    }
  }

  Future<void> _openAddSubjectDialog() async {
    _subjectNameController.clear();
    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final subjectFormKey = GlobalKey<FormState>();

        return Theme(
          data: AppStyle.dialogTheme(dialogContext),
          child: BlocBuilder<AddNewStudyPlanCubit, AddNewStudyPlanState>(
            builder: (context, state) => AlertDialog(
              title: const Text('Thêm môn học mới'),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: subjectFormKey,
                  child: TextFormField(
                    controller: _subjectNameController,
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: true,
                    decoration: _inputDecoration(
                      context,
                      hint: 'Ví dụ: Ngữ văn, Sinh học...',
                    ),
                    validator: (value) {
                      return _cubit.validateSubjectName(value);
                    },
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: state.isAddingSubject
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: state.isAddingSubject
                      ? null
                      : () async {
                          if (!subjectFormKey.currentState!.validate()) return;
                          try {
                            final subject = await _cubit.addSubject(
                              _subjectNameController.text,
                            );
                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext, true);
                            if (!mounted) return;
                            _showMessage('Đã thêm môn học "${subject.name}".');
                          } on StateError catch (error) {
                            if (!dialogContext.mounted) return;
                            ScaffoldMessenger.of(dialogContext)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(error.message.toString()),
                                ),
                              );
                          } on ArgumentError catch (error) {
                            if (!dialogContext.mounted) return;
                            ScaffoldMessenger.of(dialogContext)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(error.message.toString()),
                                ),
                              );
                          } on Exception {
                            if (!dialogContext.mounted) return;
                            ScaffoldMessenger.of(dialogContext)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                const SnackBar(
                                  content: Text('Không thể thêm môn học.'),
                                ),
                              );
                          }
                        },
                  child: Text(state.isAddingSubject ? 'Đang lưu...' : 'Thêm'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (created != true && mounted) {
      _subjectNameController.clear();
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final result = await _cubit.saveTask(
        title: _titleController.text,
        description: _descriptionController.text,
      );
      if (!mounted) return;
      switch (result) {
        case StudyTaskSaveResult.saved:
          context.pop(true);
          return;
        case StudyTaskSaveResult.alreadySaving:
          return;
        case StudyTaskSaveResult.missingSubject:
          _showMessage('Vui lòng chọn môn học.');
          return;
        case StudyTaskSaveResult.invalidTitle:
          _showMessage('Vui lòng nhập tên nhiệm vụ.');
          return;
        case StudyTaskSaveResult.savedButReminderFailed:
          _showMessage('Nhiệm vụ đã lưu nhưng không thể đặt thông báo nhắc.');
          context.pop(true);
          return;
        case StudyTaskSaveResult.invalidTimeRange:
          _showMessage('Giờ kết thúc phải sau giờ bắt đầu.');
          return;
        case StudyTaskSaveResult.startBeforeNow:
          _showMessage('Giờ bắt đầu không thể trước thời gian hiện tại.');
          return;
        case StudyTaskSaveResult.endBeforeNow:
          _showMessage('Giờ kết thúc không thể trước thời gian hiện tại.');
          return;
        case StudyTaskSaveResult.timeConflict:
          _showMessage('Khung giờ này bị trùng với một nhiệm vụ khác.');
          return;
      }
    } on Exception {
      if (!mounted) return;
      _showMessage('Không thể lưu nhiệm vụ. Vui lòng thử lại.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddNewStudyPlanCubit, AddNewStudyPlanState>(
      builder: (context, state) => Scaffold(
        backgroundColor: AppStyle.pageBackground(context),
        body: DecoratedBox(
          decoration: BoxDecoration(gradient: AppStyle.pageGradient(context)),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final padding = Responsive.getScreenPadding(
                  constraints.maxWidth,
                );
                final horizontalPadding = EdgeInsets.symmetric(
                  horizontal: padding.horizontal / 2,
                  vertical: 12,
                );

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: horizontalPadding,
                          sliver: SliverToBoxAdapter(
                            child: _buildHeader(context, state.isSaving),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding.horizontal / 2,
                            8,
                            horizontalPadding.horizontal / 2,
                            horizontalPadding.vertical +
                                MediaQuery.paddingOf(context).bottom,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildSectionCard(
                                    context,
                                    children: [
                                      _buildFieldLabel(context, 'Môn học'),
                                      _buildSubjectField(context, state),
                                      const SizedBox(height: 16),
                                      _buildFieldLabel(context, 'Tên nhiệm vụ'),
                                      TextFormField(
                                        controller: _titleController,
                                        textInputAction: TextInputAction.next,
                                        decoration: _inputDecoration(
                                          context,
                                          hint: 'Ví dụ: Ôn chương đạo hàm',
                                        ),
                                        validator: (value) {
                                          return context
                                              .read<AddNewStudyPlanCubit>()
                                              .validateTaskTitle(value);
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      _buildFieldLabel(context, 'Mô tả'),
                                      TextFormField(
                                        controller: _descriptionController,
                                        minLines: 3,
                                        maxLines: 5,
                                        decoration: _inputDecoration(
                                          context,
                                          hint: 'Nội dung cần hoàn thành...',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildSectionCard(
                                    context,
                                    children: [
                                      _buildFieldLabel(context, 'Ngày học'),
                                      _buildPickerButton(
                                        context,
                                        icon: Icons.calendar_month_outlined,
                                        label: _formatDate(state.lessonDate),
                                        onTap: _pickDate,
                                      ),
                                      const SizedBox(height: 16),
                                      LayoutBuilder(
                                        builder: (context, fieldConstraints) {
                                          final useTwoColumns =
                                              fieldConstraints.maxWidth >= 420;
                                          final startButton = _buildTimeField(
                                            context,
                                            label: 'Bắt đầu',
                                            time: state.startTime,
                                            onTap: () =>
                                                _pickTime(isStart: true),
                                          );
                                          final endButton = _buildTimeField(
                                            context,
                                            label: 'Kết thúc',
                                            time: state.endTime,
                                            onTap: () =>
                                                _pickTime(isStart: false),
                                          );

                                          if (!useTwoColumns) {
                                            return Column(
                                              children: [
                                                startButton,
                                                const SizedBox(height: 12),
                                                endButton,
                                              ],
                                            );
                                          }
                                          return Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(child: startButton),
                                              const SizedBox(width: 12),
                                              Expanded(child: endButton),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildSectionCard(
                                    context,
                                    children: [
                                      _buildFieldLabel(context, 'Mức ưu tiên'),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: LessonPriority.values.map((
                                          priority,
                                        ) {
                                          final selected =
                                              state.priority == priority;
                                          return ChoiceChip(
                                            label: Text(
                                              _priorityLabel(priority),
                                            ),
                                            selected: selected,
                                            selectedColor: AppStyle.tinted(
                                              context,
                                            ),
                                            backgroundColor: AppStyle.surface(
                                              context,
                                            ),
                                            side: BorderSide(
                                              color: selected
                                                  ? AppStyle.purple
                                                  : AppStyle.border(context),
                                            ),
                                            labelStyle: TextStyle(
                                              color: selected
                                                  ? AppStyle.purple
                                                  : AppStyle.muted(context),
                                              fontWeight: selected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                            ),
                                            onSelected: (_) => context
                                                .read<AddNewStudyPlanCubit>()
                                                .selectPriority(priority),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  FilledButton.icon(
                                    onPressed: state.isSaving ? null : _save,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppStyle.purple,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size.fromHeight(52),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    icon: state.isSaving
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.check),
                                    label: Text(
                                      state.isSaving
                                          ? 'Đang lưu...'
                                          : 'Lưu nhiệm vụ',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSaving) => Row(
    children: [
      IconButton(
        alignment: Alignment.center,
        onPressed: isSaving ? null : () => context.pop(),
        tooltip: 'Quay lại',
        style: IconButton.styleFrom(
          backgroundColor: AppStyle.surface(context),
          foregroundColor: AppStyle.ink(context),
          side: BorderSide(color: AppStyle.border(context)),
        ),
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          'Thêm nhiệm vụ mới',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppStyle.ink(context),
          ),
        ),
      ),
    ],
  );

  Widget _buildSectionCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppStyle.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppStyle.border(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05613E99),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppStyle.ink(context),
      ),
    ),
  );

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hint,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppStyle.muted(context)),
      filled: true,
      fillColor: AppStyle.tinted(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppStyle.border(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppStyle.border(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppStyle.purple, width: 1.5),
      ),
    );
  }

  Widget _buildSubjectField(BuildContext context, AddNewStudyPlanState state) {
    if (state.isLoadingSubjects) {
      return const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.subjectLoadError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.subjectLoadError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          TextButton(
            onPressed: () => _cubit.loadSubjects(),
            child: const Text('Thử tải lại'),
          ),
        ],
      );
    }
    if (state.subjects.isEmpty) {
      return _buildPickerButton(
        context,
        icon: Icons.add_circle_outline,
        label: 'Thêm môn học đầu tiên',
        onTap: _openAddSubjectDialog,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SizedBox(
            height: _subjectControlHeight,
            child: DropdownButtonFormField<StudySubject>(
              key: ValueKey(state.selectedSubject?.id),
              initialValue: state.selectedSubject,
              isExpanded: true,
              isDense: true,
              itemHeight: _subjectControlHeight,
              dropdownColor: AppStyle.surface(context),
              borderRadius: BorderRadius.circular(14),
              elevation: 4,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppStyle.ink(context),
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              decoration: _inputDecoration(context, hint: 'Chọn môn học')
                  .copyWith(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                  ),
              items: state.subjects
                  .map(
                    (subject) => DropdownMenuItem<StudySubject>(
                      value: subject,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            subject.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppStyle.ink(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _cubit.selectSubject,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _openAddSubjectDialog,
          tooltip: 'Thêm môn học mới',
          style: IconButton.styleFrom(
            backgroundColor: AppStyle.tinted(context),
            foregroundColor: AppStyle.purple,
            side: BorderSide(color: AppStyle.border(context)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            fixedSize: const Size.square(_subjectControlHeight),
            padding: EdgeInsets.zero,
          ),
          icon: const Icon(Icons.add, size: 22),
        ),
      ],
    );
  }

  Widget _buildPickerButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppStyle.tinted(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppStyle.border(context)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppStyle.purple),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppStyle.ink(context),
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppStyle.muted(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField(
    BuildContext context, {
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppStyle.muted(context),
          ),
        ),
        const SizedBox(height: 6),
        _buildPickerButton(
          context,
          icon: Icons.schedule_outlined,
          label: _formatTime(time),
          onTap: onTap,
        ),
      ],
    );
  }

  String _priorityLabel(LessonPriority priority) {
    switch (priority) {
      case LessonPriority.high:
        return 'Cao';
      case LessonPriority.medium:
        return 'Trung bình';
      case LessonPriority.low:
        return 'Thấp';
    }
  }
}
