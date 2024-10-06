import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// tree view support
class TreeUtils {
  const TreeUtils._(); // Private constructor to prevent instantiation

  static const Duration animationDuration = Duration(milliseconds: 200);
  static const EdgeInsets edgeInsets = EdgeInsets.symmetric(horizontal: 8);
  static const SizedBox parentPadding = SizedBox(width: 16);
  static const Icon folderIcon = Icon(Icons.folder);
  static const Icon chevronIcon = Icon(Icons.chevron_right);
  static const SizedBox rowPadding = SizedBox(width: 10);

  static BoxDecoration buildBoxDecoration(
      BuildContext context, bool isSelected) {
    return BoxDecoration(
      gradient: isSelected
          ? LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(.3),
                Theme.of(context).colorScheme.primary.withOpacity(.1),
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
        children: [
          Row(
            children: [
              Icon(iconData),
              rowPadding,
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              const SizedBox.shrink(),
              rowPadding,
              Text(
                subtitle,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// shared utilities
class UIUtils {
  static const Icon backIcon =
      Icon(Icons.chevron_left, size: 48, color: Colors.white);
  static const Color appBarBackground = Colors.blue;

  static ButtonStyle submitStyle = ElevatedButton.styleFrom(
    textStyle: const TextStyle(fontSize: 18),
    backgroundColor: Colors.lightGreen, // Background color
    foregroundColor: Colors.black, // Text color
  );

  static void showAlert(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.buttonClose),
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
    showAlert(context, AppLocalizations.of(context)!.errorTitle, content);
  }

  static void showInfoDialog(BuildContext context, String content) {
    showAlert(context, AppLocalizations.of(context)!.infoTitle, content);
  }

  static void showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: AppLocalizations.of(context)!.buttonClose,
        onPressed: () {
          // Perform some action (e.g., undo the change)
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ));
  }
}
