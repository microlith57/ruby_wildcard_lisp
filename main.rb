#!/usr/bin/env ruby

require 'byebug'
require './lib'
require './token'
require './token_tree'
require './tree_executor'
require './execution_context'

# A WildcardLISP interpretation built in Ruby
#
# WildcardLISP is a language initially implemented by Hundred Rabbits.
#   https://100r.co/pages/paradise.html
#   https://github.com/hundredrabbits/Paradise
module WildcardLISP
  ##
  # A WildcardLISP interpreter
  class Interpreter
    ##
    # Interpret a line of code
    def interpret(input, context)
      tokens = TokenList.new(input).to_a
      tree = TokenTree.new tokens

      executor = TreeExecutor.new tree, context
      executor.act
    end
  end
end

programs = {
  list_join: 'output (join (list "Hello" "There"))',
  five: 'output (add 2 3)',
  seven: 'output (sub 10 3)',
  ten: 'output (mult 2 5)',
  three: 'output (div 9 3)',
  variable_set: 'let x (add 3 2)',
  variable_get: 'output (x)',
  lambda_set: 'let add_five (lambda x (add x 5))',
  lambda_get: 'output (add_five 7)',
  function_def: 'def sub_ten x (sub x 10)',
  function_call: 'output (sub_ten 15)'
}

context = WildcardLISP::ExecutionContext.new

programs.each do |name, program|
  puts "\n\n#{name}:"
  WildcardLISP::Interpreter.new.interpret(program, context: context)
end
