import 'package:viora_app/features/organization/domain/entities/branch_detail.dart';

class BranchDetailModel {
  final String id;
  final String organizationId;
  final String organizationName;
  final List<String> services;
  final String address;
  final double latitude;
  final double longitude;
  final String branchStatus;
  final String contactEmail;
  final List<String> phoneNumbers;
  final List<BusinessHourModel> schedule;
  final String timeZone;
  final DateTime openedSinceUtc;
  final List<GalleryMediaModel> gallery;
  final bool isCurrentlyOpen;

  const BranchDetailModel({
    required this.id,
    required this.organizationId,
    required this.organizationName,
    required this.services,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.branchStatus,
    required this.contactEmail,
    required this.phoneNumbers,
    required this.schedule,
    required this.timeZone,
    required this.openedSinceUtc,
    required this.gallery,
    required this.isCurrentlyOpen,
  });

  factory BranchDetailModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    return BranchDetailModel(
      id: json['id']?.toString() ?? '',
      organizationId: json['organizationId']?.toString() ?? '',
      organizationName: json['organizationName']?.toString() ?? '',
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      address: json['address']?.toString() ?? '',
      latitude: (location?['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (location?['longitude'] as num?)?.toDouble() ?? 0.0,
      branchStatus: json['branchStatus']?.toString() ?? 'Active',
      contactEmail: json['contactEmail']?.toString() ?? '',
      phoneNumbers: (json['phoneNumbers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      schedule: (json['schedule'] as List<dynamic>?)
              ?.map((e) =>
                  BusinessHourModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      timeZone: json['timeZone']?.toString() ?? '',
      openedSinceUtc: json['openedSinceUtc'] != null
          ? DateTime.parse(json['openedSinceUtc'].toString())
          : DateTime.now(),
      gallery: (json['gallery'] as List<dynamic>?)
              ?.map((e) =>
                  GalleryMediaModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isCurrentlyOpen: json['isCurrentlyOpen'] as bool? ?? false,
    );
  }

  BranchDetail toEntity() {
    return BranchDetail(
      id: id,
      organizationId: organizationId,
      organizationName: organizationName,
      services: services,
      address: address,
      latitude: latitude,
      longitude: longitude,
      branchStatus: branchStatus,
      contactEmail: contactEmail,
      phoneNumbers: phoneNumbers,
      schedule: schedule.map((s) => s.toEntity()).toList(),
      timeZone: timeZone,
      openedSinceUtc: openedSinceUtc,
      gallery: gallery.map((g) => g.toEntity()).toList(),
      isCurrentlyOpen: isCurrentlyOpen,
    );
  }
}

class BusinessHourModel {
  final int day;
  final String openTime;
  final String closeTime;

  const BusinessHourModel({
    required this.day,
    required this.openTime,
    required this.closeTime,
  });

  factory BusinessHourModel.fromJson(Map<String, dynamic> json) {
    return BusinessHourModel(
      day: json['day'] as int? ?? 0,
      openTime: json['openTime']?.toString() ?? '',
      closeTime: json['closeTime']?.toString() ?? '',
    );
  }

  BusinessHour toEntity() {
    return BusinessHour(
      day: day,
      openTime: openTime,
      closeTime: closeTime,
    );
  }
}

class GalleryMediaModel {
  final String id;
  final String contentType;
  final String fileName;
  final DateTime createdAt;

  const GalleryMediaModel({
    required this.id,
    required this.contentType,
    required this.fileName,
    required this.createdAt,
  });

  factory GalleryMediaModel.fromJson(Map<String, dynamic> json) {
    return GalleryMediaModel(
      id: json['id']?.toString() ?? '',
      contentType: json['contentType']?.toString() ?? '',
      fileName: json['fileName']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  GalleryMedia toEntity() {
    return GalleryMedia(
      id: id,
      contentType: contentType,
      fileName: fileName,
      createdAt: createdAt,
    );
  }
}
