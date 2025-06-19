import 'package:flutter/material.dart';
import 'package:oee_mobile/l10n/app_localizations.dart';
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
  bool _isLoading = true;
  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _portController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadServerInfo();
  }

  Future<void> _loadServerInfo() async {
    if (!mounted) return;

    try {
      final serverInfo = await PersistenceService().readServerInfo();

      if (!mounted) return; // Check again after async operation

      if (serverInfo.length >= 2) {
        setState(() {
          _serverName = serverInfo[0];
          _serverPort = serverInfo[1];
          _nameController.text = _serverName;
          _portController.text = _serverPort;
          _isLoading = false;
        });
      } else {
        // Handle unexpected data format
        setState(() {
          _nameController.text = _serverName; // Use defaults
          _portController.text = _serverPort;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _nameController.text = _serverName; // Use defaults on error
        _portController.text = _serverPort;
        _isLoading = false;
      });

      // Show error to user
      final localizations = AppLocalizations.of(context);
      if (localizations != null) {
        UIUtils.showErrorDialog(context, 'Failed to load settings: $error');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _portController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final localizations = AppLocalizations.of(context);

    if (value == null || value.trim().isEmpty) {
      return localizations?.errNoServerName ?? 'Server name is required';
    }

    // Additional validation for server name format
    if (value.trim().length < 3) {
      return 'Server name must be at least 3 characters';
    }

    return null;
  }

  String? _validatePort(String? value) {
    final localizations = AppLocalizations.of(context);

    if (value == null || value.trim().isEmpty) {
      return localizations?.errNoServerPort ?? 'Port is required';
    }

    // Validate port number range
    final port = int.tryParse(value.trim());
    if (port == null) {
      return 'Port must be a valid number';
    }

    if (port < 1 || port > 65535) {
      return 'Port must be between 1 and 65535';
    }

    return null;
  }

  Future<void> _onSave() async {
    if (!mounted) return;

    // Validate form first
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final newServerName = _nameController.text.trim();
      final newServerPort = _portController.text.trim();

      await PersistenceService().saveServerInfo(newServerName, newServerPort);

      if (!mounted) return;

      setState(() {
        _serverName = newServerName;
        _serverPort = newServerPort;
        _isSaving = false;
      });

      final localizations = AppLocalizations.of(context);
      if (localizations != null) {
        UIUtils.showSnackBar(context, localizations.homeSettingsSaved);
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      final localizations = AppLocalizations.of(context);
      UIUtils.showErrorDialog(
          context,
          localizations?.homeSettingsSaved != null
              ? 'Failed to save settings: $error'
              : 'Failed to save settings: $error');
    }
  }

  void _onClose() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    if (_isLoading) {
      return const SizedBox(
        height: 250,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 5, left: 15, right: 15),
      height: 250,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              enabled: !_isSaving,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                filled: true,
                icon: const Icon(Icons.computer),
                hintText: localizations?.homeServerHint ?? 'Enter server name',
                labelText: localizations?.homeServerLabel ?? 'Server Name',
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              validator: _validateName,
            ),
            // port
            TextFormField(
              controller: _portController,
              enabled: !_isSaving,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                filled: true,
                icon: const Icon(Icons.settings_ethernet),
                hintText: localizations?.homePortHint ?? 'Enter port number',
                labelText: localizations?.homePortLabel ?? 'Port',
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              validator: _validatePort,
              onFieldSubmitted: (_) => _onSave(),
            ),
            OverflowBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _onSave,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(localizations?.homeSave ?? 'Save'),
                ),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _onClose,
                  icon: const Icon(Icons.close),
                  label: Text(localizations?.buttonClose ?? 'Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
