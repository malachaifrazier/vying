require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestSpangles < Test::Unit::TestCase
  include RulesTests

  def rules
    Spangles
  end

  def test_info
    assert_equal( "Spangles", rules.name )
  end

  def test_players
    assert_equal( [:black,:white], rules.new.players )
  end

  def test_init
    g = Game.new( rules )

    assert_equal( :black, g.turn )
    assert_equal( [Coord[0,0]], g.board.occupied( :white ) )
    assert_equal( [], g.board.occupied( :black ) )
  end

  def test_has_score
    g = Game.new( rules )
    assert( !g.has_score? )
  end

  def test_has_moves
    g = Game.new( rules )
    assert_equal( [:black], g.has_moves )
    g << g.moves.first
    assert_equal( [:white], g.has_moves )
  end

  def test_game01   # Quick, simple win
    g = play_sequence %w( (-1,0) (-1,-1) (0,1) (-2,-1) (1,0) )

    assert( !g.draw? )
    assert( g.winner?( :black ) )
    assert( !g.loser?( :black ) )
    assert( !g.winner?( :white ) )
    assert( g.loser?( :white ) )
  end

  def test_game02   # Suicide
    g = play_sequence %w( (1,0) (1,-1) (2,0) (0,-1) (3,0) (-1,-1) (-2,-1) 
                          (-3,-1) (-3,0) (-2,0) (-1,0) )

    assert( !g.draw? )
    assert( !g.winner?( :black ) )
    assert( g.loser?( :black ) )
    assert( g.winner?( :white ) )
    assert( !g.loser?( :white ) )
  end

  def test_game03   # Win by filling center
    g = play_sequence %w( (1,0) (1,-1) (2,0) (0,-1) (3,0) (-1,-1) (-2,-1) 
                          (-3,-1) (-3,0) (-2,0) (4,0) (-1,0) )

    assert( !g.draw? )
    assert( !g.winner?( :black ) )
    assert( g.loser?( :black ) )
    assert( g.winner?( :white ) )
    assert( !g.loser?( :white ) )
  end

  def test_game04   # Simultaneous connection
    g = play_sequence %w( (1,0) (1,-1) (0,-1) (-1,-1) (-2,-1) (-3,-1) (-3,0)
                          (-2,0) (-1,0) )

    assert( !g.draw? )
    assert( g.winner?( :black ) )
    assert( !g.loser?( :black ) )
    assert( !g.winner?( :white ) )
    assert( g.loser?( :white ) )
  end

end

