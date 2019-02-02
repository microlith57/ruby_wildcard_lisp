require 'byebug'
require './lib'
require './token'
require './execution_context'

# A WildcardLISP interpretation built in Ruby
#
# WildcardLISP is a language initially implemented by Hundred Rabbits.
#   https://100r.co/pages/paradise.html
#   https://github.com/hundredrabbits/Paradise
module WildcardLISP
  class TreeExecutor
    @stack = []

    def initialize(tree, context: nil)
      @tree = tree
      @context = context || ExecutionContext.new
    end

    def act
      execute_layer(@tree, @context)
    end

    private

    def execute_layer(layer, context)
      return layer.first if layer.nil? || layer.length <= 1

      executor = TokenExecutor.new(layer.first, layer, context)
      executor.act
    end
  end
end
