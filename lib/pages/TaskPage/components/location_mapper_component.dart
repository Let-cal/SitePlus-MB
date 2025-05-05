import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationMapperComponent extends StatefulWidget {
  final String specificAddress;
  final String district;
  final String city;
  final String? buildingName;

  const LocationMapperComponent({
    super.key,
    required this.specificAddress,
    required this.district,
    required this.city,
    this.buildingName,
  });

  @override
  State<LocationMapperComponent> createState() =>
      _LocationMapperComponentState();
}

class _LocationMapperComponentState extends State<LocationMapperComponent> {
  bool _isLoading = false;
  Location? _location;
  String? _errorMessage;
  bool _showMap = false;
  LatLng? _districtCenter;

  // Tọa độ mặc định cho Ho Chi Minh City để fallback nếu geocoding thất bại
  final LatLng _hcmcDefault = LatLng(
    10.7769,
    106.7009,
  ); // Tọa độ trung tâm HCMC

  // Bảng ánh xạ tên quận sang tọa độ trung tâm để fallback
  final Map<String, LatLng> _districtCoordinates = {
    'quan-1': LatLng(10.7756, 106.7019),
    'quan-2': LatLng(10.7860, 106.7501),
    'quan-3': LatLng(10.7824, 106.6841),
    'quan-4': LatLng(10.7578, 106.7016),
    'quan-5': LatLng(10.7539, 106.6633),
    // Có thể thêm các quận khác ở đây
  };

  Future<void> _geocodeAddress() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String searchQuery;
      if (widget.buildingName != null && widget.buildingName!.isNotEmpty) {
        searchQuery =
            '${widget.buildingName}, ${widget.district}, ${widget.city}, Vietnam';
      } else {
        searchQuery =
            '${widget.specificAddress}, ${widget.district}, ${widget.city}, Vietnam';
      }

      final locations = await locationFromAddress(searchQuery);

      if (locations.isNotEmpty) {
        setState(() {
          _location = locations.first;
          _isLoading = false;
        });
      } else {
        _fallbackToDefaultCoordinates();
      }
    } catch (e) {
      print('Geocoding error: $e');
      _fallbackToDefaultCoordinates();
    }
  }

  void _fallbackToDefaultCoordinates() {
    // Fallback to district center if available
    final districtKey = _normalizeDistrictName(widget.district);
    if (_districtCoordinates.containsKey(districtKey)) {
      setState(() {
        final coords = _districtCoordinates[districtKey]!;
        _location = Location(
          latitude: coords.latitude,
          longitude: coords.longitude,
          timestamp: DateTime.now(),
        );
        _errorMessage = 'Using approximate coordinates for ${widget.district}';
        _isLoading = false;
      });
    } else {
      // Default to HCMC center
      setState(() {
        _location = Location(
          latitude: _hcmcDefault.latitude,
          longitude: _hcmcDefault.longitude,
          timestamp: DateTime.now(),
        );
        _errorMessage = 'Using default coordinates for Ho Chi Minh City';
        _isLoading = false;
      });
    }
  }

  Future<void> _showLocationMap() async {
    if (_location == null) {
      // Nếu chưa có location, thực hiện geocode trước
      await _geocodeAddress();
      if (_location == null) {
        // Nếu vẫn không có location, hiển thị thông báo lỗi
        setState(() {
          _errorMessage = 'Could not find coordinates for this location';
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Sử dụng vị trí đã geocode
      setState(() {
        _districtCenter = LatLng(_location!.latitude, _location!.longitude);
        _showMap = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error showing map: ${e.toString()}';
        _isLoading = false;
      });
      print('Show map error: $e');
    }
  }

  // Chuẩn hóa tên quận để so sánh
  String _normalizeDistrictName(String district) {
    // Chuyển "Quận 1" thành "quan-1" để so sánh
    return district
        .toLowerCase()
        .replaceAll('quận ', 'quan-')
        .replaceAll(' ', '-')
        .replaceAll('đ', 'd')
        .replaceAll('ậ', 'a')
        .replaceAll('ấ', 'a')
        .replaceAll('ầ', 'a')
        .replaceAll('ắ', 'a')
        .replaceAll('ằ', 'a')
        .replaceAll('ẫ', 'a')
        .replaceAll('ẩ', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('ẵ', 'a')
        .replaceAll('ẳ', 'a')
        .replaceAll('ế', 'e')
        .replaceAll('ề', 'e')
        .replaceAll('ễ', 'e')
        .replaceAll('ể', 'e')
        .replaceAll('ố', 'o')
        .replaceAll('ồ', 'o')
        .replaceAll('ỗ', 'o')
        .replaceAll('ổ', 'o')
        .replaceAll('ớ', 'o')
        .replaceAll('ờ', 'o')
        .replaceAll('ỡ', 'o')
        .replaceAll('ở', 'o')
        .replaceAll('ứ', 'u')
        .replaceAll('ừ', 'u')
        .replaceAll('ữ', 'u')
        .replaceAll('ử', 'u')
        .replaceAll('ỳ', 'y')
        .replaceAll('ỹ', 'y')
        .replaceAll('ỷ', 'y')
        .replaceAll('ỵ', 'y');
  }

  void _openInGoogleMaps() {
    if (_location != null) {
      final url =
          'https://www.google.com/maps/search/?api=1&query=${_location!.latitude},${_location!.longitude}';
      _launchUrl(url);
    }
  }

  void _openLocationInGoogleMaps() {
    if (_districtCenter != null) {
      final url =
          'https://www.google.com/maps/search/?api=1&query=${_districtCenter!.latitude},${_districtCenter!.longitude}';
      _launchUrl(url);
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open Google Maps')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening URL: ${e.toString()}')),
      );
    }
  }

  void _copyCoordinatesToClipboard() {
    if (_location != null) {
      final coordinates = '${_location!.latitude},${_location!.longitude}';
      Clipboard.setData(ClipboardData(text: coordinates));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coordinates copied to clipboard')),
      );
    }
  }

  void _hideMap() {
    setState(() {
      _showMap = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pin_drop, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 12),
              Text(
                'Location on Map',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(
            height: 1,
            thickness: 1,
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),

          Text(
            'Current address:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.buildingName != null && widget.buildingName!.isNotEmpty
                ? '${widget.specificAddress}, ${widget.district}, ${widget.city} (${widget.buildingName})'
                : '${widget.specificAddress}, ${widget.district}, ${widget.city}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),

          if (_showMap) ...[
            // Hiển thị bản đồ khi _showMap = true
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: _districtCenter!,
                    initialZoom: 15.0, // Zoom gần hơn để thấy rõ pin
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.myapp.siteplus_mb',
                    ),
                    // Hiển thị pin tại vị trí
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _districtCenter!,
                          width: 80,
                          height: 80,
                          child: Icon(
                            Icons.location_on,
                            color: theme.colorScheme.primary,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _hideMap,
                    icon: const Icon(Icons.close),
                    label: const Text('Hide Map'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _openLocationInGoogleMaps,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Google Maps'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (_location != null) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Coordinates:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_location!.latitude.toStringAsFixed(6)}, ${_location!.longitude.toStringAsFixed(6)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.content_copy,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: _copyCoordinatesToClipboard,
                  tooltip: 'Copy coordinates',
                ),
              ],
            ),
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _openInGoogleMaps,
                    icon: const Icon(Icons.map),
                    label: const Text('Google Maps'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _showLocationMap,
                    icon: const Icon(Icons.layers),
                    label: const Text('Show Map'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: theme.colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (_isLoading) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: CircularProgressIndicator(),
              ),
            ),
          ] else ...[
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _geocodeAddress,
                    icon: const Icon(Icons.search),
                    label: const Text('Find Location'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _showLocationMap,
                    icon: const Icon(Icons.map),
                    label: const Text('Show Map'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: theme.colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
