function drawGraph(options) {
  //if (!options.data || !options.data.length == 0) return;
  $('#graph').html("");
  $.jqplot('graph', [options.data], {
    axes: {
      xaxis: {
        ticks: options.xlabels,
        renderer: $.jqplot.CategoryAxisRenderer,
        rendererOptions: {
          tickRenderer: $.jqplot.CanvasAxisTickRenderer
        },
        tickOptions: {
          angle: -30,
          fontSize: '8pt',
          fontFamily: "Helvetica Neue, Arial",
          enableFontSupport: true,
          textColor: "#333"
        }
      },
      yaxis: {
        tickInterval: 500,
        //min: 0,
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
        }
      }
    },
    series: [{
      label: options.title,
      lineWidth: 2,
      showMarker: false,
      renderer: $.jqplot.BarRenderer,
      rendererOptions: {barPadding: 8, barMargin: 20},
      fillToZero: true,
      /* BUG? The offset, alpha, and depth are not being honored for bar charts */
      shadowAngle: 30, 
      shadowOffset: 5,
      shadowDepth: 1,
      shadowAlpha: 0.15
    }],
    /*
    cursor: {
      show: false,
      showCursorLegend: true
    },*/
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