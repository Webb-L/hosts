import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hosts/app.dart';
import 'package:hosts/host_observer.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const HostObserver();

  final Iterable<String> files = args.where((path) => File(path).existsSync());
  if (files.isNotEmpty) {
    runApp(HostsApp(files.first));
  } else {
    runApp(HostsApp(""));
  }
}
