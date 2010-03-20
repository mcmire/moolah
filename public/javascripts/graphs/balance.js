function drawGraph(options) {
  if (!options.data || options.data.length == 0) return;
  var firstDate = new Date(options.data[0][0]);
  var minDate = new Date(firstDate.getFullYear(), firstDate.getMonth(), 1);
  $('#graph').html("");
  $.jqplot('graph', [options.data], {
    axes: {
      xaxis: {
        renderer: $.jqplot.DateAxisRenderer,
        rendererOptions: {
          tickRenderer: $.jqplot.CanvasAxisTickRenderer
        },
        tickOptions: {
          formatString: "%m/%d/%y",
          angle: -30,
          fontSize: '8pt',
          fontFamily: "Helvetica Neue, Arial",
          enableFontSupport: true,
          textColor: "#333",
          // not working??
          tickInterval: "1 month",
          min: minDate
        }
      },
      yaxis: {
        autoscale: true,
        rendererOptions: {
          tickRenderer: $.jqplot.CanvasAxisTickRenderer
        },
        tickOptions: {
          formatter: $.jqplot.CurrencyTickFormatter,
          fontSize: '8pt',
          fontFamily: "Helvetica Neue, Arial",
          enableFontSupport: true,
          textColor: "#333"
        },
        tickInterval: 1500,
        min: 0
      }
    },
    series: [{
      label: options.title,
      lineWidth: 2,
      showMarker: false,
      /* BUG? The offset, alpha, and depth are not being honored for bar charts */
      shadowAngle: 30, 
      shadowOffset: 5,
      shadowDepth: 1,
      shadowAlpha: 0.15
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