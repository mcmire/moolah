module HamlInitializer
  module HamlFilters
    # Surrounds the filtered text with `<script>` and CDATA tags.
    # Useful for including inline Javascript.
    module Style
      include Haml::Filters::Base

      # @see Base#render_with_options
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
  
  def self.registered(app)
    Haml::Filters.class_eval { include HamlFilters }
  end
end