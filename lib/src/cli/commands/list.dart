import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import '../fetcher.dart';

/// Command to list available or installed animated Lucide icons
class ListCommand extends Command<void> {
  @override
  final name = 'list';

  @override
  final description = 'List available or installed animated Lucide icons';

  ListCommand() {
    argParser
      ..addFlag(
        'installed',
        abbr: 'i',
        help: 'List only installed icons in current project',
        negatable: false,
      )
      ..addOption('search', abbr: 's', help: 'Search for icons by name')
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Directory to check for installed icons',
        defaultsTo: 'lib/lucide_animated/icons',
      );
  }

  @override
  Future<void> run() async {
    final results = argResults!;
    final showInstalled = results['installed'] as bool;
    final searchQuery = results['search'] as String?;
    final outputDir = results['output'] as String;

    if (showInstalled) {
      await _listInstalled(outputDir, searchQuery);
    } else {
      await _listAvailable(searchQuery);
    }
  }

  Future<void> _listAvailable(String? searchQuery) async {
    final fetcher = Fetcher();

    try {
      stdout.writeln('Fetching registry...');
      final registry = await fetcher.fetchRegistry();

      var icons = registry.icons;

      // Filter by search query
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        icons = icons
            .where((name) => name.toLowerCase().contains(query))
            .toList();
      }

      if (icons.isEmpty) {
        if (searchQuery != null) {
          stdout.writeln('No icons found matching "$searchQuery"');
        } else {
          stdout.writeln('No icons available');
        }
        return;
      }

      stdout.writeln('');
      stdout.writeln('Available icons (${icons.length}/${registry.total}):');
      stdout.writeln('');

      // Print in columns
      _printInColumns(icons);

      stdout.writeln('');
      stdout.writeln('Registry version: ${registry.version}');
      stdout.writeln('Last updated: ${registry.updatedAt.toIso8601String()}');
      stdout.writeln('');
      stdout.writeln(
        'To add icons: dart run flutter_lucide_animated add <icon_name>',
      );
    } finally {
      fetcher.dispose();
    }
  }

  Future<void> _listInstalled(String outputDir, String? searchQuery) async {
    final dir = Directory(outputDir);

    if (!dir.existsSync()) {
      stdout.writeln('No icons installed yet.');
      stdout.writeln('');
      stdout.writeln(
        'To add icons: dart run flutter_lucide_animated add <icon_name>',
      );
      return;
    }

    // Find all .g.dart files
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.g.dart'))
        .where((f) => !path.basename(f.path).startsWith('lucide_animated'))
        .toList();

    if (files.isEmpty) {
      stdout.writeln('No icons installed yet.');
      stdout.writeln('');
      stdout.writeln(
        'To add icons: dart run flutter_lucide_animated add <icon_name>',
      );
      return;
    }

    // Extract icon names from file names
    var icons = files.map((f) {
      final baseName = path.basenameWithoutExtension(f.path);
      return baseName.replaceAll('.g', '').replaceAll('_', '-');
    }).toList();

    // Filter by search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      icons = icons
          .where((name) => name.toLowerCase().contains(query))
          .toList();
    }

    if (icons.isEmpty) {
      if (searchQuery != null) {
        stdout.writeln('No installed icons found matching "$searchQuery"');
      } else {
        stdout.writeln('No icons installed');
      }
      return;
    }

    icons.sort();

    stdout.writeln('');
    stdout.writeln('Installed icons (${icons.length}):');
    stdout.writeln('');

    _printInColumns(icons);

    stdout.writeln('');
    stdout.writeln('Location: $outputDir');
  }

  void _printInColumns(List<String> items) {
    // Get terminal width (default to 80 if not available)
    final termWidth = stdout.hasTerminal ? stdout.terminalColumns : 80;
    final maxItemWidth =
        items.map((s) => s.length).reduce((a, b) => a > b ? a : b) + 2;
    final columns = (termWidth / maxItemWidth).floor().clamp(1, 6);

    for (var i = 0; i < items.length; i += columns) {
      final row = items.skip(i).take(columns);
      stdout.writeln(row.map((s) => s.padRight(maxItemWidth)).join(''));
    }
  }
}
