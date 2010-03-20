function drawGraph(options) {
  //if (!options.data || !options.data.length == 0) return;
  $('#graph').html("");
  $.jqplot('graph', [options.data], {
    axes: {
      xaxis: {
        ticks: options.xlabels,
        renderer: $.jqplot.CategoryAxisRenderer,
        rendererOptions: { tickRenderer: $.jqplot.CanvasAxisTickRenderer }/*,
        tickOptions: {
          angle: -30
        }*/
      },
      yaxis: {
        tickInterval: 500,
        //min: 0,
        autoscale: true,
        rendererOptions: { tickRenderer: $.jqplot.CanvasAxisTickRenderer },
        tickOptions: {
          formatter: $.jqplot.CurrencyTickFormatter
        }
      }
    },
    series: [{
      label: options.title,
      lineWidth: 2,
      showMarker: false,
      renderer: $.jqplot.BarRenderer,
      rendererOptions: {barPadding: 8, barMargin: 20}
    }],
    cursor: {
      show: false,
      showCursorLegend: true
    }
    /*,
    cursor: {  
      showVerticalLine: true,
      showHorizontalLine: false,
      showCursorLegend: true,
      showTooltip: false,
      zoom: true,
      intersectionThreshold: 5,
      cursorLegendFormatString: '%s x: %s, y: %s'
    }*/
  })
}