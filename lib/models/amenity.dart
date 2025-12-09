class Amenity {
  final int id;
  final String name;
  final String category;
  final double lat;
  final double lng;
  final String? description;
  final String? icon;

  Amenity({
    required this.id,
    required this.name,
    required this.category,
    required this.lat,
    required this.lng,
    this.description,
    this.icon,
  });
}

enum AmenityCategory {
  medical('Medical', 'Hospitals, clinics, first aid'),
  food('Food & Water', 'Restaurants, food stalls, water points'),
  restroom('Restrooms', 'Public toilets, washrooms'),
  parking('Parking', 'Parking lots, vehicle parking'),
  accommodation('Accommodation', 'Hotels, guest houses, dharamshalas'),
  transport('Transport', 'Bus stops, taxi stands, auto rickshaws'),
  worship('Worship', 'Temples, ghats, prayer areas'),
  shopping('Shopping', 'Markets, shops, stores');

  final String title;
  final String description;

  const AmenityCategory(this.title, this.description);
}

// Sample amenities data
final List<Amenity> ALL_AMENITIES = [
  // Medical
  Amenity(id: 1, name: 'City Hospital', category: 'medical', lat: 29.9500, lng: 78.1600, description: '24/7 Emergency services'),
  Amenity(id: 2, name: 'First Aid Post 1', category: 'medical', lat: 29.9576, lng: 78.1712, description: 'Near Har Ki Pauri'),
  Amenity(id: 3, name: 'First Aid Post 2', category: 'medical', lat: 29.9350, lng: 78.1550, description: 'Near Triveni Ghat'),
  
  // Food & Water
  Amenity(id: 4, name: 'Food Court Main', category: 'food', lat: 29.9500, lng: 78.1600, description: 'Multiple food options'),
  Amenity(id: 5, name: 'Water Point 1', category: 'food', lat: 29.9576, lng: 78.1712, description: 'Drinking water available'),
  Amenity(id: 6, name: 'Water Point 2', category: 'food', lat: 29.9650, lng: 78.1850, description: 'Drinking water available'),
  Amenity(id: 7, name: 'Langar Hall', category: 'food', lat: 29.9400, lng: 78.1400, description: 'Free community kitchen'),
  
  // Restrooms
  Amenity(id: 8, name: 'Public Toilet 1', category: 'restroom', lat: 29.9576, lng: 78.1712, description: 'Near Har Ki Pauri'),
  Amenity(id: 9, name: 'Public Toilet 2', category: 'restroom', lat: 29.9350, lng: 78.1550, description: 'Near Triveni Ghat'),
  Amenity(id: 10, name: 'Public Toilet 3', category: 'restroom', lat: 29.9650, lng: 78.1850, description: 'Near Ram Jhula'),
  
  // Parking
  Amenity(id: 11, name: 'Parking Lot A', category: 'parking', lat: 29.9400, lng: 78.1400, description: 'Car parking available'),
  Amenity(id: 12, name: 'Parking Lot B', category: 'parking', lat: 29.9500, lng: 78.1500, description: 'Two-wheeler parking'),
  Amenity(id: 13, name: 'Parking Lot C', category: 'parking', lat: 29.9800, lng: 78.1900, description: 'Bus parking'),
  
  // Accommodation
  Amenity(id: 14, name: 'Hotel Ganga View', category: 'accommodation', lat: 29.9576, lng: 78.1712, description: '3-star hotel'),
  Amenity(id: 15, name: 'Dharamshala 1', category: 'accommodation', lat: 29.9350, lng: 78.1550, description: 'Budget accommodation'),
  Amenity(id: 16, name: 'Guest House', category: 'accommodation', lat: 29.9500, lng: 78.1600, description: 'Family rooms available'),
  
  // Transport
  Amenity(id: 17, name: 'Bus Stand', category: 'transport', lat: 29.9400, lng: 78.1400, description: 'Main bus terminal'),
  Amenity(id: 18, name: 'Auto Stand', category: 'transport', lat: 29.9576, lng: 78.1712, description: 'Auto rickshaw stand'),
  Amenity(id: 19, name: 'Taxi Stand', category: 'transport', lat: 29.9500, lng: 78.1600, description: 'Taxi booking'),
  
  // Worship
  Amenity(id: 20, name: 'Har Ki Pauri', category: 'worship', lat: 29.9576, lng: 78.1712, description: 'Main ghat for prayers'),
  Amenity(id: 21, name: 'Triveni Ghat', category: 'worship', lat: 29.9350, lng: 78.1550, description: 'Sacred bathing ghat'),
  Amenity(id: 22, name: 'Mansa Devi Temple', category: 'worship', lat: 29.9650, lng: 78.1850, description: 'Famous temple'),
  
  // Shopping
  Amenity(id: 23, name: 'Main Bazaar', category: 'shopping', lat: 29.9500, lng: 78.1600, description: 'Shopping market'),
  Amenity(id: 24, name: 'Gift Shop 1', category: 'shopping', lat: 29.9576, lng: 78.1712, description: 'Religious items'),
  Amenity(id: 25, name: 'Gift Shop 2', category: 'shopping', lat: 29.9350, lng: 78.1550, description: 'Souvenirs'),
];

