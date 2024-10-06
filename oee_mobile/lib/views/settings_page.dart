import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:oee_mobile/services/http_service.dart';
import 'package:oee_mobile/views/common.dart';
import '../services/persistence_service.dart';

// widget for app settings
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _serverName = HttpService.defaultServer;
  String _serverPort = HttpService.defaultPort;

  final _nameController = TextEditingController();
  final _portController = TextEditingController();

  @override
  void initState() {
    super.initState();

    PersistenceService().readServerInfo().then((value) {
      if (value != null) {
        _nameController.text = value[0];
        _portController.text = value[1];
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _portController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value != null && value.isEmpty) {
      return AppLocalizations.of(context)!.noServerName;
    }
    return null;
  }

  String? _validatePort(String? value) {
    if (value != null && value.isEmpty) {
      return AppLocalizations.of(context)!.noServerPort;
    }
    return null;
  }

  onSave() {
    _serverName = _nameController.text;
    _serverPort = _portController.text;

    PersistenceService().saveServerInfo(_serverName, _serverPort);

    UIUtils.showSnackBar(
        context, AppLocalizations.of(context)!.homeSettingsSaved);
  }

  onClose() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 5, left: 15, right: 15),
        height: 250,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                filled: true,
                icon: const Icon(Icons.computer),
                hintText: AppLocalizations.of(context)!.homeServerHint,
                labelText: AppLocalizations.of(context)!.homeServerLabel,
              ),
              keyboardType: TextInputType.text,
              onSaved: (String? value) {
                _serverName = value!;
              },
              validator: _validateName,
            ),
            // port
            TextFormField(
              controller: _portController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                filled: true,
                icon: const Icon(Icons.panorama_fish_eye),
                hintText: AppLocalizations.of(context)!.homePortHint,
                labelText: AppLocalizations.of(context)!.homePortLabel,
              ),
              keyboardType: TextInputType.number,
              onSaved: (String? value) {
                _serverPort = value!;
              },
              validator: _validatePort,
            ),
            OverflowBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.save),
                  label: Text(AppLocalizations.of(context)!.homeSave),
                ),
                ElevatedButton.icon(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                  label: Text(AppLocalizations.of(context)!.buttonClose),
                ),
              ],
            ),
          ],
        ));
  }
}
