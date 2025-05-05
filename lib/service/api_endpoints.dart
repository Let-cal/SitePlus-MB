class ApiEndpoints {
  ////auth service
  static const String login = '/users/auth/token'; //done
  //// site service
  static const String siteCate = '/site-categories'; //done
  static const String createSite = '/sites'; //done
  static const String getSiteById = '/sites'; //done
  static const String updateSite = '/sites'; //done
  static const String getAllSites = '/sites/by-staff'; //done
  static const String createSiteDeal = '/site-deals'; //done
  static const String getSiteDealBySiteId = '/site-deals/by-site'; //done
  static const String getSiteDealByUserId = '/site-deals/by-user'; //done
  static const String getSiteDealById = '/site-deals'; //done
  static const String updateSiteDeal = '/site-deals'; //done
  static const String updateSiteDealStatus = '/site-deals'; //done

  ///building service
  static const String getAllBuilding = '/buildings/areas'; //done
  static const String createBuilding = '/buildings'; //done

  /// notifications service
  static const String notification = '/notifications'; //done

  /// task service
  static const String task = '/tasks'; //done
  static const String taskStatuses = '/tasks/status'; //done

  /// report statistic
  static const String taskStatistics = '/statistics/tasks/weekly-report'; //done
  static const String siteStatistics = '/statistics/sites/weekly-report'; //done

  /// location service
  static const String getAllDistricts = '/districts'; //done
  static const String getAllAreaByDistrict = '/areas/district'; //done
  static const String getAllAreas = '/areas'; //done

  /// image service
  static const String imageUpload = '/images/upload'; //done
  static const String getImageSite = '/images/site'; //done
  static const String deleteImage = '/images'; //done

  /// attribute service
  static const String getAllAttributes = '/attributes'; //done
  static const String createReport = '/reports'; //done
  static const String updateReport = '/reports'; //done
  static const String getAttributeValuesBySiteId =
      '/attribute-values/site'; //done
  static const String getAttributes = '/attributes'; //done

  /// customer segment
  static const String getCustomerSegments = '/customer-segments'; //done

  /// status service
  static const String updateSiteStatus = '/sites/status'; //done
  static const String updateTaskStatus = '/tasks/status'; //done
}
