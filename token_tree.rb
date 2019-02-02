require 'byebug'
require './lib'

# A WildcardLISP interpretation built in Ruby
#
# WildcardLISP is a language initially implemented by Hundred Rabbits.
#   https://100r.co/pages/paradise.html
#   https://github.com/hundredrabbits/Paradise
module WildcardLISP
  ##
  # A token tree. Allows for easy traversal.
  class TokenTree
    def initialize(tokens)
      @tree = []
      depth = 0

      tokens.each do |token|
        if token == '('
          @tree = add_by_depth(depth, [], @tree)
          depth += 1
        elsif token == ')'
          depth -= 1
        else
          @tree = add_by_depth(depth, token, @tree)
        end
      end
      raise unless depth.zero?
    end

    ##
    # Add a +token+ to the end of the tree, limited by a given +depth+
    def add_by_depth(depth, token, tree = @tree)
      return unless tree.is_a? Array

      if depth.zero?
        tree.push token
      elsif tree.last.is_a? Array
        add_by_depth(depth - 1, token, tree.last)
      else
        tree.push []
        add_by_depth(depth - 1, token, tree.last)
      end

      tree
    end

    def push(token)
      @tree.push token
    end

    def to_a
      @tree
    end

    def to_s
      to_a.to_s
    end

    def length
      (@tree || []).length
    end

    def first
      (@tree || []).first
    end

    def slice(*args)
      if args.length == 1
        @tree.slice(args.first)
      elsif args.length == 2
        @tree.slice(args[0], args[1])
      else
        @tree.slice(args)
      end
    end
  end
end
