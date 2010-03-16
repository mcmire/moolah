module HamlFilters
  # Surrounds the filtered text with `<style>` and CDATA tags.
  # Useful for including inline styles.
  module Style
    include Haml::Filters::Base
    def render_with_options(text, options)
      <<END
<style type=#{options[:attr_wrapper]}text/css#{options[:attr_wrapper]}>
//<![CDATA[
  #{text.rstrip.gsub("\n", "\n    ")}
//]]>
</script>
END
    end
  end
end