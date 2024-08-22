import 'package:flutter/material.dart';
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
  bool _isUse = false;
  String _host = "";
  String _description = "";
  final List<String> _hosts = [""];
  final List<TextEditingController> _hostControllers = [];
  final TextEditingController _hostConf = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.hostModel != null) {
      _isUse = widget.hostModel!.isUse;
      _host = widget.hostModel!.host;
      _description = widget.hostModel!.description;
      _hosts.clear();
      _hosts.addAll(widget.hostModel!.hosts);
    }
    _hostControllers
        .addAll(_hosts.map((host) => TextEditingController(text: host)));
    _hostConf.value = TextEditingValue(
        text: HostsModel(_host, _isUse, _description, _hosts).toString());
  }

  @override
  void dispose() {
    // 释放所有的 TextEditingController
    for (var controller in _hostControllers) {
      controller.dispose();
    }
    _hostConf.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.hostModel != null ? "编辑 - $_host" : "新增"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!((_formKey.currentState as FormState?)?.validate() ?? false)) {
            return;
          }

          Navigator.of(context)
              .pop(HostsModel(_host, _isUse, _description, _hosts));
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
              controller: _hostConf,
              maxLines: 1000,
              decoration: const InputDecoration(border: InputBorder.none),
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
                        _hostConf.value = TextEditingValue(
                            text:
                                HostsModel(_host, _isUse, _description, _hosts)
                                    .toString());
                      }))
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(),
          ),
          TextFormField(
            initialValue: _host,
            decoration: const InputDecoration(
                label: Text("IP地址"),
                hintText: "支持IPV4和IPV6",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)))),
            onChanged: (value) {
              setState(() {
                _host = value;
              });
              _hostConf.value = TextEditingValue(
                  text: HostsModel(_host, _isUse, _description, _hosts)
                      .toString());
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
              initialValue: _description,
              onChanged: (value) {
                setState(() {
                  _description = value;
                });
                _hostConf.value = TextEditingValue(
                    text: HostsModel(_host, _isUse, _description, _hosts)
                        .toString());
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
        itemCount: _hosts.length,
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
                      if (_hosts.length > 1) {
                        _hosts.removeAt(index);
                        _hostControllers.removeAt(index);
                      } else {
                        _hosts.first = "";
                        _hostControllers.first.text = "";
                      }
                    });
                  },
                  child: const Icon(Icons.remove),
                ),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (index == _hosts.length - 1) {
                        _hosts.add("");
                        _hostControllers.add(TextEditingController());
                      } else {
                        _hosts.insert(index + 1, "");
                        _hostControllers.insert(
                            index + 1, TextEditingController());
                      }
                    });
                  },
                  child: const Icon(Icons.add),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _hosts[index] = value;
                });
                _hostConf.value = TextEditingValue(
                    text: HostsModel(_host, _isUse, _description, _hosts)
                        .toString());
                (_formKey.currentState as FormState?)?.validate();
              },
              validator: (value) {
                final text = value ?? "";
                if (text.isEmpty) return "请输入域名";

                final regExp = RegExp(r' |\\n');
                if (regExp.hasMatch(text)) {
                  return "请不要输入空格(“ ”)和换行(“\n”)。";
                }

                if (_hosts.where((it) => it == text).length > 1) {
                  return "该域名已存在";
                }

                return null;
              },
            ),
          );
        });
  }
}
