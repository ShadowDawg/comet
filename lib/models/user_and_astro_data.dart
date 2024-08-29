// import 'package:test1/models/astro_data.dart';
// import 'package:test1/models/user.dart';

// class UserAndAstroData {
//   final userModel user;
//   AstroDataModel astroData;

//   UserAndAstroData({required this.user, required this.astroData});

  // factory UserAndAstroData.fromFirestore(Map<String, dynamic> data) {
  //   return UserAndAstroData(
  //     user: userModel.fromJson(data['user'] ?? {}),
  //     astroData: AstroDataModel.fromJson(data['astroData'] ?? {}),
  //   );
  // }

//   Map<String, dynamic> toJson() {
//     return {
//       'user': user.toJson(),
//       'astroData': astroData.toJson(),
//     };
//   }

//   UserAndAstroData copyWith({
//     userModel? user,
//     AstroDataModel? astroData,
//   }) {
//     return UserAndAstroData(
//       user: user ?? this.user,
//       astroData: astroData ?? this.astroData,
//     );
//   }
// }
