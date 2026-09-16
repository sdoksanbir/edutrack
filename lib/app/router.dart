import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/features/home/home_screen.dart';
import 'package:ozel_ders_takip/features/students/students_screen.dart';
import 'package:ozel_ders_takip/features/students/students_detail_screen.dart';
import 'package:ozel_ders_takip/features/students/student_schedule_editor_screen.dart';
import 'package:ozel_ders_takip/features/schedule/schedule_screen.dart';
import 'package:ozel_ders_takip/features/lessons/lessons_screen.dart';
import 'package:ozel_ders_takip/features/lessons/lesson_create_screen.dart';
import 'package:ozel_ders_takip/features/lessons/lesson_detail_screen.dart';
import 'package:ozel_ders_takip/features/lessons/student_lessons_screen.dart';
import 'package:ozel_ders_takip/features/homework/homework_screen.dart';
import 'package:ozel_ders_takip/features/homework/student_homework_screen.dart';
import 'package:ozel_ders_takip/features/homework/lesson_homework_screen.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/features/payments/payments_screen.dart';
import 'package:ozel_ders_takip/features/payments/student_payment_detail_screen.dart';
import 'package:ozel_ders_takip/features/payments/guardian_payment_report_screen.dart';
import 'package:ozel_ders_takip/features/settings/settings_screen.dart';
import 'package:ozel_ders_takip/features/settings/parameters_screen.dart';
import 'package:ozel_ders_takip/features/todos/todos_screen.dart';
import 'package:ozel_ders_takip/shared/models/daily_lesson.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';

class AppRouter {
  static const String home = '/home';
  static const String students = '/students';
  static const String schedule = '/schedule';
  static const String lessons = '/lessons';
  static const String homeworks = '/homeworks';
  static const String payments = '/payments';
  static const String settings = '/settings';
  static const String settingsParameters = '/settings/parametreler';
  static const String todos = '/settings/yapilacaklar';

  static GoRouter get router => _router;

  static final _router = GoRouter(
    initialLocation: home,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationShell(child: child);
        },
        routes: [
          GoRoute(
            path: home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: students,
            builder: (context, state) => const StudentsScreen(),
          ),
          GoRoute(
            path: '$students/:id',
            builder: (context, state) {
              final student = state.extra as Student?;
              if (student == null) {
                // Eğer extra yoksa, ID'den öğrenciyi yükle
                // Şimdilik basit bir hata mesajı göster
                return const Scaffold(
                  body: Center(child: Text('Öğrenci bulunamadı')),
                );
              }
              return StudentsDetailScreen(student: student);
            },
            routes: [
              GoRoute(
                path: 'schedule',
                builder: (context, state) {
                  final studentId = state.extra as String? ?? 
                      state.pathParameters['id'] ?? '';
                  return StudentScheduleEditorScreen(studentId: studentId);
                },
              ),
            ],
          ),
          GoRoute(
            path: schedule,
            builder: (context, state) => const ScheduleScreen(),
          ),
          GoRoute(
            path: lessons,
            builder: (context, state) => const LessonsScreen(),
            routes: [
              GoRoute(
                path: 'student/:studentId',
                builder: (context, state) {
                  final studentId = state.pathParameters['studentId'] ?? '';
                  final studentName = state.extra as String? ?? studentId;
                  return StudentLessonsScreen(
                    studentId: studentId,
                    studentName: studentName,
                  );
                },
              ),
              GoRoute(
                path: 'create',
                builder: (context, state) {
                  final dailyLesson = state.extra as DailyLesson?;
                  if (dailyLesson == null) {
                    return const Scaffold(
                      body: Center(child: Text('Ders bilgisi bulunamadı')),
                    );
                  }
                  return LessonCreateScreen(dailyLesson: dailyLesson);
                },
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  // extra bir Map olabilir (lesson + scrollToPayments) veya direkt Lesson
                  dynamic extra = state.extra;
                  Lesson? lesson;
                  bool scrollToPayments = false;
                  
                  if (extra is Map) {
                    lesson = extra['lesson'] as Lesson?;
                    scrollToPayments = extra['scrollToPayments'] as bool? ?? false;
                  } else if (extra is Lesson) {
                    lesson = extra;
                  }
                  
                  if (lesson == null) {
                    return const Scaffold(
                      body: Center(child: Text('Ders bulunamadı')),
                    );
                  }
                  return LessonDetailScreen(
                    lesson: lesson,
                    scrollToPayments: scrollToPayments,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: homeworks,
            builder: (context, state) => const HomeworkScreen(),
            routes: [
              GoRoute(
                path: 'student/:studentId',
                builder: (context, state) {
                  final studentId = state.pathParameters['studentId'] ?? '';
                  final studentName = state.extra as String? ?? studentId;
                  return StudentHomeworkScreen(
                    studentId: studentId,
                    studentName: studentName,
                  );
                },
                routes: [
                  GoRoute(
                    path: 'lesson/:lessonId',
                    builder: (context, state) {
                      final studentId =
                          state.pathParameters['studentId'] ?? '';
                      final lessonId = state.pathParameters['lessonId'] ?? '';
                      final extra = state.extra as Map<String, dynamic>?;
                      final studentName =
                          extra?['studentName'] as String? ?? studentId;
                      final assignedAt =
                          extra?['assignedAt'] as DateTime? ?? DateTime.now();
                      final attentionOnly =
                          extra?['attentionOnly'] as bool? ?? false;
                      return LessonHomeworkScreen(
                        studentId: studentId,
                        studentName: studentName,
                        lessonId: lessonId,
                        assignedAt: assignedAt,
                        attentionOnly: attentionOnly,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: payments,
            builder: (context, state) => const PaymentsScreen(),
            routes: [
              GoRoute(
                path: ':studentId',
                builder: (context, state) {
                  final studentId = state.pathParameters['studentId'] ?? '';
                  return StudentPaymentDetailScreen(studentId: studentId);
                },
                routes: [
                  GoRoute(
                    path: 'report',
                    builder: (context, state) {
                      final studentId = state.pathParameters['studentId'] ?? '';
                      return GuardianPaymentReportScreen(studentId: studentId);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: settings,
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'parametreler',
                builder: (context, state) => const ParametersScreen(),
              ),
              GoRoute(
                path: 'yapilacaklar',
                builder: (context, state) => const TodosScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class MainNavigationShell extends ConsumerWidget {
  final Widget child;

  const MainNavigationShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertCount = ref.watch(homeworkAlertCountProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: const Offset(0, -4),
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return AppColors.primary.withValues(alpha: 0.15);
                }
                return Colors.transparent;
              }),
              elevation: 0,
              height: 68,
              indicatorColor: AppColors.primarySoft,
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(color: AppColors.primary, size: 24);
                }
                return const IconThemeData(color: AppColors.navUnselected, size: 24);
              }),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  );
                }
                return const TextStyle(
                  color: AppColors.navUnselected,
                  fontSize: 12,
                );
              }),
            ),
          ),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            indicatorColor: AppColors.primarySoft,
            elevation: 0,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: _calculateSelectedIndex(context),
            onDestinationSelected: (index) => _onItemTapped(index, context),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Ana Sayfa',
              ),
              const NavigationDestination(
                icon: Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(Icons.calendar_today),
                label: 'Takvim',
              ),
              const NavigationDestination(
                icon: Icon(Icons.book_outlined),
                selectedIcon: Icon(Icons.book),
                label: 'Dersler',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: alertCount > 0,
                  label: Text('$alertCount'),
                  child: const Icon(Icons.assignment_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: alertCount > 0,
                  label: Text('$alertCount'),
                  child: const Icon(Icons.assignment),
                ),
                label: 'Ödevler',
              ),
              const NavigationDestination(
                icon: Icon(Icons.payment_outlined),
                selectedIcon: Icon(Icons.payment),
                label: 'Ödemeler',
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location == AppRouter.home || location.startsWith('${AppRouter.home}/')) {
      return 0;
    }
    if (location.startsWith(AppRouter.schedule)) return 1;
    if (location.startsWith(AppRouter.lessons)) return 2;
    if (location.startsWith(AppRouter.homeworks)) return 3;
    if (location.startsWith(AppRouter.payments)) return 4;
    // Öğrenciler / ayarlar ana sayfa üzerinden açılır
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRouter.home);
        break;
      case 1:
        context.go(AppRouter.schedule);
        break;
      case 2:
        context.go(AppRouter.lessons);
        break;
      case 3:
        context.go(AppRouter.homeworks);
        break;
      case 4:
        context.go(AppRouter.payments);
        break;
    }
  }
}
