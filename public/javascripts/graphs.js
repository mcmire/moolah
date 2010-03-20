$.jqplot.CurrencyTickFormatter = function(format, val) {
  var format = format || "%.2f";
  var absval = $.jqplot.sprintf(format, Math.abs(val));
  if (val < 0) return "-$"+absval;
  else return "$"+absval;
}