import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hosts/enums.dart';
import 'package:hosts/home/cubit/home_cubit.dart';
import 'package:hosts/home/cubit/host_cubit.dart';
import 'package:hosts/home/view/home_app_bar.dart';
import 'package:hosts/home/view/host_page.dart';
import 'package:hosts/home/view/host_view.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:hosts/model/global_settings.dart';
import 'package:hosts/model/host_file.dart';

class SimpleHomeView extends StatelessWidget {
  const SimpleHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb &&
        GlobalSettings().filePath != null &&
        File(GlobalSettings().filePath!).existsSync()) {
      context
          .read<HostCubit>()
          .fromText(File(GlobalSettings().filePath!).readAsStringSync());
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
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
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
    final result = await hostCubit.saveHost(context, GlobalSettings().filePath??"", hostContent);
    if (result) {
      hostCubit.fromText(hostContent);
    }
    return result;
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
