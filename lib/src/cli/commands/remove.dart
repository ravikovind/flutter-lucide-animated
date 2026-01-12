import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import '../generator.dart';

/// Command to remove animated Lucide icons from the project
class RemoveCommand extends Command<void> {
  @override
  final name = 'remove';

  @override
  final description = 'Remove animated Lucide icons from your project';

  RemoveCommand() {
    argParser
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Directory where icons are installed',
        defaultsTo: 'lib/lucide_animated/icons',
      )
      ..addFlag('all', help: 'Remove all installed icons', negatable: false);
  }

  @override
  Future<void> run() async {
    final results = argResults!;
    final outputDir = results['output'] as String;
    final removeAll = results['all'] as bool;
    final iconNames = results.rest;

    if (!removeAll && iconNames.isEmpty) {
      _printError('Please specify icon names or use --all');
      return;
    }

    final dir = Directory(outputDir);

    if (!dir.existsSync()) {
      stderr.writeln('No icons installed in $outputDir');
      return;
    }

    List<String> iconsToRemove;

    if (removeAll) {
      // Find all installed icons
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.g.dart'))
          .where((f) => !path.basename(f.path).startsWith('lucide_animated'))
          .toList();

      iconsToRemove = files.map((f) {
        final baseName = path.basenameWithoutExtension(f.path);
        return baseName.replaceAll('.g', '').replaceAll('_', '-');
      }).toList();

      if (iconsToRemove.isEmpty) {
        stdout.writeln('No icons to remove');
        return;
      }

      stdout.write(
        'This will remove ${iconsToRemove.length} icons. Continue? [y/N] ',
      );
      final response = stdin.readLineSync()?.toLowerCase();
      if (response != 'y' && response != 'yes') {
        stdout.writeln('Cancelled');
        return;
      }
    } else {
      iconsToRemove = iconNames;
    }

    // Remove each icon
    var successCount = 0;
    var errorCount = 0;
    final removedIcons = <String>[];

    for (final iconName in iconsToRemove) {
      try {
        stdout.write('Removing $iconName... ');

        final fileName = '${iconName.replaceAll('-', '_')}.g.dart';
        final filePath = path.join(outputDir, fileName);
        final file = File(filePath);

        if (!file.existsSync()) {
          stdout.writeln('not found');
          errorCount++;
          continue;
        }

        file.deleteSync();
        removedIcons.add(iconName);

        stdout.writeln('done');
        successCount++;
      } catch (e) {
        stdout.writeln('failed ($e)');
        errorCount++;
      }
    }

    // Update barrel export file
    final barrelPath = path.join(outputDir, 'lucide_animated.g.dart');
    final barrelFile = File(barrelPath);

    if (barrelFile.existsSync()) {
      // Get remaining icons
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.g.dart'))
          .where((f) => !path.basename(f.path).startsWith('lucide_animated'))
          .toList();

      if (files.isEmpty) {
        // No more icons, remove barrel file
        barrelFile.deleteSync();

        // Optionally remove directory if empty
        if (dir.listSync().isEmpty) {
          dir.deleteSync();
        }
      } else {
        // Update barrel file
        final remainingIcons = files.map((f) {
          final baseName = path.basenameWithoutExtension(f.path);
          return baseName.replaceAll('.g', '').replaceAll('_', '-');
        }).toList()..sort();

        final generator = Generator();
        final barrelCode = generator.generateBarrelExport(remainingIcons);
        barrelFile.writeAsStringSync(barrelCode);
      }
    }

    // Summary
    stdout.writeln('');
    stdout.writeln('Removed $successCount icon(s)');
    if (errorCount > 0) {
      stdout.writeln('Not found: $errorCount icon(s)');
    }
  }

  void _printError(String message) {
    stderr.writeln(message);
    stderr.writeln('');
    stderr.writeln(usage);
  }
}
