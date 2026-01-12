import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import '../fetcher.dart';
import '../generator.dart';

/// Command to update installed animated Lucide icons
class UpdateCommand extends Command<void> {
  @override
  final name = 'update';

  @override
  final description =
      'Update installed animated Lucide icons to latest versions';

  UpdateCommand() {
    argParser.addOption(
      'output',
      abbr: 'o',
      help: 'Directory where icons are installed',
      defaultsTo: 'lib/lucide_animated/icons',
    );
  }

  @override
  Future<void> run() async {
    final results = argResults!;
    final outputDir = results['output'] as String;

    final dir = Directory(outputDir);

    if (!dir.existsSync()) {
      stderr.writeln('No icons installed in $outputDir');
      stderr.writeln('');
      stderr.writeln(
        'To add icons: dart run flutter_lucide_animated add <icon_name>',
      );
      return;
    }

    // Find all installed icons
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.g.dart'))
        .where((f) => !path.basename(f.path).startsWith('lucide_animated'))
        .toList();

    if (files.isEmpty) {
      stdout.writeln('No icons to update');
      return;
    }

    final iconNames = files.map((f) {
      final baseName = path.basenameWithoutExtension(f.path);
      return baseName.replaceAll('.g', '').replaceAll('_', '-');
    }).toList();

    stdout.writeln('Found ${iconNames.length} installed icon(s)');
    stdout.writeln('Updating...');
    stdout.writeln('');

    final fetcher = Fetcher();
    final generator = Generator();

    try {
      var successCount = 0;
      var errorCount = 0;

      for (final iconName in iconNames) {
        try {
          stdout.write('Updating $iconName... ');

          // Fetch latest icon data
          final iconData = await fetcher.fetchIcon(iconName);

          // Generate Dart code
          final code = generator.generateIcon(iconData);

          // Write file
          final fileName = '${iconName.replaceAll('-', '_')}.g.dart';
          final filePath = path.join(outputDir, fileName);
          File(filePath).writeAsStringSync(code);

          stdout.writeln('done');
          successCount++;
        } catch (e) {
          stdout.writeln('failed ($e)');
          errorCount++;
        }
      }

      // Summary
      stdout.writeln('');
      stdout.writeln('Updated $successCount icon(s)');
      if (errorCount > 0) {
        stdout.writeln('Failed: $errorCount icon(s)');
      }
    } finally {
      fetcher.dispose();
    }
  }
}
