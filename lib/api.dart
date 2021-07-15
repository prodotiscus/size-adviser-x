
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:math';

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
      l.add(Recommendation.fromJson(el));
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
        RecommendedSize.fromJson(json["recommended_size"])
    );
  }

  List<String> getRecommendedStandards() {
    List<String> lr = [];
    for (var ssp in this.recommendation.recommendations) {
      lr.add(ssp.standard);
    }
    return lr;
  }

  String? recommendedForStandard(String standard) {
    for (var ssp in this.recommendation.recommendations) {
      if (ssp.standard == standard) {
        return ssp.value;
      }
    }
    return null;
  }

  List<String>? sizeRangeForStandard(String standard) {
    for (var standardObj in this.brandData.standards) {
      if (standardObj.name == standard) {
        return standardObj.sizes;
      }
    }
    return null;
  }

  String defaultStandardForBrand() {
    return this.brandData.defaultStandard;
  }
}

class SizeStandardPair {
  final String size;
  final String standard;

  SizeStandardPair(this.size, this.standard);
  factory SizeStandardPair.fromJson(Map<String, dynamic> json) {
    return SizeStandardPair(json["size"], json["standard"]);
  }
}

class DfgBrand {
  final String brand;
  final List<SizeStandardPair> systemsOfSize;
  final bool triedOn;

  DfgBrand(this.brand, this.systemsOfSize, this.triedOn);
  factory DfgBrand.fromJson(Map<String, dynamic> json) {
    List<SizeStandardPair> l1 = [];
    for (var el in json["systemsOfSize"]) {
      l1.add(SizeStandardPair.fromJson(el));
    }
    return DfgBrand(json["brand"], l1, json["triedOn"]);
  }
}

class CollectionItem {
  final String brand;
  final String date;
  final int fitValue;
  final String fittingID;
  final bool hasPhotos;
  final String size;
  final String standard;

  CollectionItem(this.brand,this.date,this.fitValue,this.fittingID,
      this.hasPhotos, this.size, this.standard);
  factory CollectionItem.fromJson(Map<String, dynamic> json) {
    return CollectionItem(json["brand"], json["date"], json["fit_value"],
        json["fittingID"], json["has_photos"], json["size"], json["standard"]);
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

  Future<BoundFittingData> boundLoadFittingData (SharedPreferences sharedPreferences, String? brand) async {
    if (brand == null) {
      var resp = await http.get(Uri.https(saPrefix, mobileSuffix + "/random_brand", {"gender_int": getUserGender(sharedPreferences)}));
      return boundLoadFittingData(sharedPreferences, json.decode(resp.body)["brand"]);
    }

    var boundLoadArgs = {
      'user_gender': getUserGender(sharedPreferences),
      'brand': brand,
      'user_id': this.user.uid
    };

    var blaResp = await http.get(Uri.https(saPrefix, mobileSuffix + "/bound_load", boundLoadArgs));
    var bfd = BoundFittingData.fromJson(json.decode(blaResp.body));
    return bfd;
  }

  void tryWithSize(String fittingID, String brand, String size,
    String standard, int fitValue) async {

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('HH.mm.ss.dd.MM.yyyy');
    final String formatted = formatter.format(now);

    var respArgs = {
      "user_id": this.user.uid,
      "brand": brand,
      "size": size,
      "system": standard,
      "fit_value": fitValue,
      "date": formatted
    };
    var r = await http.get(Uri.https(saPrefix, mobileSuffix + "/try_with_size", respArgs));
    if (r.statusCode == 200) {
      print("tryWithSize, success");
    } else {
      print("tryWithSize, FAILURE!");
    }
  }

  Future<List<DfgBrand>> getDataForUser(SharedPreferences sharedPreferences) async {
    var args = {
      "user_id": this.user.uid,
      "gender_int": getUserGender(sharedPreferences)
    };
    var r = await http.get(Uri.https(saPrefix, mobileSuffix + "/data_for_gender", args));
    if (r.statusCode == 200) {
      List<DfgBrand> l1 = [];
      for (var el in json.decode(r.body)["data"]) {
        l1.add(DfgBrand.fromJson(el));
      }
      return l1;
    }
    else {
      throw Exception("Failed to init GenderData from server");
    }
  }

  Future<List<CollectionItem>> getCollection(SharedPreferences sharedPreferences) async {
    var q = {
      "user_id": this.user.uid
    };
    var r = await http.get(Uri.https(saPrefix, mobileSuffix + "/get_collection_items", q));
    if (r.statusCode == 200) {
      print(r.body);
      List<CollectionItem> l1 = [];
      for (var el in json.decode(r.body)["items"]) {
        l1.add(CollectionItem.fromJson(el));
      }
      return l1;
    } else {
      throw Exception("Failed to get collection items");
    }
  }

  /* uploadPhoto method not written */

  String getItemPhotoURL(String fittingID, {int index = 0, bool thumbnail = false}) {
    var antiCacheParam = (new Random()).nextInt((pow(10, 8) - pow(10,6)).round()) + pow(10, 6);
    var a2 = "$mobileSuffix/get_images?index=$index&fitting_id=$fittingID&c=$antiCacheParam";
    if (thumbnail) {
      a2 += "&thumbnail=yes";
    }
    return "https://size-adviser.com/$a2";
  }

  List<String> getAllStandards() {
    return ["US", "UK", "RU", "Cm", "EU"];
  }

  void removeFitting(String fittingID) async {
    var q = {
      "user_id": this.user.uid,
      "fitting_id": fittingID
    };
    var r = await http.get(Uri.https(saPrefix, "$mobileSuffix/remove_collection_item", q));
    if (r.statusCode != 200) {
      throw Exception("Fitting object couldn't be removed on the remote server");
    }
  }

  void removePhoto(String fittingID, int photoIndex) async {
    var q = {
      "user_id": this.user.uid,
      "fitting_id": fittingID,
      "photo_index": photoIndex.toString()
    };
    var r = await http.get(Uri.https(saPrefix, "$mobileSuffix/remove_photo_by_index", q));
    if (r.statusCode != 200) {
      throw Exception("Photo couldn't be removed on the remote server");
    }
  }
}
