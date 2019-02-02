require 'byebug'
require './lib'
require './token'

# A WildcardLISP interpretation built in Ruby
#
# WildcardLISP is a language initially implemented by Hundred Rabbits.
#   https://100r.co/pages/paradise.html
#   https://github.com/hundredrabbits/Paradise
module WildcardLISP
  class Builtins
    def initialize(context)
      @context = context
    end

    def output(*text)
      if text.is_a? Array
        if text.length > 1
          text = execute_all(text)
          text.each do |t|
            output(*t)
          end
        else
          puts execute text.first
        end
      else
        puts text
      end
    end

    # FIXME
    def join(parts)
      parts = execute_all(parts)
      parts = parts.to_a.map(&:to_s)
      parts.join(' ')
    end

    def list(*parts)
      parts = execute_all(parts) if parts.is_a? Array
      parts = parts.to_a
      Lib::Array.new parts
    end

    def hash(*parts)
      parts = execute_all(parts) if parts.is_a? Array
      parts = parts.to_a
      Lib::Hash.new parts
    end

    def add(*args)
      out = 0
      args = to_numbers(execute_all(args))
      args.each do |arg|
        out += if arg.is_a?(Array) && length > 1
                 add(arg)
               elsif arg.is_a? Array
                 arg.first
               else
                 arg
               end
      end
      out
    end

    def sub(a, b)
      a = to_number(a)
      b = to_number(b)
      a - b
    end

    def mult(*args)
      out = 1
      args = to_numbers(execute_all(args))
      args.each do |arg|
        out *= if arg.is_a?(Array) && arg.length > 1
                 mult(arg)
               elsif arg.is_a? Array
                 arg.first
               else
                 arg
               end
      end
      out
    end

    def div(a, b)
      a = to_number(a)
      b = to_number(b)
      a / b
    end

    def let(name, value)
      raise 'must have a valid name' unless name.is_a? ::String

      value = execute value

      @context.variables.push Lib::Variable.new(
        name: name,
        value: value,
        scope: :local
      )
      nil
    end

    def lambda(arguments, body)
      arguments = execute_all [arguments]
      raise 'must have a body' unless body.is_a? Array

      Lib::Lambda.new arguments, body, @context.dup
    end

    def def(name, arguments, body)
      let name,
          [lambda(arguments, body)]
    end

    private

    def to_numbers(args)
      args.map do |arg|
        to_number arg
      end
    end

    def to_number(arg)
      arg = execute [arg] unless arg.is_a?(Numeric)
      if arg.to_i == arg.to_f
        arg.to_i
      else
        arg.to_f
      end
    end

    def execute_all(layers)
      layers.map do |layer|
        if layer.is_a? ::Array
          execute layer
        else
          layer
        end
      end
    end

    def execute(layer)
      executor = TokenExecutor.new(layer.first, layer, @context)
      executor.act
    end

    attr_accessor :context
  end
end
