import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hosts/enums.dart';
import 'package:hosts/home/cubit/home_cubit.dart';
import 'package:hosts/home/cubit/host_cubit.dart';
import 'package:hosts/home/view/home_app_bar.dart';
import 'package:hosts/home/view/host_view.dart';
import 'package:hosts/model/host_file.dart';
import 'package:hosts/page/host_page.dart';
import 'package:hosts/l10n/app_localizations.dart';

class SimpleHomeView extends StatelessWidget {
  const SimpleHomeView({super.key});

  @override
  Widget build(BuildContext context) {
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
          if(state is HomeEditMode) {
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

      final homeCubit = context.read<HomeCubit>();

      final String updateSaveTip =
          AppLocalizations.of(context)!.error_not_update_save_tip;
      final String updateSavePermissionTip = data.selectHostFile ==
          state.data.fileId
          ? '\n${AppLocalizations.of(context)!.error_not_update_save_permission_tip}'
          : '';
      return MaterialBanner(
        content: Text("$updateSaveTip$updateSavePermissionTip"),
        leading: const Icon(Icons.error_outline),
        actions: [
          TextButton(
            onPressed: () =>
                hostCubit.onTableSave(context, homeCubit.state.data, true),
            child: Text(AppLocalizations.of(context)!.save_create_history),
          ),
          TextButton(
            onPressed: () =>
                hostCubit.onTableSave(context, homeCubit.state.data, false),
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      );
    });
  }
}
