import 'package:flutter/material.dart';

enum RoomFeatureKey {
  kingBedPremium,
  largeWindows,
  lightingScenes,
  loungeChair,
  workDesk,
  walkInShower,
  nespresso,
  blackoutCurtains,
  queenBed,
  sofa,
  balcony,
  wardrobe,
  table,
  bath,
  mirror,
  city,
  wc,
  panorama,
  safe,
  tv,
  shower
}

class RoomFeatureDescriptor {
  RoomFeatureDescriptor({required this.icon, required this.label});
  final String icon;
  final String label;
}

RoomFeatureDescriptor featureDescriptor(RoomFeatureKey key) {
  switch (key) {
    case RoomFeatureKey.kingBedPremium:
      return RoomFeatureDescriptor(
        icon: 'assets/images/rooms/page/bed.png',
        label: 'King-size bed with high-quality mattress and layered bedding',
      );
    case RoomFeatureKey.shower:
      return RoomFeatureDescriptor(
        icon: 'assets/images/rooms/page/shower.png',
        label: 'Large bathroom with twin sinks and walk-in rain shower  ',
      );
    case RoomFeatureKey.tv:
      return RoomFeatureDescriptor(
        icon: 'assets/images/rooms/page/tv.png',
        label: 'Wall-mounted Smart TV opposite the bed ',
      );
    case RoomFeatureKey.safe:
      return RoomFeatureDescriptor(
        icon: 'assets/images/rooms/page/safe.png',
        label: 'Secure internal staircase with optional safety gate',
      );
    case RoomFeatureKey.panorama:
      return RoomFeatureDescriptor(
        icon: 'assets/images/rooms/page/panorama.png',
        label: 'Panoramic windows on two sides for natural light  ',
      );
    case RoomFeatureKey.table:
      return RoomFeatureDescriptor(
        icon: 'assets/images/rooms/page/table.png',
        label: 'Dining or meeting table for up to 4 people',
      );
    case RoomFeatureKey.wc:
      return RoomFeatureDescriptor(
        icon: 'assets/images/rooms/page/wc.png',
        label: 'Additional guest restroom in selected layouts',
      );
    case RoomFeatureKey.city:
      return RoomFeatureDescriptor(
        icon: 'assets/images/rooms/page/city.png',
        label: 'Large window with street or courtyard view',
      );
    case RoomFeatureKey.largeWindows:
      return RoomFeatureDescriptor(
        icon: 'assets/images/rooms/page/city.png',
        label: 'Large windows with city or courtyard view ',
      );
    case RoomFeatureKey.lightingScenes:
      return RoomFeatureDescriptor(
        icon: 'assets/images/rooms/page/temp.png',
        label: 'Adjustable warm/cool lighting scenes  ',
      );
    case RoomFeatureKey.loungeChair:
      return RoomFeatureDescriptor(
        icon: 'assets/images/rooms/page/health.png',
        label: 'Lounge chair with side table for reading or evening drinks ',
      );
    case RoomFeatureKey.workDesk:
      return RoomFeatureDescriptor(
        icon: 'assets/images/rooms/page/desk.png',
        label: 'Work desk with power outlets and USB sockets  ',
      );
    case RoomFeatureKey.walkInShower:
      return RoomFeatureDescriptor(
        icon: 'assets/images/rooms/page/shower.png',
        label: 'Spacious bathroom with walk-in rain shower ',
      );
    case RoomFeatureKey.nespresso:
      return RoomFeatureDescriptor(
        icon: 'assets/images/rooms/page/coffe.png',
        label: 'Nespresso machine and tea-making set',
      );
    case RoomFeatureKey.blackoutCurtains:
      return RoomFeatureDescriptor(
        icon: 'assets/images/rooms/page/curtains.png',
        label: 'Blackout curtains for undisturbed sleep',
      );
    case RoomFeatureKey.queenBed:
      return RoomFeatureDescriptor(
        icon: 'assets/images/rooms/page/bed.png',
        label: 'Queen-size bed with soft headboard and premium linens ',
      );
    case RoomFeatureKey.sofa:
      return RoomFeatureDescriptor(
        icon: 'assets/images/rooms/page/sofa.png',
        label: 'Semi-separated sitting area with sofa or armchairs',
      );
    case RoomFeatureKey.balcony:
      return RoomFeatureDescriptor(
        icon: 'assets/images/rooms/page/balcony.png',
        label: 'Private balcony or French balcony (depending on floor) ',
      );
    case RoomFeatureKey.wardrobe:
      return RoomFeatureDescriptor(
        icon: 'assets/images/rooms/page/bed.png',
        label: 'Queen-size bed with soft headboard and premium linens ',
      );
    case RoomFeatureKey.bath:
      return RoomFeatureDescriptor(
        icon: 'assets/images/rooms/page/bath.png',
        label: 'Marble bathroom with tub',
      );
    case RoomFeatureKey.mirror:
      return RoomFeatureDescriptor(
        icon: 'assets/images/rooms/page/mirror.png',
        label: 'Full-length mirror and dressing area',
      );
  }
}

RoomFeatureKey? featureKeyFromString(String value) {
  switch (value) {
    case 'king_bed_premium':
      return RoomFeatureKey.kingBedPremium;
    case 'large_windows':
      return RoomFeatureKey.largeWindows;
    case 'lighting_scenes':
      return RoomFeatureKey.lightingScenes;
    case 'lounge_chair':
      return RoomFeatureKey.loungeChair;
    case 'work_desk':
      return RoomFeatureKey.workDesk;
    case 'walk_in_shower':
      return RoomFeatureKey.walkInShower;
    case 'nespresso':
      return RoomFeatureKey.nespresso;
    case 'blackout_curtains':
      return RoomFeatureKey.blackoutCurtains;
    case 'queenBed':
      return RoomFeatureKey.queenBed;
    case 'sofa':
      return RoomFeatureKey.sofa;
    case 'balcony':
      return RoomFeatureKey.balcony;
    case 'wardrobe':
      return RoomFeatureKey.wardrobe;
    case 'bath':
      return RoomFeatureKey.bath;
    case 'mirror':
      return RoomFeatureKey.mirror;
    case 'city':
      return RoomFeatureKey.city;
    case 'wc':
      return RoomFeatureKey.wc;
    case 'table':
      return RoomFeatureKey.table;
    case 'panorama':
      return RoomFeatureKey.panorama;
    case 'safe':
      return RoomFeatureKey.safe;
    case 'tv':
      return RoomFeatureKey.tv;
    case 'shower':
      return RoomFeatureKey.shower;
    default:
      return null;
  }
}
