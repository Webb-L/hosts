import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hosts/model/host_file.dart';

Future<void> testDialog(BuildContext context, HostsModel host) {
  for (var value in host.hosts) {
    _getRemoteIpAddress(value);
  }
  return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text("测试"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: host.hosts.map((domain) {
                return FutureBuilder<String>(
                  future: _getRemoteIpAddress(domain),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    Widget leadingIcon;
                    String? subtitle;

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      leadingIcon = const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                      subtitle = null;
                    } else if (snapshot.hasError) {
                      leadingIcon = const Icon(Icons.error);
                      subtitle = snapshot.error
                          ?.toString()
                          .replaceFirst("Exception:", "");
                    } else {
                      final ipAddress = snapshot.data;
                      leadingIcon = ipAddress == null
                          ? const Icon(Icons.error)
                          : (ipAddress == host.host
                              ? const Icon(Icons.check)
                              : const Icon(Icons.error));
                      subtitle = ipAddress == null
                          ? "未找到 IP 地址"
                          : (ipAddress == host.host
                              ? ipAddress
                              : "找到 IP 地址和设置 IP 地址并不一致");
                    }

                    return ListTile(
                      leading: leadingIcon,
                      title: Text(domain),
                      subtitle: subtitle != null ? Text(subtitle) : null,
                    );
                  },
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
          );
        });
      });
}

// TODO 兼容Web
Future<String> _getRemoteIpAddress(String domain) async {
  try {
    List<InternetAddress> addresses = await InternetAddress.lookup(domain);

    for (var address in addresses) {
      return address.address;
    }
    throw Exception('');
  } catch (e) {
    throw Exception("未找到 IP 地址");
  }
}
