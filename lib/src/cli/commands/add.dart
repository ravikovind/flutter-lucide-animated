import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import '../fetcher.dart';
import '../generator.dart';

/// Command to add animated Lucide icons to the project
class AddCommand extends Command<void> {
  @override
  final name = 'add';

  @override
  final description = 'Add animated Lucide icons to your project';

  AddCommand() {
    argParser
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Output directory for generated files',
        defaultsTo: 'lib/lucide_animated/icons',
      )
      ..addFlag(
        'all',
        help: 'Add all available icons (warning: ~350 icons)',
        negatable: false,
      )
      ..addFlag(
        'force',
        abbr: 'f',
        help: 'Overwrite existing files without prompting',
        negatable: false,
      );
  }

  @override
  Future<void> run() async {
    final results = argResults!;
    final outputDir = results['output'] as String;
    final addAll = results['all'] as bool;
    final force = results['force'] as bool;
    final iconNames = results.rest;

    if (!addAll && iconNames.isEmpty) {
      _printError('Please specify icon names or use --all');
      return;
    }

    final fetcher = Fetcher();
    final generator = Generator();

    try {
      List<String> iconsToAdd;

      if (addAll) {
        stdout.writeln('Fetching registry...');
        final registry = await fetcher.fetchRegistry();
        iconsToAdd = registry.icons;
        stdout.writeln('Found ${registry.total} icons');

        // Warning for large number of icons
        stdout.write('This will add ${iconsToAdd.length} icons. Continue? [y/N] ');
        final response = stdin.readLineSync()?.toLowerCase();
        if (response != 'y' && response != 'yes') {
          stdout.writeln('Cancelled');
          return;
        }
      } else {
        iconsToAdd = iconNames;
      }

      // Create output directory
      final dir = Directory(outputDir);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
        stdout.writeln('Created directory: $outputDir');
      }

      // Fetch and generate each icon
      var successCount = 0;
      var errorCount = 0;
      final addedIcons = <String>[];

      for (final iconName in iconsToAdd) {
        try {
          stdout.write('Adding $iconName... ');

          // Check if file exists
          final fileName = '${iconName.replaceAll('-', '_')}.g.dart';
          final filePath = path.join(outputDir, fileName);
          final file = File(filePath);

          if (file.existsSync() && !force) {
            stdout.writeln('skipped (already exists, use --force to overwrite)');
            continue;
          }

          // Fetch icon data
          final iconData = await fetcher.fetchIcon(iconName);

          // Generate Dart code
          final code = generator.generateIcon(iconData);

          // Write file
          file.writeAsStringSync(code);
          addedIcons.add(iconName);

          stdout.writeln('done');
          successCount++;
        } catch (e) {
          stdout.writeln('failed ($e)');
          errorCount++;
        }
      }

      // Generate barrel export file (one level up from icons folder)
      if (addedIcons.isNotEmpty) {
        // Barrel file goes in parent directory of icons
        final parentDir = path.dirname(outputDir);
        final barrelPath = path.join(parentDir, 'lucide_animated.dart');
        final barrelFile = File(barrelPath);
        final existingIcons = <String>[];

        if (barrelFile.existsSync()) {
          final content = barrelFile.readAsStringSync();
          final exportRegex = RegExp(r"export 'icons/(.+)\.g\.dart';");
          for (final match in exportRegex.allMatches(content)) {
            existingIcons.add(match.group(1)!.replaceAll('_', '-'));
          }
        }

        // Combine and deduplicate
        final allIcons = {...existingIcons, ...addedIcons}.toList()..sort();
        final barrelCode = generator.generateBarrelExport(allIcons);
        barrelFile.writeAsStringSync(barrelCode);
      }

      // Summary
      stdout.writeln('');
      stdout.writeln('Added $successCount icon(s)');
      if (errorCount > 0) {
        stdout.writeln('Failed: $errorCount icon(s)');
      }

      if (addedIcons.isNotEmpty) {
        // Get parent directory for barrel file path
        final parentDir = path.dirname(outputDir);
        stdout.writeln('');
        stdout.writeln('Usage:');
        // Show appropriate import based on output path
        if (parentDir.startsWith('lib/')) {
          final importPath = parentDir.substring(4); // Remove 'lib/' prefix
          stdout.writeln("  import 'package:your_app/$importPath/lucide_animated.dart';");
        } else {
          stdout.writeln("  import '$parentDir/lucide_animated.dart';");
        }
        stdout.writeln('');
        stdout.writeln('  LucideAnimatedIcon(icon: ${addedIcons.first.replaceAll('-', '_')})');
      }
    } finally {
      fetcher.dispose();
    }
  }

  void _printError(String message) {
    stderr.writeln(message);
    stderr.writeln('');
    stderr.writeln(usage);
  }
}
