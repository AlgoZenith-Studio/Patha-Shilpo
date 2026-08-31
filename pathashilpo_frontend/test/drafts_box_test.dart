import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pathashilpa/data/local/drafts_box.dart';
import 'package:pathashilpa/data/local/hive_init.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pathashilpa_hive_test');
    Hive.init(tempDir.path);
    await Hive.openBox<Map<dynamic, dynamic>>(HiveBoxes.drafts);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('DraftsBox', () {
    const DraftsBox box = DraftsBox();

    test('put then get round-trips a draft', () async {
      await box.put('local-1', <String, dynamic>{
        'localId': 'local-1',
        'materialCost': 800,
        'hoursOfWork': 12,
        'tags': <String>['saree', 'handmade'],
        'updatedAtMs': 1000,
      });

      final Map<String, dynamic>? loaded = box.get('local-1');
      expect(loaded, isNotNull);
      expect(loaded!['materialCost'], 800);
      expect(loaded['hoursOfWork'], 12);
      expect(loaded['tags'], <String>['saree', 'handmade']);
    });

    test('get returns null for a draft that was never saved', () {
      expect(box.get('never-existed'), isNull);
    });

    test('delete removes a draft', () async {
      await box.put('local-2', <String, dynamic>{'updatedAtMs': 1});
      expect(box.get('local-2'), isNotNull);

      await box.delete('local-2');
      expect(box.get('local-2'), isNull);
    });

    test('all() returns every saved draft, most recently updated first', () async {
      await box.put('a', <String, dynamic>{'updatedAtMs': 100});
      await box.put('b', <String, dynamic>{'updatedAtMs': 300});
      await box.put('c', <String, dynamic>{'updatedAtMs': 200});

      final List<Map<String, dynamic>> all = box.all();
      expect(all.length, 3);
      expect(all.map((Map<String, dynamic> d) => d['updatedAtMs']).toList(),
          <int>[300, 200, 100]);
    });

    test('put twice with the same localId upserts, never duplicates', () async {
      // Mirrors TRD.md §9.2: localId is the idempotency key.
      await box.put('local-3', <String, dynamic>{'materialCost': 100});
      await box.put('local-3', <String, dynamic>{'materialCost': 200});

      expect(box.all().length, 1);
      expect(box.get('local-3')!['materialCost'], 200);
    });
  });
}
