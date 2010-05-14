require 'spec/runner/formatter/base_text_formatter'

class FeaturesFormatter < Spec::Runner::Formatter::BaseTextFormatter
  INDENT = '  '

  def initialize(options, where)
    super
    @last_nested_descriptions_with_stories = []
  end

  def example_group_started(example_group)
    super

    output.puts
    num_descriptions = example_group.nested_descriptions_with_stories.size
    example_group.nested_descriptions_with_stories.each_with_index do |(nested_description, story_lines), i|
      unless example_group.nested_descriptions_with_stories[0..i] == @last_nested_descriptions_with_stories[0..i]
        output.puts "#{INDENT * i}#{nested_description}"
      end
      if i == num_descriptions-1 && story_lines  # last group
        for line in story_lines
          output.puts "#{INDENT * (i+1)}#{line}\n"
        end
        output.puts
      end
    end

    @last_nested_descriptions_with_stories = example_group.nested_descriptions_with_stories
  end

  def example_failed(example, counter, failure)
    output.puts(red("#{current_indentation}#{example.description} (FAILED - #{counter})"))
    output.flush
  end

  def example_passed(example)
    message = "#{current_indentation}#{example.description}"
    output.puts green(message)
    output.flush
  end

  def example_pending(example, message, deprecated_pending_location=nil)
    super
    output.puts yellow("#{current_indentation}#{example.description} (PENDING: #{message})")
    output.flush
  end

  def current_indentation
    INDENT * @last_nested_descriptions_with_stories.length
  end
end