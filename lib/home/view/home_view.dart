import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hosts/enums.dart';
import 'package:hosts/home/cubit/home_cubit.dart';
import 'package:hosts/home/cubit/host_cubit.dart';
import 'package:hosts/home/view/home_app_bar.dart';
import 'package:hosts/home/view/home_drawer.dart';
import 'package:hosts/home/view/host_page.dart';
import 'package:hosts/home/view/host_view.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:hosts/model/host_file.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // 初始化时加载 hostFiles
    context.read<HomeCubit>().loadHostFiles(context, true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      drawer:
          MediaQuery.of(context).size.width < 600 ? const HomeDrawer() : null,
      onDrawerChanged: (value) {
        if (!value) {
          context.read<HomeCubit>().toggleAdvancedSettingsSwitch();
        }
      },
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
            if (state is HomeSelectHostFileChanged || state is HomeDelete) {
              context.read<HostCubit>().updateHost(state.data.selectHostFile);
            }

            if (state is HomeEditMode) {
              context.read<HostCubit>().updateEditMode(state.data.editMode);
            }

            if (state is HomeAdvancedSettings) {
              if (state.data.advancedSettingsEnum == AdvancedSettingsEnum.Open) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scaffoldKey.currentState?.openDrawer();
                });
              }
            }

            return Row(
              children: [
                if (state.data.advancedSettingsEnum ==
                        AdvancedSettingsEnum.Close &&
                    MediaQuery.of(context).size.width > 600)
                  const HomeDrawer(),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeAppBar(),
                    saveTipMessage(state.data),
                    HostView(state.data)
                  ],
                ))
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
