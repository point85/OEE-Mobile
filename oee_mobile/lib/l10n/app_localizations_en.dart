// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Point85 OEE Application';

  @override
  String get appVersion => '2.1.0';

  @override
  String get homePageTitle => 'Point85 OEE';

  @override
  String get homeAboutText =>
      'The Point85 Overall Equipment Effectiveness (OEE) applications enable collection of equipment data from multiple sources to support OEE calculations of performance, availability and quality.\n\nFor more information please visit https://github.com/Point85/OEE-Designer.';

  @override
  String get homeSettings => 'Settings';

  @override
  String get homeRefresh => 'Refresh';

  @override
  String get homeAbout => 'About';

  @override
  String get homeSave => 'Save';

  @override
  String get homeEquipStatus => 'Requesting equipment status ...';

  @override
  String get homeSettingsSaved => 'Settings saved.';

  @override
  String get homeServerHint => 'HTTP server name or IP address';

  @override
  String get homeServerLabel => 'Server *';

  @override
  String get homePortHint => 'HTTP server port';

  @override
  String get homePortLabel => 'Port *';

  @override
  String get equipAvailStart => 'Recording availability event ...';

  @override
  String get equipAvailDone => 'Availability event recorded.';

  @override
  String get equipProdStart => 'Recording production event ...';

  @override
  String get equipProdDone => 'Production event recorded.';

  @override
  String get equipSetupStart => 'Recording set up event ...';

  @override
  String get equipSetupDone => 'Set up event recorded.';

  @override
  String get equipTabAvail => 'Availability';

  @override
  String get equipTabProd => 'Production';

  @override
  String get equipTabSetup => 'Setup/Job';

  @override
  String get equipNoReason => 'Choose reason';

  @override
  String get equipNoMaterial => 'Choose material';

  @override
  String get equipReason => 'Reason';

  @override
  String get equipMaterial => 'Material';

  @override
  String get equipTimePeriod => 'By Time Period';

  @override
  String get equipEvent => 'By Event';

  @override
  String get equipStart => 'Start Time';

  @override
  String get equipEnd => 'End Time';

  @override
  String get equipDuration => 'Duration';

  @override
  String get equipHrs => 'Hours';

  @override
  String get equipMins => 'Minutes';

  @override
  String get equipSubmit => 'Submit';

  @override
  String get equipGood => 'Good';

  @override
  String get equipReject => 'Reject/Rework';

  @override
  String get equipStartup => 'Startup';

  @override
  String get equipAmountHint => 'Enter amount';

  @override
  String get equipAmountLabel => 'Amount *';

  @override
  String get equipJobHint => 'Job Id';

  @override
  String get equipJobLabel => 'Job';

  @override
  String get buttonClose => 'Close';

  @override
  String get errorTitle => 'OEE Application Error';

  @override
  String get infoTitle => 'OEE Application Information';

  @override
  String get reasonTitle => 'OEE Reasons';

  @override
  String get materialTitle => 'OEE Materials';

  @override
  String get refreshedEntities => 'Refreshed entities';

  @override
  String get refreshedMaterials => 'Refreshed materials';

  @override
  String get refreshedReasons => 'Refreshed reasons';

  @override
  String errNoLocalizations(Object message) {
    return '$message';
  }

  @override
  String get errNoHttpServer =>
      'The HTTP server name and port must be defined under Settings.';

  @override
  String get errNoServerName => 'Server name is required.';

  @override
  String get errNoServerPort => 'Server port is required.';

  @override
  String errInvalidDate(Object date) {
    return 'The date $date is not valid.';
  }

  @override
  String get errMaterialTimeOut => 'Fetching materials timed out.';

  @override
  String get errMustSelectEvent =>
      'The production event type must be selected.';

  @override
  String errNoSetup(Object name) {
    return 'No setup has been performed for equipment $name.';
  }

  @override
  String errInvalidAmount(Object amount) {
    return 'The amount $amount must be greater than zero.';
  }

  @override
  String errInvalidDuration(Object duration) {
    return 'The duration $duration must be greater than zero.';
  }

  @override
  String errLoadFailed(Object message, Object name) {
    return 'Failed to load equipment $name: $message.';
  }

  @override
  String errGetFailed(Object message, Object name) {
    return 'Failed to get equipment $name: $message.';
  }

  @override
  String errStatusGetFailed(Object message, Object name) {
    return 'Failed to get status for equipment $name: $message.';
  }

  @override
  String get errNoEquipmentName => 'Equipment name cannot be empty.';
}
