my $list = [  [0.0, 0, 'TMT_SECOND', 1, 'TMT_SECOND', 5, 'TMT_SECOND', 1, 0, "%H:%M:%S"]
    ,
    [0.015, 0, 'TMT_SECOND', 1, 'TMT_SECOND', 5, 'TMT_SECOND', 5, 0, "%H:%M:%S"]
    ,
    [0.08, 0, 'TMT_SECOND', 1, 'TMT_SECOND', 5, 'TMT_SECOND','10', 0, "%H:%M:%S"]
    ,
    [0.15, 0, 'TMT_SECOND', 5, 'TMT_SECOND','15', 'TMT_SECOND','30', 0, "%H:%M:%S"]
    ,
    [0.4, 0, 'TMT_SECOND','10', 'TMT_MINUTE', 1, 'TMT_MINUTE', 1, 0, "%H:%M"]
    ,
    [0.7, 0, 'TMT_SECOND','20', 'TMT_MINUTE', 1, 'TMT_MINUTE', 1, 0, "%H:%M"]
    ,
    [1.0, 0, 'TMT_SECOND','30', 'TMT_MINUTE', 1, 'TMT_MINUTE', 2, 0, "%H:%M"]
    ,
    [2.0, 0, 'TMT_MINUTE', 1, 'TMT_MINUTE', 5, 'TMT_MINUTE', 5, 0, "%H:%M"]
    ,
    [5.0, 0, 'TMT_MINUTE', 2, 'TMT_MINUTE','10', 'TMT_MINUTE','10', 0, "%H:%M"]
    ,
    [10.0, 0, 'TMT_MINUTE', 5, 'TMT_MINUTE','20', 'TMT_MINUTE','20', 0, "%H:%M"]
    ,
    [30.0, 0, 'TMT_MINUTE','10', 'TMT_MINUTE','30', 'TMT_HOUR', 1, 0, "%H:%M"]
    ,
    [60.0, 0, 'TMT_MINUTE','30', 'TMT_HOUR', 1, 'TMT_HOUR', 2, 0, "%H:%M"]
    ,
    [60.0,'24 * 3600', 'TMT_MINUTE','30', 'TMT_HOUR', 1, 'TMT_HOUR', 3, 0, "%a %H:%M"]
    ,
    [140.0, 0, 'TMT_HOUR', 1, 'TMT_HOUR', 2, 'TMT_HOUR', 4, 0, "%a %H:%M"]
    ,
    [180.0, 0, 'TMT_HOUR', 1, 'TMT_HOUR', 3, 'TMT_HOUR', 6, 0, "%a %H:%M"]
    ,
    [300.0, 0, 'TMT_HOUR', 2, 'TMT_HOUR', 6, 'TMT_HOUR','12', 0, "%a %H:%M"]
    ,
    [600.0, 0, 'TMT_HOUR', 6, 'TMT_DAY', 1, 'TMT_DAY', 1,'24 * 3600', "%a %d %b"]
    ,
    [1200.0, 0, 'TMT_HOUR', 6, 'TMT_DAY', 1, 'TMT_DAY', 1,'24 * 3600', "%d %b"]
    ,
    [1800.0, 0, 'TMT_HOUR','12', 'TMT_DAY', 1, 'TMT_DAY', 2,'24 * 3600', "%a %d %b"]
    ,
    [2400.0, 0, 'TMT_HOUR','12', 'TMT_DAY', 1, 'TMT_DAY', 2,'24 * 3600', "%d %b"]
    ,
    [3600.0, 0, 'TMT_DAY', 1, 'TMT_WEEK', 1, 'TMT_WEEK', 1,'7 * 24 * 3600', "Week %V"]
    ,
    [12000.0, 0, 'TMT_DAY', 1, 'TMT_MONTH', 1, 'TMT_MONTH', 1,'30 * 24 * 3600',
     "%B %Y"]
    ,
    [18000.0, 0, 'TMT_DAY', 2, 'TMT_MONTH', 1, 'TMT_MONTH', 1,'30 * 24 * 3600',
     "%B %Y"]
    ,
    [23000.0, 0, 'TMT_WEEK', 1, 'TMT_MONTH', 1, 'TMT_MONTH', 1,'30 * 24 * 3600',
     "%b %Y"]
    ,
    [32000.0, 0, 'TMT_WEEK', 1, 'TMT_MONTH', 1, 'TMT_MONTH', 1,'30 * 24 * 3600',
     "%b '%g"]
    ,
    [42000.0, 0, 'TMT_WEEK', 1, 'TMT_MONTH', 1, 'TMT_MONTH', 2,'30 * 24 * 3600',
     "%B %Y"]
    ,
    [52000.0, 0, 'TMT_WEEK', 1, 'TMT_MONTH', 1, 'TMT_MONTH', 2,'30 * 24 * 3600',
     "%b %Y"]
    ,
    [78000.0, 0, 'TMT_WEEK', 1, 'TMT_MONTH', 1, 'TMT_MONTH', 2,'30 * 24 * 3600',
     "%b '%g"]
    ,
    [84000.0, 0, 'TMT_WEEK', 2, 'TMT_MONTH', 1, 'TMT_MONTH', 3,'30 * 24 * 3600',
     "%B %Y"]
    ,
    [94000.0, 0, 'TMT_WEEK', 2, 'TMT_MONTH', 1, 'TMT_MONTH', 3,'30 * 24 * 3600',
     "%b %Y"]
    ,
    [120000.0, 0, 'TMT_WEEK', 2, 'TMT_MONTH', 1, 'TMT_MONTH', 3,'30 * 24 * 3600',
     "%b '%g"]
    ,
    [130000.0, 0, 'TMT_MONTH', 1, 'TMT_MONTH', 2, 'TMT_MONTH', 4, 0, "%Y-%m-%d"]
    ,
    [142000.0, 0, 'TMT_MONTH', 1, 'TMT_MONTH', 3, 'TMT_MONTH', 6, 0, "%Y-%m-%d"]
    ,
    [220000.0, 0, 'TMT_MONTH', 1, 'TMT_MONTH', 6, 'TMT_MONTH','12', 0, "%Y-%m-%d"]
    ,
    [400000.0, 0, 'TMT_MONTH', 2, 'TMT_MONTH','12', 'TMT_MONTH','12','365 * 24 * 3600',
     "%Y"]
    ,
    [800000.0, 0, 'TMT_MONTH', 4, 'TMT_MONTH','12', 'TMT_MONTH','24','365 * 24 * 3600',
     "%Y"]
    ,
    [2000000.0, 0, 'TMT_MONTH', 6, 'TMT_MONTH','12', 'TMT_MONTH','24',
     365 * 24 * 3600, "'%g"]
];

my $key = 'g000';
for my $e (@$list) {
    $key++;
    my @e = @$e;
    map { if (/TMT_(\S+)/) {
        $_ = 'Iv.'.lc($1)
    }} @e;
    
   print <<OUT
   $key(
    minSec: $e[0],
    length: $e[1],
    gridIv: $e[2],
    gridSt: $e[3],
    mGridIv: $e[4],
    mGridSt: $e[5],
    labIv: $e[6],
    labSt: $e[7],
    precis: $e[8],
    fmt: "$e[9]",
  ),
OUT
}