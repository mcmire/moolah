function drawGraph(options) {
  if (!options.data || options.data.length == 0) return;
  var firstDate = new Date(options.data[0][0]);
  var minDate = new Date(firstDate.getFullYear(), firstDate.getMonth(), 1);
  $('#graph').html("");
  $.jqplot('graph', [options.data], {
    axes: {
      xaxis: {
        renderer: $.jqplot.DateAxisRenderer,
        rendererOptions: { tickRenderer: $.jqplot.CanvasAxisTickRenderer },
        tickOptions: {
          formatString: "%m/%d/%y",
          angle: -30,
          // not working??
          tickInterval: "1 month",
          min: minDate
        }
      },
      yaxis: {
        autoscale: true,
        rendererOptions: { tickRenderer: $.jqplot.CanvasAxisTickRenderer },
        tickOptions: {
          formatter: $.jqplot.CurrencyTickFormatter
        },
        tickInterval: 1500,
        min: 0
      }
    },
    series: [{
      label: options.title,
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
  })
}