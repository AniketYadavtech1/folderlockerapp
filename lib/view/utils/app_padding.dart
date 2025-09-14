import 'package:flutter/widgets.dart';

class AppPaddings {
  static const zero = EdgeInsets.zero;
  static const all2 = EdgeInsets.all(2.0);
  static const all4 = EdgeInsets.all(4.0);
  static const all6 = EdgeInsets.all(6.0);
  static const all7 = EdgeInsets.all(7.0);
  static const all8 = EdgeInsets.all(8.0);
  static const all10 = EdgeInsets.all(10.0);
  static const all16 = EdgeInsets.all(16.0);
  static const all12 = EdgeInsets.all(12.0);
  static const all24 = EdgeInsets.all(24.0);

  static const h4 = EdgeInsets.symmetric(horizontal: 4.0);
  static const h8 = EdgeInsets.symmetric(horizontal: 8.0);
  static const h12 = EdgeInsets.symmetric(horizontal: 12.0);
  static const h16 = EdgeInsets.symmetric(horizontal: 16.0);
  static const h15 = EdgeInsets.symmetric(horizontal: 15.0);

  static const v8 = EdgeInsets.symmetric(vertical: 8.0);
  static const v16 = EdgeInsets.symmetric(vertical: 16.0);

  static const onlyTop16 = EdgeInsets.only(top: 16.0);
  static const onlyTop32Bottom8Left16Right16 = EdgeInsets.only(top: 20.0, bottom: 12, left: 16, right: 16);
  static const onlyTop16Bottom8Left16Right16 = EdgeInsets.only(top: 8.0, bottom: 12, left: 16, right: 16);

  static const onlyBottom16 = EdgeInsets.only(bottom: 16.0);
  static const onlyLeft16 = EdgeInsets.only(left: 16.0);
  static const onlyRight16 = EdgeInsets.only(right: 16.0);
  static const onlyRight8 = EdgeInsets.only(right: 8.0);

  static const h8v16 = EdgeInsets.symmetric(horizontal: 8.0, vertical: 16);
  static const h8v4 = EdgeInsets.symmetric(horizontal: 8.0, vertical: 4);
  static const h12v8 = EdgeInsets.symmetric(horizontal: 12.0, vertical: 8);
  static const h12v4 = EdgeInsets.symmetric(horizontal: 12.0, vertical: 4);
  static const h15v5 = EdgeInsets.symmetric(horizontal: 15.0, vertical: 5);

  static const h12v16 = EdgeInsets.symmetric(horizontal: 12.0, vertical: 16);
  static const h8v12 = EdgeInsets.symmetric(horizontal: 8.0, vertical: 12);
  static const h16v8 = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8);
  static const h4v2 = EdgeInsets.symmetric(horizontal: 4.0, vertical: 2);
  static const h4v10 = EdgeInsets.symmetric(horizontal: 4.0, vertical: 10);

  static const ltrb1612160 = EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0);
}

class AppCorners {
  static const radius4 = BorderRadius.all(Radius.circular(4.0));
  static const radius6 = BorderRadius.all(Radius.circular(6.0));
  static const radius8 = BorderRadius.all(Radius.circular(8.0));
  static const radius12 = BorderRadius.all(Radius.circular(12.0));
  static const radius14 = BorderRadius.all(Radius.circular(14.0));
  static const radius16 = BorderRadius.all(Radius.circular(16.0));
  static const radius18 = BorderRadius.all(Radius.circular(18.0));
  static const radius24 = BorderRadius.all(Radius.circular(24.0));
  static const radius100 = BorderRadius.all(Radius.circular(100.0));

  static const radiusTopLeftRightBottom =
      BorderRadius.only(topLeft: Radius.circular(13), bottomRight: Radius.circular(14));

  static const topRadius12 = BorderRadius.vertical(top: Radius.circular(12.0));
  static const bottomRadius12 = BorderRadius.vertical(bottom: Radius.circular(12.0));

  static const bottomRadius18 = BorderRadius.only(
    bottomLeft: Radius.circular(18.0),
    bottomRight: Radius.circular(18.0),
  );
}

class AppHeights {
  static const h2 = SizedBox(height: 2.0);
  static const h4 = SizedBox(height: 4.0);
  static const h5 = SizedBox(height: 5.0);
  static const h6 = SizedBox(height: 6.0);
  static const h8 = SizedBox(height: 8.0);
  static const h10 = SizedBox(height: 10.0);
  static const h11 = SizedBox(height: 11.0);
  static const h12 = SizedBox(height: 12.0);
  static const h15 = SizedBox(height: 15.0);
  static const h16 = SizedBox(height: 16.0);
  static const h18 = SizedBox(height: 18.0);
  static const h20 = SizedBox(height: 20.0);
  static const h24 = SizedBox(height: 24.0);
  static const h32 = SizedBox(height: 32.0);
  static const h40 = SizedBox(height: 40.0);
  static const h50 = SizedBox(height: 50.0);
  static const h70 = SizedBox(height: 70.0);
  static const h80 = SizedBox(height: 80.0);
}

class AppWidths {
  static const w1 = SizedBox(width: 1.0);
  static const w4 = SizedBox(width: 4.0);
  static const w5 = SizedBox(width: 5.0);
  static const w6 = SizedBox(width: 5.0);
  static const w8 = SizedBox(width: 8.0);
  static const w10 = SizedBox(width: 10.0);
  static const w12 = SizedBox(width: 12.0);
  static const w15 = SizedBox(width: 15.0);
  static const w16 = SizedBox(width: 16.0);
  static const w20 = SizedBox(width: 20.0);
  static const w24 = SizedBox(width: 24.0);
  static const w32 = SizedBox(width: 32.0);
}
