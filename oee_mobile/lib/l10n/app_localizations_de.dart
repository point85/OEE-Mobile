// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Point85 OEE Anwendung';

  @override
  String get appVersion => '2.1.0';

  @override
  String get homePageTitle => 'Point85 OEE';

  @override
  String get homeAboutText =>
      'Die Point85 Gesamtanlageneffektivität (OEE) Anwendungen ermöglichen die Sammlung von Anlagendaten aus mehreren Quellen zur Unterstützung von OEE-Berechnungen für Leistung, Verfügbarkeit und Qualität.\n\nFür weitere Informationen besuchen Sie bitte https://github.com/Point85/OEE-Designer.';

  @override
  String get homeSettings => 'Einstellungen';

  @override
  String get homeRefresh => 'Aktualisieren';

  @override
  String get homeAbout => 'Über';

  @override
  String get homeSave => 'Speichern';

  @override
  String get homeEquipStatus => 'Anlagenstatus wird angefordert ...';

  @override
  String get homeSettingsSaved => 'Einstellungen gespeichert.';

  @override
  String get homeServerHint => 'HTTP-Servername oder IP-Adresse';

  @override
  String get homeServerLabel => 'Server *';

  @override
  String get homePortHint => 'HTTP-Server Port';

  @override
  String get homePortLabel => 'Port *';

  @override
  String equipment(Object name) {
    return 'Anlage : $name';
  }

  @override
  String get equip => 'Anlage';

  @override
  String get equipAvailStart => 'Verfügbarkeitsereignis wird aufgezeichnet ...';

  @override
  String get equipAvailDone => 'Verfügbarkeitsereignis aufgezeichnet.';

  @override
  String get equipProdStart => 'Produktionsereignis wird aufgezeichnet ...';

  @override
  String get equipProdDone => 'Produktionsereignis aufgezeichnet.';

  @override
  String get equipSetupStart => 'Rüstereignis wird aufgezeichnet ...';

  @override
  String get equipSetupDone => 'Rüstereignis aufgezeichnet.';

  @override
  String get equipTabAvail => 'Verfügbarkeit';

  @override
  String get equipTabProd => 'Produktion';

  @override
  String get equipTabSetup => 'Rüsten/Auftrag';

  @override
  String get equipNoReason => 'Grund wählen';

  @override
  String get equipNoMaterial => 'Material wählen';

  @override
  String get equipReason => 'Grund';

  @override
  String get equipMaterial => 'Material';

  @override
  String get equipTimePeriod => 'Nach Zeitraum';

  @override
  String get equipEvent => 'Nach Ereignis';

  @override
  String get equipStart => 'Startzeit';

  @override
  String get equipEnd => 'Endzeit';

  @override
  String get equipDuration => 'Dauer';

  @override
  String get equipHrs => 'Stunden';

  @override
  String get equipMins => 'Minuten';

  @override
  String get equipSubmit => 'Senden';

  @override
  String get equipGood => 'Gut';

  @override
  String get equipReject => 'Ausschuss/Nacharbeit';

  @override
  String get equipStartup => 'Anlauf';

  @override
  String get equipAmountHint => 'Menge eingeben';

  @override
  String get equipAmountLabel => 'Menge *';

  @override
  String get equipJobHint => 'Auftrags-ID';

  @override
  String get equipJobLabel => 'Auftrag';

  @override
  String get equipMaterialLabel => 'Material';

  @override
  String get equipMatlDescLabel => 'Beschreibung';

  @override
  String get equipReasonLabel => 'Aktueller Grund';

  @override
  String get equipLossLabel => 'Verlustkategorie';

  @override
  String get equipRunLabel => 'Laufrate Einheit';

  @override
  String get equipRejectLabel => 'Ausschuss Einheit';

  @override
  String get equipStatus => 'Anlagenstatus';

  @override
  String get buttonClose => 'Schließen';

  @override
  String get errorTitle => 'OEE Anwendungsfehler';

  @override
  String get infoTitle => 'OEE Anwendungsinformation';

  @override
  String get reasonTitle => 'OEE Gründe';

  @override
  String get materialTitle => 'OEE Materialien';

  @override
  String get refreshedEntities => 'Entitäten aktualisiert';

  @override
  String get refreshedMaterials => 'Materialien aktualisiert';

  @override
  String get refreshedReasons => 'Gründe aktualisiert';

  @override
  String get retry => 'Wiederholen';

  @override
  String get loading => 'Wird geladen ...';

  @override
  String get none => 'Keine';

  @override
  String get na => 'N/V';

  @override
  String get lossMinorStoppages => 'Kleinere Stillstände';

  @override
  String get lossNoLoss => 'Läuft normal';

  @override
  String get lossNotScheduled => 'Derzeit nicht geplant';

  @override
  String get lossPlannedDowntime => 'Geplante Stillstandszeit';

  @override
  String get lossReducedSpeed => 'Läuft mit reduzierter Geschwindigkeit';

  @override
  String get lossRejectRework => 'Ausschussmaterial';

  @override
  String get lossSetup => 'Maschinenrüstung';

  @override
  String get lossStartupYield => 'Maschinenanlauf-Ausbeute';

  @override
  String get lossUnplannedDowntime => 'Ungeplante Stillstandszeit';

  @override
  String get lossUnscheduled => 'Ungeplant';

  @override
  String errNoLocalizations(Object message) {
    return '$message';
  }

  @override
  String get errNoHttpServer =>
      'Der HTTP-Servername und Port müssen in den Einstellungen definiert werden.';

  @override
  String get errNoServerName => 'Servername ist erforderlich.';

  @override
  String get errNoServerPort => 'Server-Port ist erforderlich.';

  @override
  String errInvalidDate(Object date) {
    return 'Das Datum $date ist nicht gültig.';
  }

  @override
  String get errMaterialTimeOut =>
      'Zeitüberschreitung beim Abrufen der Materialien.';

  @override
  String get errMustSelectEvent =>
      'Der Produktionsereignistyp muss ausgewählt werden.';

  @override
  String errNoSetup(Object name) {
    return 'Für Anlage $name wurde keine Rüstung durchgeführt.';
  }

  @override
  String errInvalidAmount(Object amount) {
    return 'Die Menge $amount muss größer als null sein.';
  }

  @override
  String errInvalidDuration(Object duration) {
    return 'Die Dauer $duration muss größer als null sein.';
  }

  @override
  String errLoadFailed(Object message, Object name) {
    return 'Fehler beim Laden der Anlage $name: $message.';
  }

  @override
  String errGetFailed(Object message, Object name) {
    return 'Fehler beim Abrufen der Anlage $name: $message.';
  }

  @override
  String errStatusGetFailed(Object message, Object name) {
    return 'Fehler beim Abrufen des Status für Anlage $name: $message.';
  }

  @override
  String get errNoEquipmentName => 'Anlagenname darf nicht leer sein.';

  @override
  String get errNoEntities => 'Keine Entitäten gefunden.';

  @override
  String get errConnection =>
      'Zum Aktualisieren ziehen oder Verbindung prüfen.';

  @override
  String get errFailedLoadingEntities => 'Fehler beim Laden der Entitäten';

  @override
  String get errFailedLoadingMaterials => 'Fehler beim Laden der Materialien';

  @override
  String get errFailedLoadingReasons => 'Fehler beim Laden der Gründe';

  @override
  String errFailedLoadingSettings(Object message) {
    return 'Fehler beim Laden der Einstellungen $message';
  }
}
