import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/features/students/widgets/student_form_sheet.dart';

/// Öğrenci düzenleme formu (alt sayfa).
void showStudentEditDialog(
  BuildContext context,
  WidgetRef ref,
  Student student,
) {
  showStudentFormSheet(context, ref, student: student);
}
