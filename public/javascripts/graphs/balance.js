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
        tickOptions: {
          formatString: "%m/%d/%y",
          angle: -30
        },
        tickInterval: "1 month",
        min: minDate
      },
      yaxis: {
        autoscale: true,
        tickOptions: {formatString: "$%.2f"}
      }
    },
    series: [{
      lineWidth: 2,
      showMarker: false
    }], 
    cursor: {  
      showVerticalLine: true,
      showHorizontalLine: false,
      showCursorLegend: true,
      showTooltip: false,
      zoom: true,
      intersectionThreshold: 5
    }
  });
}