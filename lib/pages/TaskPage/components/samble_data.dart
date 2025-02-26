import 'package:siteplus_mb/utils/constants.dart';

import 'task.dart';

class SampleData {
  // Danh sách các tòa nhà
  static List<Building> buildings = [
    Building(
      id: 'BLD-001',
      name: 'Vinhomes Central Park',
      address: 'Bình Thạnh, TP. Hồ Chí Minh',
    ),
    Building(
      id: 'BLD-002',
      name: 'Landmark 81',
      address: 'Bình Thạnh, TP. Hồ Chí Minh',
    ),
    Building(
      id: 'BLD-003',
      name: 'Pearl Plaza',
      address: 'Bình Thạnh, TP. Hồ Chí Minh',
    ),
  ];

  // Danh sách các địa điểm
  static List<Site> sites = [
    Site(
      id: 'SITE-001',
      name: 'Trung tâm thương mại Vinhomes',
      buildingId: 'BLD-001',
      district: 'Bình Thạnh',
      city: 'TP. Hồ Chí Minh',
      address: '208 Nguyễn Hữu Cảnh',
      building: buildings[0],
    ),
    Site(
      id: 'SITE-002',
      name: 'Khu vực quảng cáo Landmark',
      buildingId: 'BLD-002',
      district: 'Bình Thạnh',
      city: 'TP. Hồ Chí Minh',
      address: '720A Điện Biên Phủ',
      building: buildings[1],
    ),
    Site(
      id: 'SITE-003',
      name: 'Khu vực triển lãm Pearl',
      buildingId: 'BLD-003',
      district: 'Bình Thạnh',
      city: 'TP. Hồ Chí Minh',
      address: '561A Điện Biên Phủ',
      building: buildings[2],
    ),
    Site(
      id: 'SITE-004',
      name: 'Khu phố đi bộ Nguyễn Huệ',
      buildingId: null,
      district: 'Quận 1',
      city: 'TP. Hồ Chí Minh',
      address: 'Đường Nguyễn Huệ',
      building: null,
    ),
    Site(
      id: 'SITE-005',
      name: 'Chợ Bến Thành',
      buildingId: null,
      district: 'Quận 1',
      city: 'TP. Hồ Chí Minh',
      address: '32-30 Lê Lợi',
      building: null,
    ),
  ];

  // Danh sách các thương hiệu
  static List<Brand> brands = [
    Brand(id: 'BRD-001', name: 'Vinamilk', logo: 'assets/logos/vinamilk.png'),
    Brand(id: 'BRD-002', name: 'Samsung', logo: 'assets/logos/samsung.png'),
    Brand(id: 'BRD-003', name: 'Apple', logo: 'assets/logos/apple.png'),
    Brand(id: 'BRD-004', name: 'Coca Cola', logo: 'assets/logos/cocacola.png'),
    Brand(id: 'BRD-005', name: 'Masan', logo: 'assets/logos/masan.png'),
  ];

  static List<BrandRequest> brandRequests = [
    BrandRequest(
      id: 'REQ-001',
      brandId: 'BRD-001',
      description:
          'Highland Coffee yêu cầu khảo sát mặt bằng tại ngã tư trung tâm để mở quán cà phê mới.',
      status: 'Đã Duyệt',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      brand: brands[0],
    ),

    BrandRequest(
      id: 'REQ-002',
      brandId: 'BRD-002',
      description:
          'Samsung cần khảo sát lại mặt bằng trong trung tâm thương mại để mở cửa hàng flagship.',
      status: 'Đang Chờ',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      brand: brands[1],
    ),

    BrandRequest(
      id: 'REQ-003',
      brandId: 'BRD-003',
      description:
          'Apple yêu cầu kiểm tra và xác minh mặt bằng khả thi để đặt showroom tại khu đô thị mới.',
      status: 'Đã Duyệt',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      brand: brands[2],
    ),

    BrandRequest(
      id: 'REQ-004',
      brandId: 'BRD-004',
      description:
          'Coca Cola muốn tìm kiếm mặt bằng cho chiến dịch quảng cáo mùa hè tại khu vui chơi lớn.',
      status: 'Đã Duyệt',
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      brand: brands[3],
    ),

    BrandRequest(
      id: 'REQ-005',
      brandId: 'BRD-005',
      description:
          'Masan cần khảo sát địa điểm để trưng bày sản phẩm mới trong chuỗi siêu thị lớn.',
      status: 'Đang Chờ',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      brand: brands[4],
    ),
  ];

  // Danh sách các công việc
  static List<Task> tasks = [
    // Task 1: Task từ request - Khảo sát lại địa điểm có sẵn
    Task(
      id: 'TASK-001',
      name: 'Khảo sát lại địa điểm Vinamilk',
      description:
          'Tiến hành khảo sát lại các vị trí quảng cáo đã triển khai theo yêu cầu của Vinamilk để xem xét khả năng mở rộng hoặc điều chỉnh.',
      status: STATUS_CHUA_NHAN,
      priority: PRIORITY_CAO,
      areaId: 'AREA-001',
      requestId: 'REQ-001',
      siteId: null,
      assignedTo: 'Nguyễn Văn A',
      deadline: DateTime.now().add(const Duration(days: 7)),
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      request: brandRequests[0],
      site: null,
    ),

    // Task 2: Task đã hoàn thành - Từ request, có site cụ thể
    Task(
      id: 'TASK-002',
      name: 'Kiểm tra hiệu quả quảng cáo Apple',
      description:
          'Đánh giá hiệu quả quảng cáo tại địa điểm đã triển khai cho Apple và đề xuất phương án cải thiện nếu cần.',
      status: STATUS_DA_NHAN,
      priority: PRIORITY_CAO,
      areaId: 'AREA-002',
      requestId: 'REQ-003',
      siteId: 'SITE-003',
      assignedTo: 'Trần Thị B',
      deadline: DateTime.now().subtract(const Duration(days: 5)),
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      request: brandRequests[2],
      site: sites[2],
    ),

    // Task 3: Task đang tiến hành - Từ request, khảo sát lại vị trí
    Task(
      id: 'TASK-003',
      name: 'Khảo sát lại địa điểm quảng cáo Samsung',
      description:
          'Kiểm tra lại các vị trí quảng cáo Samsung Galaxy S24 để đánh giá tính hiệu quả và tìm kiếm mặt bằng thay thế nếu cần.',
      status: STATUS_DA_NHAN,
      priority: PRIORITY_TRUNG_BINH,
      areaId: 'AREA-003',
      requestId: 'REQ-002',
      siteId: null,
      assignedTo: 'Lê Văn C',
      deadline: DateTime.now().add(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      request: brandRequests[1],
      site: null,
    ),

    // Task 4: Task đã hoàn thành - Từ request, triển khai site không có building
    Task(
      id: 'TASK-004',
      name: 'Đánh giá địa điểm quảng cáo Coca Cola',
      description:
          'Kiểm tra tính hiệu quả của địa điểm quảng cáo Coca Cola tại phố đi bộ và báo cáo đề xuất cải thiện.',
      status: STATUS_HOAN_THANH,
      priority: PRIORITY_CAO,
      areaId: 'AREA-004',
      requestId: 'REQ-004',
      siteId: 'SITE-004',
      assignedTo: 'Phạm Thị D',
      deadline: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      request: brandRequests[3],
      site: sites[3],
    ),

    // Task 5: Task từ Area Manager - Khảo sát tìm mặt bằng mới
    Task(
      id: 'TASK-005',
      name: 'Khảo sát địa điểm mới tại Vinhomes',
      description:
          'Tiến hành khảo sát các vị trí tiềm năng tại Vinhomes Central Park để tìm mặt bằng phù hợp cho quảng cáo.',
      status: STATUS_CHUA_NHAN,
      priority: PRIORITY_THAP,
      areaId: 'AREA-001',
      requestId: null,
      siteId: null,
      assignedTo: 'Nguyễn Văn E',
      deadline: DateTime.now().add(const Duration(days: 14)),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      request: null,
      site: null,
    ),

    // Task 6: Task đã hoàn thành - Từ request, có site và building cụ thể
    Task(
      id: 'TASK-006',
      name: 'Khảo sát quảng cáo Masan',
      description:
          'Tiến hành đánh giá địa điểm quảng cáo sản phẩm mới của Masan để xác nhận tính hiệu quả và báo cáo kết quả.',
      status: STATUS_HOAN_THANH,
      priority: PRIORITY_TRUNG_BINH,
      areaId: 'AREA-002',
      requestId: 'REQ-005',
      siteId: 'SITE-001',
      assignedTo: 'Vũ Thị F',
      deadline: DateTime.now().subtract(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      request: brandRequests[4],
      site: sites[0],
    ),

    // Task 7: Task từ request - Kiểm tra phản hồi khách hàng
    Task(
      id: 'TASK-007',
      name: 'Đánh giá phản hồi khách hàng về quảng cáo Apple',
      description:
          'Thu thập ý kiến phản hồi từ khách hàng về quảng cáo Apple và phân tích mức độ ảnh hưởng đến thương hiệu.',
      status: STATUS_DA_NHAN,
      priority: PRIORITY_TRUNG_BINH,
      areaId: 'AREA-003',
      requestId: 'REQ-003',
      siteId: null,
      assignedTo: 'Trần Văn G',
      deadline: DateTime.now().add(const Duration(days: 5)),
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      request: brandRequests[2],
      site: null,
    ),
  ];

  // Phương thức để lấy dữ liệu task
  static List<Task> getTasks() {
    return tasks;
  }
}
