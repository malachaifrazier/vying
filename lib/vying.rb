# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

# Container for constants related to the vying library

module Vying
  
  # Returns the version of this vying codebase.

  def self.version
    v = const_defined?( :VERSION ) ? VERSION : "git master"
    "#{v}"
  end

  # Returns a list of methods defined in extensions.
  #
  # NOTE: JRuby doesn't seem to like it when method_added is redefined
  #       for Module (or Class).  As a result, this method will always
  #       return an empty array in JRuby.  : ((   At least until fixed.

  def self.defined_in_extension
    (@defined_in_ext ||= [])
  end

  # Returns a list of the types of extensions that have been loaded.
  # Currently, only the values :c and :java are returned.

  def self.extension_types
    (@exts || {}).keys
  end

  # Returns a list of the extensions that were loaded for a given type.  
  # Get the extension type from Vying.ext_types.

  def self.extensions( type )
    (@exts || {})[type]
  end

  # Load the given extension.

  def self.load_extension( type, path )
    @exts ||= {}

    # Track what methods are added by the extension.

    Module.class_eval do
      def singleton_method_added( name )
        Vying.defined_in_extension << "#{self}.#{name}"
      end
 
      def method_added( name )
        unless name == :method_added
          Vying.defined_in_extension << "#{self}##{name}"
        end
      end
    end

    begin
      require path
      (@exts[type] ||= []) << path
    rescue LoadError, SyntaxError
      # Well, we tried.  What more can you ask?
    end

    # Stop tracking.

    Module.class_eval do
      def method_added( n ); end
      def singleton_method_added( n ); end
    end
  end

end

require 'yaml'

require 'vying/ruby'
require 'vying/dup'
require 'vying/memoize'

require 'vying/parts/board'
require 'vying/parts/dice'
require 'vying/parts/cards/card'

require 'vying/user'
require 'vying/random'
require 'vying/option'
require 'vying/position'
require 'vying/notation'
require 'vying/rules/card/trick/trick'
require 'vying/rules'
require 'vying/player'
require 'vying/move'
require 'vying/special_move'
require 'vying/history'
require 'vying/game'
require 'vying/ai/search'
require 'vying/ai/book'
require 'vying/ai/bot'

# The version file is generated by 'rake version' for tagged versions of the
# library.  So, it may not be present.

begin
  require 'vying/version'
rescue LoadError
  nil
end

# Load all SpecialMoves, Rules, Notations, and Bots

SpecialMove.require_all
Rules.require_all
Notation.require_all
Bot.require_all( $:.select { |p| p =~ /vying/ } )

