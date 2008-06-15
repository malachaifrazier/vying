# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

# Container for constants related to the vying library

module Vying
  
  # Returns the version of this vying codebase.

  def self.version
    v = const_defined?( :VERSION ) ? VERSION : "svn trunk"
    "vying #{v}"
  end
end

begin
  require 'rubygems'
rescue LoadError
  # No worries, mate.
end

require 'yaml'

require 'vying/board/board'
require 'vying/board/amazons'
require 'vying/board/connect6'
require 'vying/board/hexhex'
require 'vying/board/mancala'
require 'vying/board/othello'
require 'vying/board/y'
require 'vying/board/yinsh'

require 'vying/dice'

require 'vying/user'
require 'vying/random'
require 'vying/dup'
require 'vying/option'
require 'vying/position'
require 'vying/notation'
require 'vying/rules'
require 'vying/game'
require 'vying/ai/search'
require 'vying/ai/bot'

# The version file is generated by 'rake gem', so it may not be present

begin
  require 'version'
rescue LoadError
  nil
end

# Load all Rules, Notations, and Bots

Rules.require_all
Notation.require_all
Bot.require_all

