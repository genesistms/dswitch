/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import '../../channel.dart';
import '../../exceptions/exit.dart';
import '../../first_run.dart';

class InstallCommand extends Command<void> {
  InstallCommand(this.channel) {
    argParser.addFlag('select',
        abbr: 's',
        help: 'Displays a list of available releases that you can select from');
  }
  String channel;

  @override
  String get description => '''
Installs the given version for the $channel channel but does not switch to it.
If you don't provide a version then the latest version is installed.
If you pass the --select switch then a menu is displayed with the version available for download.''';

  @override
  String get name => 'install';

  @override
  void run() {
    checkIsFullyInstalled();
    if (argResults!.wasParsed('select')) {
      select();
    } else {
      if (argResults!.rest.isNotEmpty) {
        if (argResults!.rest.length != 1) {
          throw ExitException(
              1,
              'You may only pass a single version no. '
              'Found ${argResults!.rest}',
              showUsage: true,
              argParser: argParser);
        }

        final version = argResults!.rest[0];
        installVersion(version);
      } else {
        installLatestVersion(channel);
      }
    }
  }

  void installLatestVersion(String channel) {
    Channel(channel).installLatestVersion();
  }

  void select() {
    final ch = Channel(channel);

    final selected = ch.selectToInstall();

    if (ch.isVersionCached(selected.version.toString())) {
      print(blue('The selected version is already installed.'));
    } else {
      ch.download(selected.version.toString());
    }
    print('Install of $channel channel complete.');
  }

  void installVersion(String version) {
    print('Installing $channel version $version...');
    final ch = Channel(channel);
    if (ch.isVersionCached(version)) {
      throw ExitException(1, 'The selected version is already installed.',
          showUsage: false);
    }
    ch.download(version);
    print('Install of $channel channel complete. ');
  }
}
