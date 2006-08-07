require 'game'

# These changes to Enumerable (adding powerset and each_subset) are taken from
# comp.lang.ruby.
#   <http://groups.google.com/group/comp.lang.ruby/msg/b7e6135533b85ca6?hl=en&>

module Enumerable
  def each_subset(skip_empty = false)
    enum = respond_to?( :size ) ? self : to_a

    for n in (skip_empty ? 1 : 0) ... (1 << enum.size) do
      subset = []

      enum.each_with_index do |elem, i|
        subset << elem if n[i] == 1
      end

      yield subset
    end

    self
  end

  def powerset(skip_empty = false)
    subsets = []

    each_subset(skip_empty) { |s| subsets << s }

    return subsets
  end
end 

class Fifteen < Rules

  info :name => 'Fifteen',
       :description => 'Fifteen is isomorphic to Tic Tac Toe.  Each player' +
                       ' takes turns selecting numbers between 1 and 9,' +
                       ' with no number taken first.  The winner is the' +
                       ' first to have any combination of his selected' +
                       ' numbers add up to 15.',
       :resources => ['Wikipedia <http://en.wikipedia.org/wiki/Tic-tac-toe>']

  attr_reader :unused, :a_list, :b_list, :turn

  players [:a, :b]

  def initialize( seed=nil )
    @unused = (1..9).to_a
    @a_list = []
    @b_list = []
    @turn = players.dup
  end

  def op?( op, player=nil )
    return false unless player.nil? || has_ops.include?( player )
    op.to_s =~ /(a|b)(\d)/
    turn.now.to_s == $1 && unused.include?( $2.to_i )
  end

  def ops( player=nil )
    return false unless player.nil? || has_ops.include?( player )
    return nil if final?
    a = unused.map { |n| "#{turn.now}#{n}" }
    a == [] ? nil : a
  end

  def apply!( op )
    op.to_s =~ /(a|b)(\d)/
    n = $2.to_i
    unused.delete( n )
    a_list << n if turn.now == :a
    b_list << n if turn.now == :b
    turn.rotate!
    self
  end

  def has_15?( list )
    list.each_subset do |subset|
      if subset.length == 3
        return true if subset.inject(0) { |n, value| n + value } == 15
      end
    end
    false
  end

  def final?
    return true  if unused.length == 0
    return false if unused.length >  4
    has_15?( a_list ) || has_15?( b_list )
  end

  def winner?( player )
    return has_15?( a_list ) if player == :a
    return has_15?( b_list ) if player == :b
  end

  def loser?( player )
    return !draw? && !has_15?( a_list ) if player == :a
    return !draw? && !has_15?( b_list ) if player == :b
  end

  def draw?
    unused.empty? && !has_15?( a_list ) && !has_15?( b_list )
  end
end
