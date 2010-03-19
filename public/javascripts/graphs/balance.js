$.jqplot.CurrencyTickFormatter = function(format, val) {
  var format = format || "%.2f";
  var absval = $.jqplot.sprintf(format, Math.abs(val));
  if (val < 0) return "-$"+absval;
  else return "$"+absval;
}

function drawGraph(data, title) {
  if (!data || data.length == 0) return;
  var firstDate = new Date(data[0][0]);
  var minDate = new Date(firstDate.getFullYear(), firstDate.getMonth(), 1);
  $('#graph').html("");
  $.jqplot('graph', [data], {
    //title: title,
    axes: {
      xaxis: {
        renderer: $.jqplot.DateAxisRenderer,
        rendererOptions: { tickRenderer: $.jqplot.CanvasAxisTickRenderer },
        tickOptions: {
          formatString: "%m/%d/%y",
          angle: -30
        },
        tickInterval: "1 month",
        min: minDate
      },
      yaxis: {
        autoscale: true,
        rendererOptions: { tickRenderer: $.jqplot.CanvasAxisTickRenderer },
        tickOptions: {
          formatter: $.jqplot.CurrencyTickFormatter
        },
        tickInterval: 500,
        min: 0
      }
    },
    series: [{
      label: title,
      lineWidth: 2,
      showMarker: false
    }], 
    cursor: {  
      showVerticalLine: true,
      showHorizontalLine: false,
      showCursorLegend: true,
      showTooltip: false,
      zoom: true,
      intersectionThreshold: 5,
      cursorLegendFormatString: '%s x: %s, y: %s'
    }
  });
}