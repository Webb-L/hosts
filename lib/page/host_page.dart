import 'package:flutter/material.dart';
import 'package:hosts/model/host_file.dart';
import 'package:hosts/util/regexp_util.dart';

// TODO 应该支持批量添加
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
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<TextEditingController> _hostControllers = [];
  final TextEditingController _hostConfController = TextEditingController();
  int currentIndex = 0;
  List<HostsModel> hosts = [HostsModel("", false, "", [])];

  @override
  void initState() {
    super.initState();
    if (widget.hostModel != null) {
      setState(() {
        setForm(widget.hostModel!);
      });
    }
    updateHostModelString();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) return;

      final List<HostsModel> tempHosts =
          HostsFile.parseHosts(_hostConfController.text.split("\n"));
      setState(() {
        hosts = tempHosts;
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
        _isUse = false;
      });

      _hostController.value = const TextEditingValue();
      _descriptionController.value = const TextEditingValue();
      _hostControllers.clear();
    });
  }

  void setForm(HostsModel tempHost) {
    _isUse = tempHost.isUse;
    _hostController.value = TextEditingValue(text: tempHost.host);
    _descriptionController.value = TextEditingValue(text: tempHost.description);
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
            ? "编辑 - ${_hostController.text}"
            : "新增(${currentIndex + 1}/${hosts.isEmpty ? 1 : hosts.length})"),
        actions: [
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
            tooltip: "上一个",
          ),
          IconButton(
            onPressed: currentIndex == hosts.length - 1 || hosts.isEmpty
                ? null
                : () {
                    setState(() {
                      currentIndex++;
                      setForm(hosts[currentIndex]);
                    });
                  },
            icon: const Icon(Icons.chevron_right),
            tooltip: "下一个",
          ),
          IconButton(
            onPressed: () {
              setState(() {
                hosts.add(HostsModel("", false, "", []));
                updateHostModelString();
              });
            },
            icon: const Icon(Icons.add),
            tooltip: "新增",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!((_formKey.currentState as FormState?)?.validate() ?? false)) {
            return;
          }

          Navigator.of(context).pop(HostsModel(
            _hostController.text,
            _isUse,
            _descriptionController.text,
            _hostControllers.map((text) => text.text).toList(),
          ));
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
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText:
                      "模板：\n# 127.0.0.1 flutter.dev\n\n# Flutter\n127.0.0.1 flutter.dev\n\n..."),
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
              Text(
                "信息",
                style: Theme.of(context).textTheme.titleLarge,
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
            controller: _hostController,
            decoration: const InputDecoration(
                label: Text("IP地址"),
                hintText: "支持IPV4和IPV6",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)))),
            onChanged: (value) {
              updateHostModelString();
              (_formKey.currentState as FormState?)?.validate();
            },
            validator: (value) {
              final text = value ?? "";
              if (text.isEmpty) return "请输入IP地址";

              if (!(isValidIPv4(text, true) || isValidIPv6(text, true))) {
                return "请输入IPV4或IPV6地址";
              }

              return null;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
              controller: _descriptionController,
              onChanged: (value) {
                updateHostModelString();
                (_formKey.currentState as FormState?)?.validate();
              },
              decoration: const InputDecoration(
                  label: Text("备注"),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16))))),
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
                label: const Text("域名"),
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
                if (text.isEmpty) return "请输入域名";

                final regExp = RegExp(r' |\\n');
                if (regExp.hasMatch(text)) {
                  return "请不要输入空格(“ ”)和换行(“\n”)。";
                }

                if (_hostControllers.where((it) => it.text == text).length >
                    1) {
                  return "该域名已存在";
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
