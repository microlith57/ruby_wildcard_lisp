require 'byebug'
require './lib'
require './builtins'

# A WildcardLISP interpretation built in Ruby
#
# WildcardLISP is a language initially implemented by Hundred Rabbits.
#   https://100r.co/pages/paradise.html
#   https://github.com/hundredrabbits/Paradise
module WildcardLISP
  class TokenList
    def initialize(input)
      @tokens = separate_out_strings input
      @tokens = separate_by_spaces_and_parens @tokens
      @tokens = tokenise_numbers @tokens
    end

    def to_a
      @tokens
    end

    private

    ##
    # Separate an input string into +Lib::String+s and strings
    def separate_out_strings(input)
      output = []
      current_quote_type = nil

      (0...input.length).each do |i|
        # Find the current character
        char = input[i]

        # Is the previous character a '\'?
        is_escaped = i >= 1 && input[i - 1] == '\\'

        # Start / end +Lib::String+s
        unless is_escaped
          if current_quote_type.nil? && ['"', "'"].include?(char)
            current_quote_type = char
            output.push Lib::String.new
            next
          elsif current_quote_type == char
            current_quote_type = nil
            next
          end
        end

        # Add current +char+ to +output+
        if output.empty?
          output.push char
        elsif output.last.is_a?(Lib::String) && current_quote_type.nil?
          output.push char
        else
          output.last.concat char
        end
      end

      output
    end

    ##
    # Separate tokens by spaces and parentheses
    def separate_by_spaces_and_parens(input)
      output = []
      input.each do |token|
        unless token.is_a? ::String
          output.push token
          next
        end
        token = token.gsub '(', ' ( '
        token = token.gsub ')', ' ) '
        token = token.split(' ')
        output += token
      end
      output
    end

    ##
    # Convert unconverted +tokens+ (represented as +::String+s) to numbers where possible
    def tokenise_numbers(tokens)
      output = []
      tokens.each do |token|
        if token.is_a?(::String) && Lib::NUMBER_REGEX =~ token
          output.push Lib::Number.new token
        else
          output.push token
        end
      end
      output
    end
  end

  class TokenExecutor
    def initialize(token, other_tokens, context)
      @token = token
      @others = other_tokens.slice(1..-1)
      @context = context
    end

    def act
      return @token if @token.is_a?(Lib::String) ||
                       @token.is_a?(Lib::Number) ||
                       @token.is_a?(Lib::Lambda) ||
                       @token.nil?

      output = nil
      if @context.include? @token
        output = @context[@token].act(@others, @context)
      else
        builtins = Builtins.new @context

        if builtins.respond_to? @token
          output = builtins.method(@token.to_sym).call(*@others)
        else
          raise "No such wildcard #{@token}"
        end
      end
      output
    end
  end
end
