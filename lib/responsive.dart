class ResponsiveCollection {
  double screenWidth;
  double screenHeight;
  String? screenType = null;
  String assignForUnknown = "Type1";

  ResponsiveCollection (this.screenWidth, this.screenHeight) {
    if (screenWidth >= 400 && screenHeight >= 860) {
      screenType = "Type1";
    }
    else if (screenHeight < 860) {
      screenType = "Type2";
    }
  }
}