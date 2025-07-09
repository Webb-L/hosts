import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hosts/enums.dart';
import 'package:hosts/home/cubit/home_cubit.dart';
import 'package:hosts/home/cubit/host_cubit.dart';
import 'package:hosts/home/view/home_app_bar.dart';
import 'package:hosts/home/view/host_view.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:hosts/model/host_file.dart';
import 'package:hosts/page/host_page.dart';
import 'package:hosts/util/file_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class SimpleHomeView extends StatelessWidget {
  final String filePath;

  const SimpleHomeView({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && filePath.isNotEmpty && File(filePath).existsSync()) {
      context.read<HostCubit>().fromText(File(filePath).readAsStringSync());
    }

    return Scaffold(
      floatingActionButton: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.data.editMode == EditMode.Table) {
            return FloatingActionButton(
              onPressed: () async {
                List<HostsModel>? hostsModels = await Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => const HostPage()));
                if (hostsModels == null) return;
                context.read<HostCubit>().addHosts(hostsModels);
              },
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox();
        },
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeEditMode) {
            context.read<HostCubit>().updateEditMode(state.data.editMode);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeAppBar(),
              saveTipMessage(state.data),
              HostView(state.data)
            ],
          );
        },
      ),
    );
  }

  Widget saveTipMessage(HomeStateData data) {
    return BlocBuilder<HostCubit, HostState>(builder: (context, state) {
      final hostCubit = context.read<HostCubit>();
      if (state.data.isSave) {
        return const SizedBox();
      }

      return MaterialBanner(
        content: Text(AppLocalizations.of(context)!.error_not_update_save_tip),
        leading: const Icon(Icons.error_outline),
        actions: [
          TextButton(
            onPressed: () {
              saveHost(context, hostCubit.state.data.fileContent);
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      );
    });
  }

  Future<bool> saveHost(BuildContext context, String hostContent) async {
    final hostCubit = context.read<HostCubit>();

    if (kIsWeb) {
      final String tempContent = hostContent.replaceAll("\"", "\\\"");
      await showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
                title: const Text("保存"),
                content: SizedBox(
                  width: MediaQuery.of(dialogContext).size.width * 0.5,
                  child: SelectableText(hostContent),
                ),
                actions: [
                  TextButton(
                      onPressed: () => writeClipboard(
                            'echo "$tempContent" > /etc/hosts',
                            tempContent,
                            context,
                            hostCubit,
                          ),
                      child: const Text("Linux(echo)")),
                  TextButton(
                      onPressed: () {
                        final String systemHostPath = p.joinAll([
                          "C:",
                          "Windows",
                          "System32",
                          "drivers",
                          "etc",
                          "hosts"
                        ]);
                        final String content = hostContent
                            .split("\n")
                            .map((item) => 'echo $item')
                            .join("\n");
                        writeClipboard(
                          '(\n$content\n) > $systemHostPath',
                          hostContent,
                          context,
                          hostCubit,
                        );
                      },
                      child: const Text("Windows(echo)")),
                  TextButton(
                      onPressed: () => writeClipboard(
                            'echo "$tempContent" > /etc/hosts',
                            tempContent,
                            context,
                            hostCubit,
                          ),
                      child: const Text("MacOS(echo)")),
                ],
              ));
      return true;
    }

    final File file = File(filePath);
    try {
      await file.writeAsString(hostContent);
    } catch (e) {
      try {
        final Directory cacheDirectory = await getApplicationCacheDirectory();
        final File cacheFile = File(p.join(cacheDirectory.path, 'hosts'));
        await cacheFile.writeAsString(hostContent);

        await FileManager()
            .writeFileWithAdminPrivileges(cacheFile.path, filePath);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.error_save_fail)));
        return false;
      }
    }

    hostCubit.fromText(hostContent);
    return true;
  }

  void writeClipboard(String hostContent, String defaultContent,
      BuildContext context, HostCubit hostCubit) {
    Clipboard.setData(ClipboardData(text: hostContent)).then((_) {
      hostCubit.fromText(defaultContent);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.copy_to_tip),
        ),
      );
    });
  }
}
