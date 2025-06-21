import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Point85 OEE Application'**
  String get appName;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'2.1.0'**
  String get appVersion;

  /// No description provided for @homePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Point85 OEE'**
  String get homePageTitle;

  /// No description provided for @homeAboutText.
  ///
  /// In en, this message translates to:
  /// **'The Point85 Overall Equipment Effectiveness (OEE) applications enable collection of equipment data from multiple sources to support OEE calculations of performance, availability and quality.\n\nFor more information please visit https://github.com/Point85/OEE-Designer.'**
  String get homeAboutText;

  /// No description provided for @homeSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettings;

  /// No description provided for @homeRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get homeRefresh;

  /// No description provided for @homeAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get homeAbout;

  /// No description provided for @homeSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get homeSave;

  /// No description provided for @homeEquipStatus.
  ///
  /// In en, this message translates to:
  /// **'Requesting equipment status ...'**
  String get homeEquipStatus;

  /// No description provided for @homeSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved.'**
  String get homeSettingsSaved;

  /// No description provided for @homeServerHint.
  ///
  /// In en, this message translates to:
  /// **'HTTP server name or IP address'**
  String get homeServerHint;

  /// No description provided for @homeServerLabel.
  ///
  /// In en, this message translates to:
  /// **'Server *'**
  String get homeServerLabel;

  /// No description provided for @homePortHint.
  ///
  /// In en, this message translates to:
  /// **'HTTP server port'**
  String get homePortHint;

  /// No description provided for @homePortLabel.
  ///
  /// In en, this message translates to:
  /// **'Port *'**
  String get homePortLabel;

  /// No description provided for @equipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment : {name}'**
  String equipment(Object name);

  /// No description provided for @equip.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equip;

  /// No description provided for @equipAvailStart.
  ///
  /// In en, this message translates to:
  /// **'Recording availability event ...'**
  String get equipAvailStart;

  /// No description provided for @equipAvailDone.
  ///
  /// In en, this message translates to:
  /// **'Availability event recorded.'**
  String get equipAvailDone;

  /// No description provided for @equipProdStart.
  ///
  /// In en, this message translates to:
  /// **'Recording production event ...'**
  String get equipProdStart;

  /// No description provided for @equipProdDone.
  ///
  /// In en, this message translates to:
  /// **'Production event recorded.'**
  String get equipProdDone;

  /// No description provided for @equipSetupStart.
  ///
  /// In en, this message translates to:
  /// **'Recording set up event ...'**
  String get equipSetupStart;

  /// No description provided for @equipSetupDone.
  ///
  /// In en, this message translates to:
  /// **'Set up event recorded.'**
  String get equipSetupDone;

  /// No description provided for @equipTabAvail.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get equipTabAvail;

  /// No description provided for @equipTabProd.
  ///
  /// In en, this message translates to:
  /// **'Production'**
  String get equipTabProd;

  /// No description provided for @equipTabSetup.
  ///
  /// In en, this message translates to:
  /// **'Setup/Job'**
  String get equipTabSetup;

  /// No description provided for @equipNoReason.
  ///
  /// In en, this message translates to:
  /// **'Choose reason'**
  String get equipNoReason;

  /// No description provided for @equipNoMaterial.
  ///
  /// In en, this message translates to:
  /// **'Choose material'**
  String get equipNoMaterial;

  /// No description provided for @equipReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get equipReason;

  /// No description provided for @equipMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get equipMaterial;

  /// No description provided for @equipTimePeriod.
  ///
  /// In en, this message translates to:
  /// **'By Time Period'**
  String get equipTimePeriod;

  /// No description provided for @equipEvent.
  ///
  /// In en, this message translates to:
  /// **'By Event'**
  String get equipEvent;

  /// No description provided for @equipStart.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get equipStart;

  /// No description provided for @equipEnd.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get equipEnd;

  /// No description provided for @equipDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get equipDuration;

  /// No description provided for @equipHrs.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get equipHrs;

  /// No description provided for @equipMins.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get equipMins;

  /// No description provided for @equipSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get equipSubmit;

  /// No description provided for @equipGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get equipGood;

  /// No description provided for @equipReject.
  ///
  /// In en, this message translates to:
  /// **'Reject/Rework'**
  String get equipReject;

  /// No description provided for @equipStartup.
  ///
  /// In en, this message translates to:
  /// **'Startup'**
  String get equipStartup;

  /// No description provided for @equipAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get equipAmountHint;

  /// No description provided for @equipAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount *'**
  String get equipAmountLabel;

  /// No description provided for @equipJobHint.
  ///
  /// In en, this message translates to:
  /// **'Job Id'**
  String get equipJobHint;

  /// No description provided for @equipJobLabel.
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get equipJobLabel;

  /// No description provided for @equipMaterialLabel.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get equipMaterialLabel;

  /// No description provided for @equipMatlDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get equipMatlDescLabel;

  /// No description provided for @equipReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Reason'**
  String get equipReasonLabel;

  /// No description provided for @equipLossLabel.
  ///
  /// In en, this message translates to:
  /// **'Loss Category'**
  String get equipLossLabel;

  /// No description provided for @equipRunLabel.
  ///
  /// In en, this message translates to:
  /// **'Run Rate UOM'**
  String get equipRunLabel;

  /// No description provided for @equipRejectLabel.
  ///
  /// In en, this message translates to:
  /// **'Reject UOM'**
  String get equipRejectLabel;

  /// No description provided for @equipStatus.
  ///
  /// In en, this message translates to:
  /// **'Equipment Status'**
  String get equipStatus;

  /// No description provided for @buttonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get buttonClose;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'OEE Application Error'**
  String get errorTitle;

  /// No description provided for @infoTitle.
  ///
  /// In en, this message translates to:
  /// **'OEE Application Information'**
  String get infoTitle;

  /// No description provided for @reasonTitle.
  ///
  /// In en, this message translates to:
  /// **'OEE Reasons'**
  String get reasonTitle;

  /// No description provided for @materialTitle.
  ///
  /// In en, this message translates to:
  /// **'OEE Materials'**
  String get materialTitle;

  /// No description provided for @refreshedEntities.
  ///
  /// In en, this message translates to:
  /// **'Refreshed entities'**
  String get refreshedEntities;

  /// No description provided for @refreshedMaterials.
  ///
  /// In en, this message translates to:
  /// **'Refreshed materials'**
  String get refreshedMaterials;

  /// No description provided for @refreshedReasons.
  ///
  /// In en, this message translates to:
  /// **'Refreshed reasons'**
  String get refreshedReasons;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading ...'**
  String get loading;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @na.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get na;

  /// No description provided for @lossMinorStoppages.
  ///
  /// In en, this message translates to:
  /// **'Minor Stoppage'**
  String get lossMinorStoppages;

  /// No description provided for @lossNoLoss.
  ///
  /// In en, this message translates to:
  /// **'Running Normally'**
  String get lossNoLoss;

  /// No description provided for @lossNotScheduled.
  ///
  /// In en, this message translates to:
  /// **'Not Currently Scheduled'**
  String get lossNotScheduled;

  /// No description provided for @lossPlannedDowntime.
  ///
  /// In en, this message translates to:
  /// **'Planned Downtime'**
  String get lossPlannedDowntime;

  /// No description provided for @lossReducedSpeed.
  ///
  /// In en, this message translates to:
  /// **'Running at Reduced Speed'**
  String get lossReducedSpeed;

  /// No description provided for @lossRejectRework.
  ///
  /// In en, this message translates to:
  /// **'Rejected Material'**
  String get lossRejectRework;

  /// No description provided for @lossSetup.
  ///
  /// In en, this message translates to:
  /// **'Machine Setup'**
  String get lossSetup;

  /// No description provided for @lossStartupYield.
  ///
  /// In en, this message translates to:
  /// **'Machine Startup Yield'**
  String get lossStartupYield;

  /// No description provided for @lossUnplannedDowntime.
  ///
  /// In en, this message translates to:
  /// **'Unplanned Downtime'**
  String get lossUnplannedDowntime;

  /// No description provided for @lossUnscheduled.
  ///
  /// In en, this message translates to:
  /// **'Unscheduled'**
  String get lossUnscheduled;

  /// No description provided for @errNoLocalizations.
  ///
  /// In en, this message translates to:
  /// **'{message}'**
  String errNoLocalizations(Object message);

  /// No description provided for @errNoHttpServer.
  ///
  /// In en, this message translates to:
  /// **'The HTTP server name and port must be defined under Settings.'**
  String get errNoHttpServer;

  /// No description provided for @errNoServerName.
  ///
  /// In en, this message translates to:
  /// **'Server name is required.'**
  String get errNoServerName;

  /// No description provided for @errNoServerPort.
  ///
  /// In en, this message translates to:
  /// **'Server port is required.'**
  String get errNoServerPort;

  /// No description provided for @errInvalidDate.
  ///
  /// In en, this message translates to:
  /// **'The date {date} is not valid.'**
  String errInvalidDate(Object date);

  /// No description provided for @errMaterialTimeOut.
  ///
  /// In en, this message translates to:
  /// **'Fetching materials timed out.'**
  String get errMaterialTimeOut;

  /// No description provided for @errMustSelectEvent.
  ///
  /// In en, this message translates to:
  /// **'The production event type must be selected.'**
  String get errMustSelectEvent;

  /// No description provided for @errNoSetup.
  ///
  /// In en, this message translates to:
  /// **'No setup has been performed for equipment {name}.'**
  String errNoSetup(Object name);

  /// No description provided for @errInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'The amount {amount} must be greater than zero.'**
  String errInvalidAmount(Object amount);

  /// No description provided for @errInvalidDuration.
  ///
  /// In en, this message translates to:
  /// **'The duration {duration} must be greater than zero.'**
  String errInvalidDuration(Object duration);

  /// No description provided for @errLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load equipment {name}: {message}.'**
  String errLoadFailed(Object message, Object name);

  /// No description provided for @errGetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to get equipment {name}: {message}.'**
  String errGetFailed(Object message, Object name);

  /// No description provided for @errStatusGetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to get status for equipment {name}: {message}.'**
  String errStatusGetFailed(Object message, Object name);

  /// No description provided for @errNoEquipmentName.
  ///
  /// In en, this message translates to:
  /// **'Equipment name cannot be empty.'**
  String get errNoEquipmentName;

  /// No description provided for @errNoEntities.
  ///
  /// In en, this message translates to:
  /// **'No entities found.'**
  String get errNoEntities;

  /// No description provided for @errConnection.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh or check your connection.'**
  String get errConnection;

  /// No description provided for @errFailedLoadingEntities.
  ///
  /// In en, this message translates to:
  /// **'Error loading entities'**
  String get errFailedLoadingEntities;

  /// No description provided for @errFailedLoadingMaterials.
  ///
  /// In en, this message translates to:
  /// **'Error loading materials'**
  String get errFailedLoadingMaterials;

  /// No description provided for @errFailedLoadingReasons.
  ///
  /// In en, this message translates to:
  /// **'Error loading reasons'**
  String get errFailedLoadingReasons;

  /// No description provided for @errFailedLoadingSettings.
  ///
  /// In en, this message translates to:
  /// **'Error loading settings {message}'**
  String errFailedLoadingSettings(Object message);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
