Moolah.helpers do
  def jqplot_javascripts
    javascript_include_tag(
      "vendor/jquery.jqplot.js", 
      "vendor/jqplot.barRenderer.js", 
      "vendor/jqplot.canvasAxisTickRenderer.js", 
      "vendor/jqplot.canvasTextRenderer.js", 
      "vendor/jqplot.categoryAxisRenderer.js",
      "vendor/jqplot.cursor.js",
      "vendor/jqplot.dateAxisRenderer.js"
    )
  end
end