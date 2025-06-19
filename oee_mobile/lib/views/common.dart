import 'package:flutter/material.dart';
import 'package:oee_mobile/l10n/app_localizations.dart';

// tree view support
class TreeUtils {
  const TreeUtils._(); // Private constructor to prevent instantiation

  static const Duration animationDuration = Duration(milliseconds: 200);
  static const EdgeInsets edgeInsets = EdgeInsets.symmetric(horizontal: 8);
  static const Widget parentPadding = SizedBox(width: 16);
  static const Icon folderIcon = Icon(Icons.folder);
  static const Icon chevronIcon = Icon(Icons.chevron_right);
  static const Widget rowPadding = SizedBox(width: 10);

  static BoxDecoration buildBoxDecoration(
      BuildContext context, bool isSelected) {
    return BoxDecoration(
      gradient: isSelected
          ? LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
      borderRadius: BorderRadius.circular(4),
    );
  }

  static Padding buildTreeRow(
      String name, String? description, IconData iconData) {
    final String subtitle = description ?? '';

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData),
              rowPadding,
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (subtitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 34), // Icon width + spacing
              child: Text(
                subtitle,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }
}

// shared utilities
class UIUtils {
  static Icon getBackIcon(BuildContext context) => Icon(
        Icons.chevron_left,
        size: 48,
        color: Theme.of(context).colorScheme.onPrimary,
      );

  static Color getAppBarBackground(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static ButtonStyle getSubmitStyle(BuildContext context) =>
      ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 18),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
      );

  static void showAlert(BuildContext context, String title, String content) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      // Fallback if localizations aren't available
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            ElevatedButton(
              child: Text(localizations.buttonClose),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static void showErrorDialog(BuildContext context, String content) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return;

    showAlert(context, localizations.errorTitle, content);
  }

  static void showInfoDialog(BuildContext context, String content) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return;

    showAlert(context, localizations.infoTitle, content);
  }

  static void showSnackBar(BuildContext context, String text) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: localizations.buttonClose,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ));
  }
}
