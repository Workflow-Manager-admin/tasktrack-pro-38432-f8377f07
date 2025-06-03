import 'package:flutter/material.dart';

/// Modal dialog for creating a new task.
/// Includes title, description, due date and due time pickers.
/// Designed for a modern, visually appealing, and accessible UX.
class TaskCreationDialog extends StatefulWidget {
  const TaskCreationDialog({super.key});

  // PUBLIC_INTERFACE
  @override
  State<TaskCreationDialog> createState() => _TaskCreationDialogState();
}

class _TaskCreationDialogState extends State<TaskCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  bool _submitting = false;

  // Color constants
  static const primaryColor = Color(0xFF1976D2);
  static const accentColor = Color(0xFFFFC107);

  Future<void> _pickDueDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365 * 5)),
      helpText: 'Select Due Date',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _pickDueTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
      helpText: 'Select Due Time',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  // PUBLIC_INTERFACE
  @override
  Widget build(BuildContext context) {
    InputDecoration modernInputDecoration(
      String label, {
      String? hint,
      Widget? suffixIcon,
      int? maxLines = 1,
    }) {
      return InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        // Use .withAlpha instead of .withOpacity (which is deprecated)
        fillColor: primaryColor.withAlpha((0.04 * 255).round()),
        filled: true,
        suffixIcon: suffixIcon,
      );
    }

    return Dialog(
      backgroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 300, maxWidth: 450),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Create Task",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Title
                  TextFormField(
                    autofocus: true,
                    decoration: modernInputDecoration(
                      "Title",
                      hint: "Enter task title",
                    ),
                    maxLength: 60,
                    validator: (v) =>
                      v == null || v.trim().isEmpty
                        ? "Title is required"
                        : null,
                    onChanged: (v) => _title = v.trim(),
                  ),
                  const SizedBox(height: 16),
                  // Description
                  TextFormField(
                    decoration: modernInputDecoration(
                      "Description",
                      hint: "Add optional details",
                    ),
                    maxLines: 3,
                    maxLength: 240,
                    onChanged: (v) => _description = v.trim(),
                  ),
                  const SizedBox(height: 16),
                  // Due Date
                  GestureDetector(
                    onTap: _pickDueDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: modernInputDecoration(
                          "Due Date",
                          suffixIcon: const Icon(Icons.calendar_month, color: primaryColor),
                        ),
                        controller: TextEditingController(
                          text: _dueDate == null
                              ? ''
                              : "${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}",
                        ),
                        validator: (v) =>
                          _dueDate == null ? "Due date required" : null,
                        readOnly: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Due Time
                  GestureDetector(
                    onTap: _pickDueTime,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: modernInputDecoration(
                          "Due Time",
                          suffixIcon: const Icon(Icons.schedule, color: primaryColor),
                        ),
                        controller: TextEditingController(
                          text: _dueTime == null
                              ? ''
                              : _dueTime!.format(context),
                        ),
                        validator: (v) =>
                          _dueTime == null ? "Due time required" : null,
                        readOnly: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: _submitting
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            setState(() => _submitting = true);

                            // Compose DateTime value
                            final due = DateTime(
                              _dueDate!.year,
                              _dueDate!.month,
                              _dueDate!.day,
                              _dueTime!.hour,
                              _dueTime!.minute,
                            );
                            Navigator.of(context).pop(<String, dynamic>{
                              'title': _title,
                              'description': _description,
                              'due': due,
                            });
                          },
                    style: FilledButton.styleFrom(
                      elevation: 2,
                      backgroundColor: accentColor,
                      foregroundColor: Colors.black,
                      shadowColor: Colors.black12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(primaryColor),
                              strokeWidth: 2.2,
                            ),
                          )
                        : const Text("Add Task"),
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
