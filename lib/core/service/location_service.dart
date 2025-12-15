// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:pm_app/core/network/dio_client.dart';
// import 'package:pm_app/models/response_models/geo_location_model.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';

// class LocationService {
  
//   final DioClient dioClient;
//   const LocationService({required this.dioClient});

//   /// CHECK LOCATION SERVICE
//   Future<bool> checkLocationService({required Location location}) async {
//     // Create a Location instance

//     // Check for location permission
//     PermissionStatus permission = await location.requestPermission();

//     if (permission == PermissionStatus.granted) {
//       // Check if location service is enabled
//       bool serviceEnabled = await location.serviceEnabled();

//       if (serviceEnabled) {
//         // If both permission and service are enabled, navigate to the home screen
//         return true;
//       } else {
//         // If location service is disabled, ask the user to enable it
//         bool serviceRequestResult = await location.requestService();
//         if (serviceRequestResult) {
//           return true;
//         } else {
//           // If user does not enable the service, show a dialog or navigate to map
//           return false;
//         }
//       }
//     } else if (permission == PermissionStatus.deniedForever) {
//       // If permission is denied, show a dialog or navigate to map
//       return false;
//     } else {
//       return false;
//     }
//   }

//   /// CHECK LOCATION PERMISSION AND SERVICE
//   Future<bool> checkLocationPermissionAndService() async {
//     // Create a Location instance
//     Location location = Location();

//     // Check for location permission
//     PermissionStatus permission = await location.requestPermission();

//     if (permission == PermissionStatus.granted) {
//       // Check if location service is enabled
//       bool serviceEnabled = await location.serviceEnabled();

//       if (serviceEnabled) {
//         return true;
//       } else {
//         // If location service is disabled, ask the user to enable it
//         bool serviceRequestResult = await location.requestService();

//         if (serviceRequestResult) {
//           return true;
//         } else {
//           // If user does not enable the service, return false
//           return false;
//         }
//       }
//     } else if (permission == PermissionStatus.denied) {
//       // If permission is denied, return false
//       return false;
//     } else if (permission == PermissionStatus.deniedForever) {
//       return false;
//     } else {
//       // For any other case, re-request permission
//       PermissionStatus newPermission = await location.requestPermission();

//       if (newPermission == PermissionStatus.granted) {
//         return true;
//       } else {
//         return false;
//       }
//     }
//   }

//   /// get place lat and lng by place ID
//   Future<LatLng?> getLatLngByPlaceId(String placeId) async {
//     const apiKey = "";

//     final url =
//         "https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$apiKey";

//     try {
//       final response = await dioClient.getRequest(apiUrl: url);

//       // Check if the request was successful
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.data);

//         // Check if the response status is OK
//         if (data['status'] == 'OK') {
//           // Extract latitude and longitude from the response
//           var result = data['result'];
//           double lat = result['geometry']['location']['lat'];
//           double lng = result['geometry']['location']['lng'];

//           // Return the coordinates as a LatLng object
//           return LatLng(lat, lng);
//         } else {
//           if (kDebugMode) {
//             print("Error: ${data['status']}");
//           }
//           return null;
//         }
//       } else {
//         debugPrint("Failed to load place details: ${response.statusCode}");
//         return null;
//       }
//     } catch (e) {
//       debugPrint("Error fetching place details: $e");
//       return null;
//     }
//   }

//   // Fetch address from latLng using Google Geocoding API
//   Future<GeoLocationModel?> getGeoLocation(LatLng? latLng) async {
//     final url =
//         'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng?.latitude},${latLng?.longitude}&key=';

//     try {
//       final response = await dioClient.getRequest(
//         apiUrl: url,
//       );

//       GeoLocationModel geolocation = GeoLocationModel.fromJson(response.data);

//       return geolocation;
//     } catch (e) {
//       return null;
//     }
//   }
// }
