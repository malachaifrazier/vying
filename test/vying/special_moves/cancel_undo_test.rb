
require 'test/unit'
require 'vying'

class TestCancelUndo < Test::Unit::TestCase
  include Vying

  def sm
    Move::CancelUndo
  end

  def test_wrap
    assert( sm["cancel_undo"] )

    assert( ! sm["undo_canceled_by_black"] )
    assert( ! sm["undo_canceled_by"] )
    assert( ! sm["x_withundos"] )

    assert( SpecialMove["cancel_undo"] )

    assert( sm["cancel_undo"].kind_of?( sm ) )

    assert( SpecialMove["cancel_undo"].kind_of?( sm ) )
  end

  def test_by
    assert_equal( nil, sm["cancel_undo"].by )
  end

  def test_valid_for
    american_checkers = Game.new( AmericanCheckers )
    connect6 = Game.new( Connect6 )

    assert( ! sm["cancel_undo"].valid_for?( american_checkers ) )
    assert( ! sm["cancel_undo"].valid_for?( connect6 ) )

    american_checkers << american_checkers.moves.first
    connect6 << connect6.moves.first

    assert( ! sm["cancel_undo"].valid_for?( american_checkers ) )
    assert( ! sm["cancel_undo"].valid_for?( connect6 ) )

    assert( american_checkers.special_move?( "undo_requested_by_white" ) )
    assert( connect6.special_move?( "undo_requested_by_white" ) )

    american_checkers << "undo_requested_by_white"
    connect6 << "undo_requested_by_white"

    assert( sm["cancel_undo"].valid_for?( american_checkers ) )
    assert( sm["cancel_undo"].valid_for?( connect6 ) )
  end

  def test_effects_history
    assert( ! sm["cancel_undo"].effects_history? )
  end

end

