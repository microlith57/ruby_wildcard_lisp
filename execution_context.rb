require 'byebug'
require './lib'
require './token'

# A WildcardLISP interpretation built in Ruby
#
# WildcardLISP is a language initially implemented by Hundred Rabbits.
#   https://100r.co/pages/paradise.html
#   https://github.com/hundredrabbits/Paradise
module WildcardLISP
  class ExecutionContext
    def initialize(variables: [], globals: [])
      @variables = variables
      @globals   = globals
    end

    def include?(other)
      @variables.include?(other.to_sym) ||
        @globals.include?(other.to_sym)
    end

    def [](other)
      @variables.detect { |var| var == other.to_sym } ||
        @globals.detect { |var| var == other.to_sym }
    end

    def []=(index, other)
      if @variables.include? other
        @variables[index] = other
      elsif @globals.include? other
        @globals[index] = other
      end
    end

    def dup_in
      ExecutionContext.new(globals: @globals)
    end

    def dup_out
      ExecutionContext.new(globals: @globals)
    end

    attr_accessor :variables, :globals
  end
end
