import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:flutter_lucide_animated/src/cli/commands/add.dart';
import 'package:flutter_lucide_animated/src/cli/commands/list.dart';
import 'package:flutter_lucide_animated/src/cli/commands/remove.dart';
import 'package:flutter_lucide_animated/src/cli/commands/update.dart';

void main(List<String> arguments) async {
  final runner =
      CommandRunner<void>(
          'flutter_lucide_animated',
          'CLI for managing animated Lucide icons in Flutter projects',
        )
        ..addCommand(AddCommand())
        ..addCommand(ListCommand())
        ..addCommand(RemoveCommand())
        ..addCommand(UpdateCommand());

  try {
    await runner.run(arguments);
  } on UsageException catch (e) {
    stderr.writeln(e.message);
    stderr.writeln('');
    stderr.writeln(runner.usage);
    exit(64);
  } catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  }
}
