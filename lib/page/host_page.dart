import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hosts/model/host_file.dart';
import 'package:hosts/util/regexp_util.dart';

class HostPage extends StatefulWidget {
  final HostsModel? hostModel;

  const HostPage({super.key, this.hostModel});

  @override
  State<HostPage> createState() => _HostPageState();
}

class _HostPageState extends State<HostPage> {
  final GlobalKey _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();
  bool _isUse = false;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _hostController = TextEditingController();
  final List<TextEditingController> _hostControllers = [];
  final TextEditingController _hostConfController = TextEditingController();
  int currentIndex = 0;
  List<HostsModel> hosts = [
    HostsModel("", false, "", [""], {})
  ];

  @override
  void initState() {
    super.initState();
    if (widget.hostModel != null) {
      hosts = [widget.hostModel!];
      setState(() {
        setForm(hosts.first);
      });
    } else {
      setForm(hosts.first);
    }
    updateHostModelString();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) return;

      final List<HostsModel> tempHosts =
          HostsFile.parseHosts(_hostConfController.text.split("\n"));
      setState(() {
        if (widget.hostModel == null) {
          hosts = tempHosts;
        } else {
          hosts = [tempHosts.first];
        }
        if (hosts.isNotEmpty && currentIndex >= hosts.length) {
          currentIndex = hosts.length - 1;
        }
      });
      if (tempHosts.isNotEmpty) {
        setState(() {
          setForm(hosts[currentIndex]);
        });
        return;
      }

      setState(() {
        hosts = [
          HostsModel("", false, "", [""], {})
        ];
        setForm(hosts.first);
        _isUse = false;
      });
    });
  }

  void setForm(HostsModel tempHost) {
    _isUse = tempHost.isUse;
    _descriptionController.value = TextEditingValue(text: tempHost.description);
    _hostController.value = TextEditingValue(text: tempHost.host);
    _hostControllers.clear();
    _hostControllers.addAll(
        tempHost.hosts.map((host) => TextEditingController(text: host)));
  }

  @override
  void dispose() {
    for (var controller in _hostControllers) {
      controller.dispose();
    }
    _hostConfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hostModel != null
            ? "${AppLocalizations.of(context)!.edit} - ${_hostController.text}"
            : "${AppLocalizations.of(context)!.create}(${currentIndex + 1}/${hosts.isEmpty ? 1 : hosts.length})"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!((_formKey.currentState as FormState?)?.validate() ?? false)) {
            return;
          }

          Navigator.of(context).pop(hosts);
        },
        child: const Icon(Icons.save),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              height: size.height,
              child: buildForm(context),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: VerticalDivider(),
            ),
            Expanded(
                child: TextFormField(
              focusNode: _focusNode,
              controller: _hostConfController,
              maxLines: 10000,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: AppLocalizations.of(context)!.create_host_template,
              ),
            ))
          ],
        ),
      ),
    );
  }

  Form buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.info,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (widget.hostModel == null)
                    Row(
                      children: [
                        IconButton(
                          onPressed: currentIndex == 0
                              ? null
                              : () {
                                  setState(() {
                                    currentIndex--;
                                    setForm(hosts[currentIndex]);
                                  });
                                },
                          icon: const Icon(Icons.chevron_left),
                          tooltip: AppLocalizations.of(context)!.prev,
                        ),
                        IconButton(
                          onPressed:
                              currentIndex == hosts.length - 1 || hosts.isEmpty
                                  ? null
                                  : () {
                                      setState(() {
                                        currentIndex++;
                                        setForm(hosts[currentIndex]);
                                      });
                                    },
                          icon: const Icon(Icons.chevron_right),
                          tooltip: AppLocalizations.of(context)!.next,
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: hosts.length == 1
                              ? null
                              : () {
                                  setState(() {
                                    if (currentIndex > 0) {
                                      currentIndex--;
                                    }
                                    hosts.removeAt(currentIndex);
                                    setForm(hosts[currentIndex]);
                                    updateHostModelString();
                                  });
                                },
                          icon: const Icon(Icons.remove),
                          tooltip: AppLocalizations.of(context)!.remove,
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              hosts.add(HostsModel("", false, "", [""], {}));
                              currentIndex++;
                              setForm(hosts[currentIndex]);
                              updateHostModelString();
                            });
                          },
                          icon: const Icon(Icons.add),
                          tooltip: AppLocalizations.of(context)!.add,
                        ),
                      ],
                    )
                ],
              ),
              Switch(
                value: _isUse,
                onChanged: (value) => setState(() {
                  _isUse = value;
                  updateHostModelString();
                }),
              )
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(),
          ),
          TextFormField(
            controller: _descriptionController,
            onChanged: (value) {
              updateHostModelString();
              (_formKey.currentState as FormState?)?.validate();
            },
            decoration: InputDecoration(
              label: Text(AppLocalizations.of(context)!.remark),
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16))),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _hostController,
            decoration: InputDecoration(
                label: Text(AppLocalizations.of(context)!.ip_address),
                hintText: AppLocalizations.of(context)!.input_ip_address_hint,
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)))),
            onChanged: (value) {
              updateHostModelString();
              (_formKey.currentState as FormState?)?.validate();
            },
            validator: (value) {
              final text = value ?? "";
              if (text.isEmpty) {
                return AppLocalizations.of(context)!.input_ip_address;
              }

              if (!(isValidIPv4(text, true) || isValidIPv6(text, true))) {
                return AppLocalizations.of(context)!.input_ipv4_ipv6;
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          Expanded(child: buildDomains()),
        ],
      ),
    );
  }

  ListView buildDomains() {
    return ListView.builder(
        itemCount: _hostControllers.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextFormField(
              controller: _hostControllers[index],
              decoration: InputDecoration(
                label: Text(AppLocalizations.of(context)!.domain),
                prefixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_hostControllers.length > 1) {
                        _hostControllers.removeAt(index);
                      } else {
                        _hostControllers.first.text = "";
                      }
                    });
                    updateHostModelString();
                    (_formKey.currentState as FormState?)?.validate();
                  },
                  child: const Icon(Icons.remove),
                ),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (index == _hostControllers.length - 1) {
                        _hostControllers.add(TextEditingController());
                      } else {
                        _hostControllers.insert(
                          index + 1,
                          TextEditingController(),
                        );
                      }
                    });
                    updateHostModelString();
                  },
                  child: const Icon(Icons.add),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              onChanged: (value) {
                updateHostModelString();
                (_formKey.currentState as FormState?)?.validate();
              },
              validator: (value) {
                final text = value ?? "";
                if (text.isEmpty) {
                  return AppLocalizations.of(context)!.input_domain;
                }

                final regExp = RegExp(r' |\\n');
                if (regExp.hasMatch(text)) {
                  return AppLocalizations.of(context)!.error_domain_tip;
                }

                final int length =
                    _hostControllers.where((it) => it.text == text).length;
                if (length > 1) {
                  return AppLocalizations.of(context)!.error_exist_domain_tip;
                }

                return null;
              },
            ),
          );
        });
  }

  void updateHostModelString() {
    hosts[currentIndex] = HostsModel(
      _hostController.text,
      _isUse,
      _descriptionController.text,
      _hostControllers.map((text) => text.text).toList(),
      {}
    );
    if (hosts.length == 1) {
      _hostConfController.value = TextEditingValue(
        text: hosts[currentIndex].toString(),
      );
      return;
    }

    _hostConfController.value = TextEditingValue(
      text: hosts.join("\n\n"),
    );
  }
}
