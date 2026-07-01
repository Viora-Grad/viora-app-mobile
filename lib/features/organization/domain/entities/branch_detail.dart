import 'package:equatable/equatable.dart';

class BranchDetail extends Equatable {
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
  final List<BusinessHour> schedule;
  final String timeZone;
  final DateTime openedSinceUtc;
  final List<GalleryMedia> gallery;
  final bool isCurrentlyOpen;

  const BranchDetail({
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

  @override
  List<Object?> get props => [
        id,
        organizationId,
        organizationName,
        services,
        address,
        latitude,
        longitude,
        branchStatus,
        contactEmail,
        phoneNumbers,
        schedule,
        timeZone,
        openedSinceUtc,
        gallery,
        isCurrentlyOpen,
      ];
}

class BusinessHour extends Equatable {
  final int day;
  final String openTime;
  final String closeTime;

  const BusinessHour({
    required this.day,
    required this.openTime,
    required this.closeTime,
  });

  @override
  List<Object?> get props => [day, openTime, closeTime];
}

class GalleryMedia extends Equatable {
  final String id;
  final String contentType;
  final String fileName;
  final DateTime createdAt;

  const GalleryMedia({
    required this.id,
    required this.contentType,
    required this.fileName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, contentType, fileName, createdAt];
}
