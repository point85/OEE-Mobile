// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Aplicación OEE Point85';

  @override
  String get appVersion => '2.1.0';

  @override
  String get homePageTitle => 'Point85 OEE';

  @override
  String get homeAboutText =>
      'Las aplicaciones de Eficiencia General de Equipos (OEE) de Point85 permiten la recopilación de datos de equipos de múltiples fuentes para apoyar los cálculos de OEE de rendimiento, disponibilidad y calidad.\n\nPara más información, visite https://github.com/Point85/OEE-Designer.';

  @override
  String get homeSettings => 'Configuraciones';

  @override
  String get homeRefresh => 'Actualizar';

  @override
  String get homeAbout => 'Acerca de';

  @override
  String get homeSave => 'Guardar';

  @override
  String get homeEquipStatus => 'Solicitando estado del equipo ...';

  @override
  String get homeSettingsSaved => 'Configuraciones guardadas.';

  @override
  String get homeServerHint => 'Nombre del servidor HTTP o dirección IP';

  @override
  String get homeServerLabel => 'Servidor *';

  @override
  String get homePortHint => 'Puerto del servidor HTTP';

  @override
  String get homePortLabel => 'Puerto *';

  @override
  String equipment(Object name) {
    return 'Equipo : $name';
  }

  @override
  String get equip => 'Equipo';

  @override
  String get equipAvailStart => 'Registrando evento de disponibilidad ...';

  @override
  String get equipAvailDone => 'Evento de disponibilidad registrado.';

  @override
  String get equipProdStart => 'Registrando evento de producción ...';

  @override
  String get equipProdDone => 'Evento de producción registrado.';

  @override
  String get equipSetupStart => 'Registrando evento de configuración ...';

  @override
  String get equipSetupDone => 'Evento de configuración registrado.';

  @override
  String get equipTabAvail => 'Disponibilidad';

  @override
  String get equipTabProd => 'Producción';

  @override
  String get equipTabSetup => 'Configuración/Trabajo';

  @override
  String get equipNoReason => 'Elegir razón';

  @override
  String get equipNoMaterial => 'Elegir material';

  @override
  String get equipReason => 'Razón';

  @override
  String get equipMaterial => 'Material';

  @override
  String get equipTimePeriod => 'Por Período de Tiempo';

  @override
  String get equipEvent => 'Por Evento';

  @override
  String get equipStart => 'Hora de Inicio';

  @override
  String get equipEnd => 'Hora de Finalización';

  @override
  String get equipDuration => 'Duración';

  @override
  String get equipHrs => 'Horas';

  @override
  String get equipMins => 'Minutos';

  @override
  String get equipSubmit => 'Enviar';

  @override
  String get equipGood => 'Bueno';

  @override
  String get equipReject => 'Rechazar/Retrabajar';

  @override
  String get equipStartup => 'Arranque';

  @override
  String get equipAmountHint => 'Ingrese cantidad';

  @override
  String get equipAmountLabel => 'Cantidad *';

  @override
  String get equipJobHint => 'ID del Trabajo';

  @override
  String get equipJobLabel => 'Trabajo';

  @override
  String get equipMaterialLabel => 'Material';

  @override
  String get equipMatlDescLabel => 'Descripción';

  @override
  String get equipReasonLabel => 'Razón Actual';

  @override
  String get equipLossLabel => 'Categoría de Pérdida';

  @override
  String get equipRunLabel => 'UOM Tasa de Funcionamiento';

  @override
  String get equipRejectLabel => 'UOM Rechazo';

  @override
  String get equipStatus => 'Estado del Equipo';

  @override
  String get buttonClose => 'Cerrar';

  @override
  String get errorTitle => 'Error de Aplicación OEE';

  @override
  String get infoTitle => 'Información de Aplicación OEE';

  @override
  String get reasonTitle => 'Razones OEE';

  @override
  String get materialTitle => 'Materiales OEE';

  @override
  String get refreshedEntities => 'Entidades actualizadas';

  @override
  String get refreshedMaterials => 'Materiales actualizados';

  @override
  String get refreshedReasons => 'Razones actualizadas';

  @override
  String get retry => 'Reintentar';

  @override
  String get loading => 'Cargando ...';

  @override
  String get none => 'Ninguno';

  @override
  String get na => 'N/A';

  @override
  String get lossMinorStoppages => 'Parada Menor';

  @override
  String get lossNoLoss => 'Funcionando Normalmente';

  @override
  String get lossNotScheduled => 'No Programado Actualmente';

  @override
  String get lossPlannedDowntime => 'Tiempo de Inactividad Planificado';

  @override
  String get lossReducedSpeed => 'Funcionando a Velocidad Reducida';

  @override
  String get lossRejectRework => 'Material Rechazado';

  @override
  String get lossSetup => 'Configuración de Máquina';

  @override
  String get lossStartupYield => 'Rendimiento de Arranque de Máquina';

  @override
  String get lossUnplannedDowntime => 'Tiempo de Inactividad No Planificado';

  @override
  String get lossUnscheduled => 'No Programado';

  @override
  String errNoLocalizations(Object message) {
    return '$message';
  }

  @override
  String get errNoHttpServer =>
      'El nombre del servidor HTTP y el puerto deben definirse en Configuraciones.';

  @override
  String get errNoServerName => 'El nombre del servidor es requerido.';

  @override
  String get errNoServerPort => 'El puerto del servidor es requerido.';

  @override
  String errInvalidDate(Object date) {
    return 'La fecha $date no es válida.';
  }

  @override
  String get errMaterialTimeOut => 'La obtención de materiales ha expirado.';

  @override
  String get errMustSelectEvent =>
      'El tipo de evento de producción debe ser seleccionado.';

  @override
  String errNoSetup(Object name) {
    return 'No se ha realizado configuración para el equipo $name.';
  }

  @override
  String errInvalidAmount(Object amount) {
    return 'La cantidad $amount debe ser mayor que cero.';
  }

  @override
  String errInvalidDuration(Object duration) {
    return 'La duración $duration debe ser mayor que cero.';
  }

  @override
  String errLoadFailed(Object message, Object name) {
    return 'Error al cargar equipo $name: $message.';
  }

  @override
  String errGetFailed(Object message, Object name) {
    return 'Error al obtener equipo $name: $message.';
  }

  @override
  String errStatusGetFailed(Object message, Object name) {
    return 'Error al obtener estado del equipo $name: $message.';
  }

  @override
  String get errNoEquipmentName => 'El nombre del equipo no puede estar vacío.';

  @override
  String get errNoEntities => 'No se encontraron entidades.';

  @override
  String get errConnection => 'Desliza para actualizar o verifica tu conexión.';

  @override
  String get errFailedLoadingEntities => 'Error cargando entidades';

  @override
  String get errFailedLoadingMaterials => 'Error cargando materiales';

  @override
  String get errFailedLoadingReasons => 'Error cargando razones';

  @override
  String errFailedLoadingSettings(Object message) {
    return 'Error cargando configuraciones $message';
  }
}
