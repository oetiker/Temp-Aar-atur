/// Calculates nice numbers for [TimeDateNiceConv].
Map<String, dynamic> linearNiceDates(
  DateTime min,
  DateTime max,
  num? width,
  num? firstDayOfWeekIndex,
) {
  return _rrdToolDates(
    min,
    max,
    width,
    firstDayOfWeekIndex,
  );
}

enum Iv {
  second,
  minute,
  hour,
  day,
  week,
  month,
  year,
}

enum GridCfg {
  g000(
    minSec: 0,
    length: 0,
    gridIv: Iv.second,
    gridSt: 1,
    mGridIv: Iv.second,
    mGridSt: 5,
    labIv: Iv.second,
    labSt: 1,
    precis: 0,
    fmt: "HH:mm:ss",
  ),
  g001(
    minSec: 0,
    length: 0,
    gridIv: Iv.second,
    gridSt: 1,
    mGridIv: Iv.second,
    mGridSt: 5,
    labIv: Iv.second,
    labSt: 1,
    precis: 0,
    fmt: "HH:mm:ss",
  ),
  g002(
    minSec: 0.015,
    length: 0,
    gridIv: Iv.second,
    gridSt: 1,
    mGridIv: Iv.second,
    mGridSt: 5,
    labIv: Iv.second,
    labSt: 5,
    precis: 0,
    fmt: "HH:mm:ss",
  ),
  g003(
    minSec: 0.08,
    length: 0,
    gridIv: Iv.second,
    gridSt: 1,
    mGridIv: Iv.second,
    mGridSt: 5,
    labIv: Iv.second,
    labSt: 10,
    precis: 0,
    fmt: "HH:mm:ss",
  ),
  g004(
    minSec: 0.15,
    length: 0,
    gridIv: Iv.second,
    gridSt: 5,
    mGridIv: Iv.second,
    mGridSt: 15,
    labIv: Iv.second,
    labSt: 30,
    precis: 0,
    fmt: "HH:mm:ss",
  ),
  g005(
    minSec: 0.4,
    length: 0,
    gridIv: Iv.second,
    gridSt: 10,
    mGridIv: Iv.minute,
    mGridSt: 1,
    labIv: Iv.minute,
    labSt: 1,
    precis: 0,
    fmt: "HH:mm",
  ),
  g006(
    minSec: 0.7,
    length: 0,
    gridIv: Iv.second,
    gridSt: 20,
    mGridIv: Iv.minute,
    mGridSt: 1,
    labIv: Iv.minute,
    labSt: 1,
    precis: 0,
    fmt: "HH:mm",
  ),
  g007(
    minSec: 1,
    length: 0,
    gridIv: Iv.second,
    gridSt: 30,
    mGridIv: Iv.minute,
    mGridSt: 1,
    labIv: Iv.minute,
    labSt: 2,
    precis: 0,
    fmt: "HH:mm",
  ),
  g008(
    minSec: 2,
    length: 0,
    gridIv: Iv.minute,
    gridSt: 1,
    mGridIv: Iv.minute,
    mGridSt: 5,
    labIv: Iv.minute,
    labSt: 5,
    precis: 0,
    fmt: "HH:mm",
  ),
  g009(
    minSec: 5,
    length: 0,
    gridIv: Iv.minute,
    gridSt: 2,
    mGridIv: Iv.minute,
    mGridSt: 10,
    labIv: Iv.minute,
    labSt: 10,
    precis: 0,
    fmt: "HH:mm",
  ),
  g010(
    minSec: 10,
    length: 0,
    gridIv: Iv.minute,
    gridSt: 5,
    mGridIv: Iv.minute,
    mGridSt: 20,
    labIv: Iv.minute,
    labSt: 20,
    precis: 0,
    fmt: "HH:mm",
  ),
  g011(
    minSec: 30,
    length: 0,
    gridIv: Iv.minute,
    gridSt: 10,
    mGridIv: Iv.minute,
    mGridSt: 30,
    labIv: Iv.hour,
    labSt: 1,
    precis: 0,
    fmt: "HH:mm",
  ),
  g012(
    minSec: 60,
    length: 0,
    gridIv: Iv.minute,
    gridSt: 30,
    mGridIv: Iv.hour,
    mGridSt: 1,
    labIv: Iv.hour,
    labSt: 2,
    precis: 0,
    fmt: "HH:mm",
  ),
  g013(
    minSec: 60,
    length: 24 * 3600,
    gridIv: Iv.minute,
    gridSt: 30,
    mGridIv: Iv.hour,
    mGridSt: 1,
    labIv: Iv.hour,
    labSt: 3,
    precis: 0,
    fmt: "EEE HH:mm",
  ),
  g014(
    minSec: 140,
    length: 0,
    gridIv: Iv.hour,
    gridSt: 1,
    mGridIv: Iv.hour,
    mGridSt: 2,
    labIv: Iv.hour,
    labSt: 4,
    precis: 0,
    fmt: "EEE HH:mm",
  ),
  g015(
    minSec: 180,
    length: 0,
    gridIv: Iv.hour,
    gridSt: 1,
    mGridIv: Iv.hour,
    mGridSt: 3,
    labIv: Iv.hour,
    labSt: 6,
    precis: 0,
    fmt: "EEE HH:mm",
  ),
  g016(
    minSec: 300,
    length: 0,
    gridIv: Iv.hour,
    gridSt: 2,
    mGridIv: Iv.hour,
    mGridSt: 6,
    labIv: Iv.hour,
    labSt: 12,
    precis: 0,
    fmt: "EEE HH:mm",
  ),
  g017(
    minSec: 600,
    length: 0,
    gridIv: Iv.hour,
    gridSt: 6,
    mGridIv: Iv.day,
    mGridSt: 1,
    labIv: Iv.day,
    labSt: 1,
    precis: 24 * 3600,
    fmt: "EEE d MMM",
  ),
  g018(
    minSec: 1200,
    length: 0,
    gridIv: Iv.hour,
    gridSt: 6,
    mGridIv: Iv.day,
    mGridSt: 1,
    labIv: Iv.day,
    labSt: 1,
    precis: 24 * 3600,
    fmt: "d MMM",
  ),
  g019(
    minSec: 1800,
    length: 0,
    gridIv: Iv.hour,
    gridSt: 12,
    mGridIv: Iv.day,
    mGridSt: 1,
    labIv: Iv.day,
    labSt: 2,
    precis: 24 * 3600,
    fmt: "EEE d MMM",
  ),
  g020(
    minSec: 2400,
    length: 0,
    gridIv: Iv.hour,
    gridSt: 12,
    mGridIv: Iv.day,
    mGridSt: 1,
    labIv: Iv.day,
    labSt: 2,
    precis: 24 * 3600,
    fmt: "d MMM",
  ),
  g021(
    minSec: 3600,
    length: 0,
    gridIv: Iv.day,
    gridSt: 1,
    mGridIv: Iv.week,
    mGridSt: 1,
    labIv: Iv.week,
    labSt: 1,
    precis: 7 * 24 * 3600,
    fmt: "WEEK_NUMBER_FORMAT",
  ),
  g022(
    minSec: 12000,
    length: 0,
    gridIv: Iv.day,
    gridSt: 1,
    mGridIv: Iv.month,
    mGridSt: 1,
    labIv: Iv.month,
    labSt: 1,
    precis: 30 * 24 * 3600,
    fmt: "MMMM y",
  ),
  g023(
    minSec: 18000,
    length: 0,
    gridIv: Iv.day,
    gridSt: 2,
    mGridIv: Iv.month,
    mGridSt: 1,
    labIv: Iv.month,
    labSt: 1,
    precis: 30 * 24 * 3600,
    fmt: "MMMM y",
  ),
  g024(
    minSec: 23000,
    length: 0,
    gridIv: Iv.week,
    gridSt: 1,
    mGridIv: Iv.month,
    mGridSt: 1,
    labIv: Iv.month,
    labSt: 1,
    precis: 30 * 24 * 3600,
    fmt: "MMM y",
  ),
  g025(
    minSec: 32000,
    length: 0,
    gridIv: Iv.week,
    gridSt: 1,
    mGridIv: Iv.month,
    mGridSt: 1,
    labIv: Iv.month,
    labSt: 1,
    precis: 30 * 24 * 3600,
    fmt: "MMM 'yy",
  ),
  g026(
    minSec: 42000,
    length: 0,
    gridIv: Iv.week,
    gridSt: 1,
    mGridIv: Iv.month,
    mGridSt: 1,
    labIv: Iv.month,
    labSt: 2,
    precis: 30 * 24 * 3600,
    fmt: "MMMM y",
  ),
  g027(
    minSec: 52000,
    length: 0,
    gridIv: Iv.week,
    gridSt: 1,
    mGridIv: Iv.month,
    mGridSt: 1,
    labIv: Iv.month,
    labSt: 2,
    precis: 30 * 24 * 3600,
    fmt: "MMM y",
  ),
  g028(
    minSec: 78000,
    length: 0,
    gridIv: Iv.week,
    gridSt: 1,
    mGridIv: Iv.month,
    mGridSt: 1,
    labIv: Iv.month,
    labSt: 2,
    precis: 30 * 24 * 3600,
    fmt: "MMM 'yy",
  ),
  g029(
    minSec: 84000,
    length: 0,
    gridIv: Iv.week,
    gridSt: 2,
    mGridIv: Iv.month,
    mGridSt: 1,
    labIv: Iv.month,
    labSt: 3,
    precis: 30 * 24 * 3600,
    fmt: "MMMM y",
  ),
  g030(
    minSec: 94000,
    length: 0,
    gridIv: Iv.week,
    gridSt: 2,
    mGridIv: Iv.month,
    mGridSt: 1,
    labIv: Iv.month,
    labSt: 3,
    precis: 30 * 24 * 3600,
    fmt: "MMM y",
  ),
  g031(
    minSec: 120000,
    length: 0,
    gridIv: Iv.week,
    gridSt: 2,
    mGridIv: Iv.month,
    mGridSt: 1,
    labIv: Iv.month,
    labSt: 3,
    precis: 30 * 24 * 3600,
    fmt: "MMM 'yy",
  ),
  g032(
    minSec: 130000,
    length: 0,
    gridIv: Iv.month,
    gridSt: 1,
    mGridIv: Iv.month,
    mGridSt: 2,
    labIv: Iv.month,
    labSt: 4,
    precis: 0,
    fmt: "yyyy-MM-dd",
  ),
  g033(
    minSec: 142000,
    length: 0,
    gridIv: Iv.month,
    gridSt: 1,
    mGridIv: Iv.month,
    mGridSt: 3,
    labIv: Iv.month,
    labSt: 6,
    precis: 0,
    fmt: "yyyy-MM-dd",
  ),
  g034(
    minSec: 220000,
    length: 0,
    gridIv: Iv.month,
    gridSt: 1,
    mGridIv: Iv.month,
    mGridSt: 6,
    labIv: Iv.month,
    labSt: 12,
    precis: 0,
    fmt: "yyyy-MM-dd",
  ),
  g035(
    minSec: 400000,
    length: 0,
    gridIv: Iv.month,
    gridSt: 2,
    mGridIv: Iv.month,
    mGridSt: 12,
    labIv: Iv.month,
    labSt: 12,
    precis: 365 * 24 * 3600,
    fmt: "%Y",
  ),
  g036(
    minSec: 800000,
    length: 0,
    gridIv: Iv.month,
    gridSt: 4,
    mGridIv: Iv.month,
    mGridSt: 12,
    labIv: Iv.month,
    labSt: 24,
    precis: 365 * 24 * 3600,
    fmt: "%Y",
  ),
  g037(
    minSec: 2000000,
    length: 0,
    gridIv: Iv.month,
    gridSt: 6,
    mGridIv: Iv.month,
    mGridSt: 12,
    labIv: Iv.month,
    labSt: 24,
    precis: 31536000,
    fmt: "'%g",
  ),
  ;

  const GridCfg({
    required this.minSec, //  minimum sec per pix
    required this.length, // number of secs on the image
    required this.gridIv, // grid interval in what ?
    required this.gridSt, // how many whats per grid
    required this.mGridIv, // label interval in what ?
    required this.mGridSt, // how many whats per label
    required this.labIv, // label interval in what ?
    required this.labSt, // how many whats per label
    required this.precis, // label precision -> label placement
    required this.fmt, // strftime string
  });

  final double minSec;
  final int length;
  final Iv gridIv;
  final int gridSt;
  final Iv mGridIv;
  final int mGridSt;
  final Iv labIv;
  final int labSt;
  final int precis;
  final String fmt;
}

GridCfg _findBaseInterval(
  DateTime min,
  DateTime max,
  num width
) {
    var seconds = (max.millisecondsSinceEpoch - min.millisecondsSinceEpoch).toDouble() / 1e3;
    var factor = seconds / width.toDouble();
    GridCfg selectedGridCfg = GridCfg.g000; // Default to the most granular

    for (var gcfg in GridCfg.values) {
      if (gcfg.minSec > factor) {
        selectedGridCfg = gcfg;
        break;
      }
      selectedGridCfg = gcfg; // Keep track of the last one if no break
    }
    return selectedGridCfg;
}

DateTime _findNextTime(
  DateTime now,
  Iv baseInterval,
  int baseStep,
) {
  int year = now.year;
  int month = now.month;
  int day = now.day;
  int hour = now.hour;
  int minute = now.minute;
  int second = now.second;

  switch (baseInterval) {
    case Iv.second:
      second += baseStep;
      break;
    case Iv.minute:
      minute += baseStep;
      break;
    case Iv.hour:
      hour += baseStep;
      break;
    case Iv.day:
      day += baseStep;
      break;
    case Iv.week:
      day += 7 * baseStep;
      break;
    case Iv.month:
      month += baseStep;
      break;
    case Iv.year:
      year += baseStep;
      break;
  }

  return now.isUtc
      ? DateTime.utc(year, month, day, hour, minute, second)
      : DateTime(year, month, day, hour, minute, second);
}

DateTime _findFirstTime(
  DateTime start,
  Iv baseInterval,
  int baseStep,
  int firstDayOfWeekIndex,
) {
  var second = start.second;
  var minute = start.minute;
  var hour = start.hour;
  var monthDay = start.day;
  var month = start.month;
  var year = start.year;
  var weekDay = start.weekday;

  switch (baseInterval) {
    case Iv.second:
      second -= second % baseStep;
      break;
    case Iv.minute:
      second = 0;
      minute -= minute % baseStep;
      break;
    case Iv.hour:
      second = 0;
      minute = 0;
      hour -= hour % baseStep;
      break;
    case Iv.day:
      /* we do NOT look at the basestep for this ... */
      second = 0;
      minute = 0;
      hour = 0;
      break;
    case Iv.week:
      /* we do NOT look at the basestep for this ... */
      second = 0;
      minute = 0;
      hour = 0;
      monthDay -= weekDay - firstDayOfWeekIndex;
      break;
    case Iv.month:
      second = 0;
      minute = 0;
      hour = 0;
      monthDay = 1;
      month -= month % baseStep;
      break;
    case Iv.year:
      second = 0;
      minute = 0;
      hour = 0;
      monthDay = 1;
      month = 1; // In Dart, month is 1-12
      year -= year % baseStep;
      break;
  }
  return start.isUtc
      ? DateTime.utc(year, month, monthDay, hour, minute, second)
      : DateTime(year, month, monthDay, hour, minute, second);
}

Map<String, dynamic> _rrdToolDates(
    DateTime min,
    DateTime max,
    num? width,
    num? firstDayOfWeekIndex,
) {
  final effectiveWidth = width ?? 400;
  final effectiveFirstDayOfWeek = firstDayOfWeekIndex?.toInt() ?? 1; // Monday

  if (max.isBefore(min)) {
    return {'ticks': [], 'format': ""};
  }

  final gridCfg = _findBaseInterval(min, max, effectiveWidth);

  var currentTick = _findFirstTime(
    min,
    gridCfg.labIv,
    gridCfg.labSt,
    effectiveFirstDayOfWeek,
  );

  final List<DateTime> ticks = [];
  for (int i = 0; i < 200; i++) { // safety break
    ticks.add(currentTick);
    currentTick = _findNextTime(currentTick, gridCfg.labIv, gridCfg.labSt);
    if (currentTick.isAfter(max)) {
      ticks.add(currentTick);
      break;
    }
  }
  // Calculate major ticks for vertical grid lines (time axis) - using mGridIv/mGridSt
  var majorCurrentTick = _findFirstTime(
    min,
    gridCfg.mGridIv,
    gridCfg.mGridSt,
    effectiveFirstDayOfWeek,
  );

  final List<DateTime> majorTicks = [];
  for (int i = 0; i < 1000; i++) { // safety break
    if (majorCurrentTick.isAfter(max)) break;
    if (majorCurrentTick.isAfter(min)) {
      majorTicks.add(majorCurrentTick);
    }
    majorCurrentTick = _findNextTime(majorCurrentTick, gridCfg.mGridIv, gridCfg.mGridSt);
  }

  // Calculate minor ticks for vertical grid lines (time axis) - using gridIv/gridSt
  var minorCurrentTick = _findFirstTime(
    min,
    gridCfg.gridIv,
    gridCfg.gridSt,
    effectiveFirstDayOfWeek,
  );

  final List<DateTime> minorTicks = [];
  for (int i = 0; i < 2000; i++) { // safety break - increased for finer grid
    if (minorCurrentTick.isAfter(max)) break;
    if (minorCurrentTick.isAfter(min)) {
      minorTicks.add(minorCurrentTick);
    }
    minorCurrentTick = _findNextTime(minorCurrentTick, gridCfg.gridIv, gridCfg.gridSt);
  }

  return {
    'ticks': ticks, 
    'format': gridCfg.fmt,
    'majorTicks': majorTicks,
    'minorTicks': minorTicks,
  };
}

// Function to calculate ISO week number
int getWeekNumber(DateTime date) {
  // Add 3 days to the date to ensure that we are in the correct week when
  // the year starts on a Thursday, Friday or Saturday.
  DateTime thursday = date.add(Duration(days: 3 - (date.weekday + 6) % 7));
  // January 4 is always in week 1.
  DateTime week1 = DateTime.utc(thursday.year, 1, 4);
  // Calculate the difference in days and divide by 7 to get the week number.
  return 1 + ((thursday.difference(week1).inDays / 7)).floor();
}

//     _wilkinsonExtended(
//       min,
//       max,
//       n,
//       true,
//       [1, 5, 2, 2.5, 4, 3],
//       [0.25, 0.2, 0.5, 0.05],
//     );


// const _maxLoop = 10000;

// const _esp = 2.220446049250313e-16 * 100;

// num _prettyNumber(num n) =>
//     n.abs() < 1e-15 ? n : double.parse(n.toStringAsFixed(15));

// num _mod(num n, num m) => ((n % m) + m) % m;

// num _round(num n) => (n * 1e12).round() / 1e12;

// num _simplicity(
//   num q,
//   List<num> candidates,
//   int j,
//   num lMin,
//   num lMax,
//   num lStep,
// ) {
//   final n = candidates.length;
//   final i = candidates.indexOf(q);
//   int v = 0;
//   final m = _mod(lMin, lStep);
//   if ((m < _esp || lStep - m < _esp) && lMin <= 0 && lMax >= 0) {
//     v = 1;
//   }
//   return 1 - i / (n - 1) - j + v;
// }

// num _simplicityMax(
//   num q,
//   List<num> candidates,
//   int j,
// ) {
//   final n = candidates.length;
//   final i = candidates.indexOf(q);
//   const v = 1;
//   return 1 - i / (n - 1) - j + v;
// }

// num _density(
//   int k,
//   int m,
//   num min,
//   num max,
//   num lMin,
//   num lMax,
// ) {
//   final r = (k - 1) / (lMax - lMin);
//   final rt = (m - 1) / (dart_math.max(lMax, max) - dart_math.min(min, lMin));
//   return 2 - dart_math.max(r / rt, rt / r);
// }

// num _densityMax(
//   int k,
//   int m,
// ) {
//   if (k >= m) {
//     return 2 - (k - 1) / (m - 1);
//   }
//   return 1;
// }

// num _coverage(
//   num min,
//   num max,
//   num lMin,
//   num lMax,
// ) {
//   final range = max - min;
//   return 1 -
//       (0.5 * (dart_math.pow(max - lMax, 2) + dart_math.pow(min - lMin, 2))) /
//           dart_math.pow(0.1 * range, 2);
// }

// num _coverageMax(
//   num min,
//   num max,
//   num span,
// ) {
//   final range = max - min;
//   if (span > range) {
//     final half = (span - range) / 2;
//     return 1 - dart_math.pow(half, 2) / dart_math.pow(0.1 * range, 2);
//   }
//   return 1;
// }

// num _legibility() => 1;

// List<num> _wilkinsonExtended(
//   num min,
//   num max,
//   int n,
//   bool onlyLoose,
//   List<num> candidates,
//   List<double> w,
// ) {
//   if (min.isNaN || max.isNaN || n <= 0) {
//     return [];
//   }

//   if (max - min < 1e-15 || n == 1) {
//     return [min];
//   }

//   num bestScore = -2;
//   num bestLMin = 0;
//   num bestLMax = 0;
//   num bestLStep = 0;

//   int j = 1;
//   while (j < _maxLoop) {
//     for (var q in candidates) {
//       final sm = _simplicityMax(q, candidates, j);
//       if (w[0] * sm + w[1] + w[2] + w[3] < bestScore) {
//         j = _maxLoop;
//         break;
//       }
//       int k = 2;
//       while (k < _maxLoop) {
//         final dm = _densityMax(k, n);
//         if (w[0] * sm + w[1] + w[2] * dm + w[3] < bestScore) {
//           break;
//         }

//         final delta = (max - min) / (k + 1) / j / q;
//         int z = (dart_math.log(delta) / dart_math.ln10).ceil();

//         while (z < _maxLoop) {
//           final step = j * q * dart_math.pow(10.0, z);
//           final cm = _coverageMax(min, max, (step * (k - 1)));

//           if (w[0] * sm + w[1] * cm + w[2] * dm + w[3] < bestScore) {
//             break;
//           }

//           final minStart = (max / step).floor() * j - (k - 1) * j;
//           final maxStart = (min / step).ceil() * j;

//           if (minStart <= maxStart) {
//             final count = maxStart - minStart;
//             for (var i = 0; i <= count; i++) {
//               final start = minStart + i;
//               final lMin = start * (step / j);
//               final lMax = lMin + step * (k - 1);
//               final lStep = step;

//               final s = _simplicity(q, candidates, j, lMin, lMax, lStep);
//               final c = _coverage(min, max, lMin, lMax);
//               final g = _density(k, n, min, max, lMin, lMax);
//               final l = _legibility();

//               final score = w[0] * s + w[1] * c + w[2] * g + w[3] * l;
//               if (score > bestScore &&
//                   (!onlyLoose || (lMin <= min && lMax >= max))) {
//                 bestLMin = lMin;
//                 bestLMax = lMax;
//                 bestLStep = lStep;
//                 bestScore = score;
//               }
//             }
//           }
//           z += 1;
//         }
//         k += 1;
//       }
//     }
//     j += 1;
//   }

//   final lMin = _prettyNumber(bestLMin);
//   final lMax = _prettyNumber(bestLMax);
//   final lStep = _prettyNumber(bestLStep);

//   final tickCount = _round((lMax - lMin) / lStep).floor() + 1;
//   final ticks = List<num>.filled(tickCount, 0);

//   ticks[0] = _prettyNumber(lMin);
//   for (var i = 1; i < tickCount; i++) {
//     ticks[i] = _prettyNumber(ticks[i - 1] + lStep);
//   }

//   return ticks;
// }