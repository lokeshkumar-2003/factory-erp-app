class Apivariables {
  static const String baseUrl = 'http://192.168.183.171:5000';
  static const String baseurlFastApi = 'http://192.168.183.171:8002';
  static const String baseUrl1 = 'http://192.168.183.171:8002';

  static const String login_url = '$baseUrl/v1/api/auth/login';

  static const String get_user_list = '$baseUrl/v1/api/auth/get/users';

  static const String get_user = '$baseUrl/v1/api/auth/get/user';

  static const String edit_user = '$baseUrl/v1/api/auth/update';

  static const String delete_user = '$baseUrl/v1/api/auth/delete';

  static const String add_user = '$baseUrl/v1/api/auth/add';

  static const String get_device_id = '$baseUrl/v1/api/auth/user/deviceid';

  static const String device_id_activate =
      '$baseUrl/v1/api/auth/device_id_activate';

  static const String get_meter_list = '$baseUrl/v1/api/meters';

  static const String get_sub_meter_list = '$baseUrl/v1/api/sub/meters';
  static const String get_submeterlist = '$baseUrl/v1/api/sub/meters';
  static const String edit_meter_name = '$baseUrl/v1/api/edit/meters/name';

  static const String meter_status = '$baseUrl/v1/api/update/meter/status';

  static const String sub_meter_status =
      '$baseUrl/v1/api/update/sub/meter/status';

  static const String delete_sub_meter_status =
      '$baseUrl/v1/api/delete/sub/meter';

  static const String delete_meter = '$baseUrl/v1/api/delete/meter';

  static const String get_sub_meter_name = '$baseUrl/v1/api/sub/meters';

  static const String add_new_meter = '$baseUrl/v1/api/add/meters';

  static const String power_meter_image = '$baseUrl/v1/api/ocr';

  static const String extract_water_meter_reading =
      '$baseurlFastApi/v1/api/watermeter/detect/reading/value';

  static const String add_water_meter_reading =
      '$baseUrl/v1/api/add/readings/watermeter';

  static const String qr_code_converter = '$baseUrl/v1/api/generate_qr/meter';
  static const String download_reports =
      '$baseUrl/v1/api/meter/reading/report/pdf';

  static const String view_report = '$baseUrl/v1/api/reports/meter/readings';

  static const String view_recent_30_days_readings =
      '$baseUrl/v1/api/watermeter/reading/recent';

  static const String view_dashboard_reports =
      "$baseUrl/v1/api/watermeter/reading/report";

  static const String add_new_sub_meter = '$baseUrl/v1/api/add/submeter';

  static const String fcm_token = "$baseUrl/v1/api/fcm/token/";

  static const String notification_user =
      "$baseUrl/v1/api/notification/admins/user";

  static const String notification_meter =
      "$baseUrl/v1/api/notification/admins/meter";

  static const String get_powermeter_list = "$baseUrl/v1/api/meter/power/list";

  static const String get_notification_data =
      "$baseUrl/v1/api/app/notifications/";

  static const String mark_notification =
      "$baseUrl/v1/api/app/notifications/mark-read";

  static const String check_meter = "$baseUrl/v1/api/check/meter/status/";
}
