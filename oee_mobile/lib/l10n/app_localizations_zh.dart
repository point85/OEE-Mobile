// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Point85 OEE 应用程序';

  @override
  String get appVersion => '2.1.0';

  @override
  String get homePageTitle => 'Point85 OEE';

  @override
  String get homeAboutText =>
      'Point85 设备综合效率（OEE）应用程序能够从多个数据源收集设备数据，以支持性能、可用性和质量的 OEE 计算。\n\n更多信息请访问 https://github.com/Point85/OEE-Designer。';

  @override
  String get homeSettings => '设置';

  @override
  String get homeRefresh => '刷新';

  @override
  String get homeAbout => '关于';

  @override
  String get homeSave => '保存';

  @override
  String get homeEquipStatus => '正在请求设备状态...';

  @override
  String get homeSettingsSaved => '设置已保存。';

  @override
  String get homeServerHint => 'HTTP 服务器名称或 IP 地址';

  @override
  String get homeServerLabel => '服务器 *';

  @override
  String get homePortHint => 'HTTP 服务器端口';

  @override
  String get homePortLabel => '端口 *';

  @override
  String equipment(Object name) {
    return '设备：$name';
  }

  @override
  String get equip => '设备';

  @override
  String get equipAvailStart => '正在记录可用性事件...';

  @override
  String get equipAvailDone => '可用性事件已记录。';

  @override
  String get equipProdStart => '正在记录生产事件...';

  @override
  String get equipProdDone => '生产事件已记录。';

  @override
  String get equipSetupStart => '正在记录设置事件...';

  @override
  String get equipSetupDone => '设置事件已记录。';

  @override
  String get equipTabAvail => '可用性';

  @override
  String get equipTabProd => '生产';

  @override
  String get equipTabSetup => '设置/作业';

  @override
  String get equipNoReason => '选择原因';

  @override
  String get equipNoMaterial => '选择材料';

  @override
  String get equipReason => '原因';

  @override
  String get equipMaterial => '材料';

  @override
  String get equipTimePeriod => '按时间段';

  @override
  String get equipEvent => '按事件';

  @override
  String get equipStart => '开始时间';

  @override
  String get equipEnd => '结束时间';

  @override
  String get equipDuration => '持续时间';

  @override
  String get equipHrs => '小时';

  @override
  String get equipMins => '分钟';

  @override
  String get equipSubmit => '提交';

  @override
  String get equipGood => '良品';

  @override
  String get equipReject => '废品/返工';

  @override
  String get equipStartup => '启动';

  @override
  String get equipAmountHint => '输入数量';

  @override
  String get equipAmountLabel => '数量 *';

  @override
  String get equipJobHint => '作业 ID';

  @override
  String get equipJobLabel => '作业';

  @override
  String get equipMaterialLabel => '材料';

  @override
  String get equipMatlDescLabel => '描述';

  @override
  String get equipReasonLabel => '当前原因';

  @override
  String get equipLossLabel => '损失类别';

  @override
  String get equipRunLabel => '运行速率单位';

  @override
  String get equipRejectLabel => '废品单位';

  @override
  String get equipStatus => '设备状态';

  @override
  String get buttonClose => '关闭';

  @override
  String get errorTitle => 'OEE 应用程序错误';

  @override
  String get infoTitle => 'OEE 应用程序信息';

  @override
  String get reasonTitle => 'OEE 原因';

  @override
  String get materialTitle => 'OEE 材料';

  @override
  String get refreshedEntities => '已刷新实体';

  @override
  String get refreshedMaterials => '已刷新材料';

  @override
  String get refreshedReasons => '已刷新原因';

  @override
  String get retry => '重试';

  @override
  String get loading => '加载中...';

  @override
  String get none => '无';

  @override
  String get na => '不适用';

  @override
  String get lossMinorStoppages => '小停机';

  @override
  String get lossNoLoss => '正常运行';

  @override
  String get lossNotScheduled => '当前未安排';

  @override
  String get lossPlannedDowntime => '计划停机';

  @override
  String get lossReducedSpeed => '降速运行';

  @override
  String get lossRejectRework => '废品材料';

  @override
  String get lossSetup => '机器设置';

  @override
  String get lossStartupYield => '机器启动产出';

  @override
  String get lossUnplannedDowntime => '非计划停机';

  @override
  String get lossUnscheduled => '未安排';

  @override
  String errNoLocalizations(Object message) {
    return '$message';
  }

  @override
  String get errNoHttpServer => '必须在设置中定义 HTTP 服务器名称和端口。';

  @override
  String get errNoServerName => '需要服务器名称。';

  @override
  String get errNoServerPort => '需要服务器端口。';

  @override
  String errInvalidDate(Object date) {
    return '日期 $date 无效。';
  }

  @override
  String get errMaterialTimeOut => '获取材料超时。';

  @override
  String get errMustSelectEvent => '必须选择生产事件类型。';

  @override
  String errNoSetup(Object name) {
    return '设备 $name 尚未执行设置。';
  }

  @override
  String errInvalidAmount(Object amount) {
    return '数量 $amount 必须大于零。';
  }

  @override
  String errInvalidDuration(Object duration) {
    return '持续时间 $duration 必须大于零。';
  }

  @override
  String errLoadFailed(Object message, Object name) {
    return '加载设备 $name 失败：$message。';
  }

  @override
  String errGetFailed(Object message, Object name) {
    return '获取设备 $name 失败：$message。';
  }

  @override
  String errStatusGetFailed(Object message, Object name) {
    return '获取设备 $name 状态失败：$message。';
  }

  @override
  String get errNoEquipmentName => '设备名称不能为空。';

  @override
  String get errNoEntities => '未找到实体。';

  @override
  String get errConnection => '下拉刷新或检查网络连接。';

  @override
  String get errFailedLoadingEntities => '加载实体时出错';

  @override
  String get errFailedLoadingMaterials => '加载材料时出错';

  @override
  String get errFailedLoadingReasons => '加载原因时出错';

  @override
  String errFailedLoadingSettings(Object message) {
    return '加载设置时出错 $message';
  }
}
