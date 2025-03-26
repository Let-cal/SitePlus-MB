class ApiEndpoints {
  ////auth service
  static const String login = '/user/login';
  //// site service
  static const String siteCate = '/SiteCate';
  static const String createSite = '/Site';
  static const String getSiteById = '/Site';
  static const String updateSite = '/Site';
  static const String getAllSites = '/Site/staff';

  ///building service
  static const String getAllBuilding = '/Building/area';
  static const String createBuilding = '/Building';

  /// notifications service
  static const String notification = '/notifications';

  /// task service
  static const String task = '/Task';
  static const String taskStatuses = '/Task/statuses';
  static const String taskStatistics = '/Statistics/weekly-report-task';
  static const String siteStatistics = '/Statistics/weekly-report-site';

  /// location service
  static const String getAllDistricts = '/districts/get-all';
  static const String getAllAreaByDistrict = '/areas';
  static const String getAllAreas = '/areas/get-all';

  /// image service
  static const String imageUpload = '/Image/upload';
  static const String getImageSite = '/Image/site';

  /// attribute service
  static const String getAttribute = '/Attribute';
  static const String createReport = '/report';
  static const String updateReport = '/report';
  static const String getAttributeValues = '/attribute-values';

  /// customer segment
  static const String getCustomerSegments = '/CustomerSegment';

  /// status service
  static const String updateSiteStatus = '/Site/status';
  static const String updateTaskStatus = '/Task/status';
}
