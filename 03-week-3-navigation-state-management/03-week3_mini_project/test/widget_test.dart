import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo_tugas/pages/todo_page.dart';

void main() {
  testWidgets(
    'menambah tugas baru menampilkan item di daftar',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TodoPage(),
          ),
        ),
      );

      expect(find.text('Belum ada tugas'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'Kerjakan PR minggu 3',
      );

      await tester.tap(find.text('Tambah'));
      await tester.pumpAndSettle();

      expect(
        find.text('Kerjakan PR minggu 3'),
        findsOneWidget,
      );

      expect(
        find.text('Belum ada tugas'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'checkbox toggle mengubah status tugas menjadi selesai',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TodoPage(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'Belajar Riverpod',
      );

      await tester.tap(find.text('Tambah'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      final checkbox = tester.widget<Checkbox>(
        find.byType(Checkbox),
      );

      expect(checkbox.value, isTrue);
    },
  );
}

