import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ozel_ders_takip/app/router.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/features/students/widgets/student_edit_dialog.dart';
import 'package:ozel_ders_takip/shared/utils/name_format.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  bool _showInactive = false;

  @override
  Widget build(BuildContext context) {
    // ref.watch yerine ref.read kullan - stream zaten reactive
    final studentsRepo = ref.read(studentsRepoProvider);
    final studentsStream = studentsRepo.watchAllStudents(includeInactive: _showInactive);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenciler'),
        actions: [
          PopupMenuButton<bool>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _showInactive = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: false,
                child: Text('Sadece Aktif Öğrenciler'),
              ),
              const PopupMenuItem(
                value: true,
                child: Text('Tüm Öğrenciler (Pasif Dahil)'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Student>>(
        stream: studentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Hata: ${snapshot.error}'),
            );
          }

          final students = snapshot.data ?? [];

          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Henüz öğrenci eklenmemiş',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddStudentDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('İlk Öğrenciyi Ekle'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final isInactive = !student.isActive;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isInactive ? Colors.grey : null,
                  child: Text(student.fullName[0].toUpperCase()),
                ),
                title: Text(
                  student.fullName,
                  style: TextStyle(
                    color: isInactive ? Colors.grey : null,
                    decoration: isInactive ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (student.phone != null)
                      Text(
                        student.phone!,
                        style: TextStyle(color: isInactive ? Colors.grey : null),
                      )
                    else
                      const Text('Telefon yok'),
                    if (isInactive)
                      const Text(
                        'Pasif',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${student.hourlyRate} ₺/saat',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isInactive ? Colors.grey : null,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => showStudentEditDialog(context, ref, student),
                      tooltip: 'Düzenle',
                    ),
                  ],
                ),
                onTap: () {
                  context.push(
                    '${AppRouter.students}/${student.id}',
                    extra: student,
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStudentDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context, WidgetRef ref) {
    final messenger = ScaffoldMessenger.of(context);
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final hourlyRateController = TextEditingController();
    final notesController = TextEditingController();
    final guardianNameController = TextEditingController();
    final guardianPhoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Yeni Öğrenci Ekle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad *',
                  border: OutlineInputBorder(),
                  hintText: 'Örn. Ahmet Mehmet YILMAZ',
                ),
                autofocus: true,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                onEditingComplete: () {
                  nameController.text =
                      formatPersonFullName(nameController.text);
                  nameController.selection = TextSelection.collapsed(
                    offset: nameController.text.length,
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefon',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: hourlyRateController,
                decoration: const InputDecoration(
                  labelText: 'Saatlik Ücret (TL) *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notlar',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: guardianNameController,
                decoration: const InputDecoration(
                  labelText: 'Veli Ad Soyad',
                  border: OutlineInputBorder(),
                  hintText: 'Örn. Ayşe YILMAZ',
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                onEditingComplete: () {
                  guardianNameController.text =
                      formatPersonFullName(guardianNameController.text);
                  guardianNameController.selection = TextSelection.collapsed(
                    offset: guardianNameController.text.length,
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: guardianPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Veli Telefon',
                  border: OutlineInputBorder(),
                  hintText: '5XX XXX XX XX',
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = formatPersonFullName(nameController.text);
              final phone = phoneController.text.trim();
              final hourlyRateStr = hourlyRateController.text.trim();
              final notes = notesController.text.trim();
              final guardianFullName =
                  formatPersonFullName(guardianNameController.text);
              final guardianPhone = guardianPhoneController.text.trim();

              nameController.text = name;
              guardianNameController.text = guardianFullName;

              if (name.isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Ad soyad gereklidir')),
                );
                return;
              }

              final hourlyRate = int.tryParse(hourlyRateStr);
              if (hourlyRate == null || hourlyRate <= 0) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Geçerli bir saatlik ücret giriniz')),
                );
                return;
              }
              if (phone.isNotEmpty && phone.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Telefon en az 10 haneli olmalıdır')),
                );
                return;
              }
              if (guardianPhone.isNotEmpty && guardianPhone.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Veli telefonu en az 10 haneli olmalıdır')),
                );
                return;
              }

              try {
                final studentsRepo = ref.read(studentsRepoProvider);
                await studentsRepo.insertStudent(
                  fullName: name,
                  phone: phone.isEmpty ? null : phone,
                  hourlyRate: hourlyRate,
                  notes: notes.isEmpty ? null : notes,
                  guardianFullName: guardianFullName.isEmpty ? null : guardianFullName,
                  guardianPhone: guardianPhone.isEmpty ? null : guardianPhone,
                );

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Öğrenci eklendi')),
                  );
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Hata: $e')),
                  );
                }
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }
}
