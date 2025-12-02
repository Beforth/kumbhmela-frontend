import 'package:latlong2/latlong.dart';

// Coordinates for Haridwar Region
const LatLng HARIDWAR_CENTER = LatLng(29.9457, 78.1642);

// Family Member Model
class FamilyMember {
  final String id;
  final String name;
  final String relation;
  final int batteryLevel;
  final bool isCharging;
  final double distanceKm;
  final Location location;
  final String lastActive;
  final MemberStatus status;
  final String avatarUrl;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.batteryLevel,
    required this.isCharging,
    required this.distanceKm,
    required this.location,
    required this.lastActive,
    required this.status,
    required this.avatarUrl,
  });
}

class Location {
  final double lat;
  final double lng;
  final String? address;

  Location({required this.lat, required this.lng, this.address});
}

enum MemberStatus { safe, moving, offline, danger }

// Missing Person Model
class MissingPersonReport {
  final String id;
  final String name;
  final int age;
  final String lastSeenLocation;
  final String lastSeenTime;
  final String description;
  final ReportStatus status;
  final String imageUrl;

  MissingPersonReport({
    required this.id,
    required this.name,
    required this.age,
    required this.lastSeenLocation,
    required this.lastSeenTime,
    required this.description,
    required this.status,
    required this.imageUrl,
  });
}

enum ReportStatus { missing, found }

// Crowd Zone Model
class CrowdZone {
  final int id;
  final String name;
  final String status;
  final String color;
  final int capacity;
  final double lat;
  final double lng;

  CrowdZone({
    required this.id,
    required this.name,
    required this.status,
    required this.color,
    required this.capacity,
    required this.lat,
    required this.lng,
  });
}

// Mock Data for Family Members
final List<FamilyMember> MOCK_FAMILY = [
  FamilyMember(
    id: '1',
    name: 'Rajesh Kumar',
    relation: 'Brother',
    batteryLevel: 85,
    isCharging: false,
    distanceKm: 0.2,
    location: Location(lat: 29.9560, lng: 78.1700, address: 'Near Har Ki Pauri'),
    lastActive: '2 min ago',
    status: MemberStatus.safe,
    avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Rajesh',
  ),
  FamilyMember(
    id: '2',
    name: 'Sunita Devi',
    relation: 'Mother',
    batteryLevel: 92,
    isCharging: false,
    distanceKm: 0.5,
    location: Location(lat: 29.9540, lng: 78.1680, address: 'Upper Road Market'),
    lastActive: '1 min ago',
    status: MemberStatus.safe,
    avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sunita',
  ),
  FamilyMember(
    id: '3',
    name: 'Amit Kumar',
    relation: 'Son',
    batteryLevel: 78,
    isCharging: true,
    distanceKm: 1.5,
    location: Location(lat: 29.9400, lng: 78.1500, address: 'Parking Lot B'),
    lastActive: 'Just now',
    status: MemberStatus.moving,
    avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Amit',
  ),
];

// Mock Data for Missing Persons
final List<MissingPersonReport> MOCK_MISSING = [
  MissingPersonReport(
    id: '101',
    name: 'Radha Devi',
    age: 65,
    lastSeenLocation: 'Near Har Ki Pauri',
    lastSeenTime: '2 hours ago',
    description: 'Wearing red saree, gold chain. Speaks Hindi only.',
    status: ReportStatus.missing,
    imageUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Radha',
  ),
  MissingPersonReport(
    id: '102',
    name: 'Rahul Singh',
    age: 8,
    lastSeenLocation: 'Railway Station Gate 2',
    lastSeenTime: '30 mins ago',
    description: 'Yellow t-shirt, blue jeans. Carrying a water bottle.',
    status: ReportStatus.found,
    imageUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Rahul',
  ),
];

// Crowd Zones Data
final List<CrowdZone> CROWD_ZONES = [
  CrowdZone(id: 1, name: 'Har Ki Pauri', status: 'Moderate', color: 'orange', capacity: 45, lat: 29.9576, lng: 78.1712),
  CrowdZone(id: 2, name: 'Triveni Ghat', status: 'Safe', color: 'green', capacity: 25, lat: 29.9350, lng: 78.1550),
  CrowdZone(id: 3, name: 'Ram Jhula', status: 'High', color: 'red', capacity: 75, lat: 29.9650, lng: 78.1850),
  CrowdZone(id: 4, name: 'Main Bazaar', status: 'Critical', color: 'red', capacity: 95, lat: 29.9500, lng: 78.1600),
  CrowdZone(id: 5, name: 'Lakshman Jhula', status: 'Moderate', color: 'yellow', capacity: 50, lat: 29.9800, lng: 78.1900),
  CrowdZone(id: 6, name: 'Bharat Mandir', status: 'Safe', color: 'green', capacity: 30, lat: 29.9400, lng: 78.1400),
];
