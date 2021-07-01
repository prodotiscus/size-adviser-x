
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BrandsList {
  final List<String> list;
  BrandsList(this.list);
  factory BrandsList.fromJson(Map<String, dynamic> json) {
    return BrandsList(new List<String>.from(json["listBrands"]));
  }
}

class BrandData {
  final List<Standard> standards;
  final String defaultStandard;

  BrandData(this.standards, this.defaultStandard);
  factory BrandData.fromJson(Map<String, dynamic> json) {
    List<Standard> list_of_standards = [];
    for (var el in json["standards"]) {
      list_of_standards.add(Standard.fromJson(el));
    }
    return BrandData(
      list_of_standards,
      json["defaultStandard"]
    );
  }
}

class Standard {
  final String name;
  final List<String> sizes;

  Standard(this.name, this.sizes);
  factory Standard.fromJson(Map<String, dynamic> json) {
    return Standard(json["standard"], new List<String>.from(json["sizes"]));
  }
}

class Recommendation {
  final String standard;
  final String value;

  Recommendation(this.standard, this.value);
  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(json["standard"], json["value"]);
  }
}


class RecommendedSize {
  final List<Recommendation> recommendations;
  
  RecommendedSize(this.recommendations);
  factory RecommendedSize.fromJson(Map<String, dynamic> json) {
    List<Recommendation> l = [];
    for (var el in json["recommendations"]) {
      l.add(Recommendation.fromJson(el))
    }
    return RecommendedSize(l);
  }
}


class BoundFittingData {
  final BrandsList brandsList;
  final BrandData brandData;
  final RecommendedSize recommendation;
  
  BoundFittingData(this.brandsList, this.brandData, this.recommendation);
  factory BoundFittingData.fromJson(Map<String, dynamic> json) {
    return BoundFittingData(
        BrandsList.fromJson(json["get_brands"]),
        BrandData.fromJson(json["get_brand_data"]),
        RecommendedSize.fromJson(json["recommendation"])
    );
  }
}

class SizeAdviserApi {
  var user = FirebaseAuth.instance.currentUser!;
  final saPrefix = "size-adviser.com";
  final firebaseSuffix = "firebase";
  final mobileSuffix = "mobile";

  SizeAdviserApi();

  String getUserGender (SharedPreferences sharedPreferences) {
    String userGender = sharedPreferences.getString("profile_gender").toString();
    if (userGender == "null") {
      userGender = "0";
    }
    return userGender;
  }

  void registerCurrentUser (SharedPreferences sharedPreferences, {int times = 1, bool update = false} ) async {
    String userGender = getUserGender(sharedPreferences);
    var queryArgs = {
      'firebase_uid': this.user.uid,
      'user_email': this.user.email,
      'user_name': this.user.displayName,
      'user_gender': userGender
    };
    if (update) {
      queryArgs["rewrite"] = "1";
    }

    var rcuResp = await http.get(Uri.https(saPrefix, firebaseSuffix + "/register_new_account", queryArgs));
    if (rcuResp.statusCode != 200 && times < 3) {
      times ++;
      registerCurrentUser(sharedPreferences, times: times);
    }

  }

  void boundLoadFittingData (SharedPreferences sharedPreferences, String? brand, Function(BoundFittingData) lbd) async {
    if (brand == null) {
      var resp = await http.get(Uri.https(saPrefix, mobileSuffix + "/random_brand", {"gender_int": getUserGender(sharedPreferences)}));
      boundLoadFittingData(sharedPreferences, json.decode(resp.body)["brand"], lbd);
    }

    var boundLoadArgs = {
      'user_gender': getUserGender(sharedPreferences),
      'brand': brand,
      'user_id': this.user.uid
    };

    var blaResp = await http.get(Uri.https(saPrefix, mobileSuffix + "/bound_load", boundLoadArgs));
    var bfd = BoundFittingData.fromJson(json.decode(blaResp.body));
    print(bfd);
  }
}