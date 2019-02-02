#!/usr/bin/env ruby

require 'byebug'

# A WildcardLISP interpretation built in Ruby
#
# WildcardLISP is a language initially implemented by Hundred Rabbits.
#   https://100r.co/pages/paradise.html
#   https://github.com/hundredrabbits/Paradise
module WildcardLISP
  ##
  # A library for various internal representations
  module Lib
    NUMBER_REGEX = /^-?\d*(\.\d+)?$/.freeze

    class String
      def initialize(content = '')
        @content = content
      end

      def concat(other)
        @content.concat other
      end

      def split(separator)
        @content.split separator
      end

      def to_s
        @content
      end

      attr_accessor :content
    end

    class Number < Numeric
      def initialize(string)
        raise unless NUMBER_REGEX =~ string

        @sign = string[0] == '-' ? -1 : 1
        string.delete! '-'

        parts = string.partition '.'

        case parts.length
        when 1
          # Single part (int)
          @num = parts.first.to_i * @sign
        when 2
          # Starts with point (float)
          @num = "0.#{parts.last}".to_f * @sign
        when 3
          # Double part (float)
          @num = "#{parts.first}.#{parts.last}".to_f * @sign
        else
          raise
        end
      end

      def to_s
        @num.to_s
      end

      def to_i
        @num.to_i
      end

      def to_f
        @num.to_f
      end

      def coerce(other)
        [self.class.new(other.to_s), self]
      end

      def <=>(other)
        to_f <=> other.to_f
      end

      def +(other)
        to_f + other.to_f
      end

      def -(other)
        to_f + other.to_f
      end

      def *(other)
        to_f + other.to_f
      end

      def /(other)
        to_f + other.to_f
      end
    end

    class Array < ::Array
    end

    class Hash < ::Hash
    end

    class Variable
      def initialize(name: nil, value: nil, scope: :local)
        @name  = name.to_sym
        @value = value
        @scope = scope
      end

      def act(others, context)
        if @value.respond_to? :act
          @value.act others, context
        else
          @value
        end
      end

      def ==(other)
        if other.is_a? Variable
          other.name == @name &&
            other.value == @value &&
            other.scope == @scope
        else
          other.to_sym == @name
        end
      end
    end

    class Lambda
      def initialize(arguments, tree, context)
        @arguments = arguments.each(&:to_sym)
        @tree      = tree
        @context   = context.dup

        if !(@tree.is_a? ::Array)
          @tree = [@tree]
        elsif @tree.length == 1
          @tree = @tree.first
        end
      end

      # TODO: Implement *args, keyword args
      def act(others, _caller_context)
        context = @context.dup_in
        (0...@arguments.length).each do |index|
          variable = Variable.new(
            name: @arguments[index],
            value: others[index],
            scope: :local
          )
          context.variables += [variable]
        end
        executor = TreeExecutor.new @tree, context: context
        executor.act
      end
    end
  end
end
