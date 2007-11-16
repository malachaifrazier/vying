require 'vying/ai/bot'
require 'vying/ai/search'

module OthelloStrategies

  $:.each do |d|
    Dir.glob( "#{d}/**/ai/strategies/othello/*" ) do |f|
      if f =~ /corners\.yaml$/
        CORNERS_YAML = f unless defined? CORNERS_YAML
      elsif f=~ /edge\.yaml$/
        EDGE_YAML = f unless defined? EDGE_YAML
      elsif f =~ /openings\.txt$/
        OPENINGS_TXT = f unless defined? OPENINGS_TXT
      end
    end
  end


  CORNER_COORDS = [[:a1,:b2,:a2,:a3],
                   [:a1,:b2,:b1,:c1],
                   [:h1,:g2,:g1,:f1],
                   [:h1,:g2,:h2,:h3],
                   [:a8,:b7,:b8,:c8],
                   [:a8,:b7,:a7,:a6],
                   [:h8,:g7,:g8,:f8],
                   [:h8,:g7,:h7,:h6]]

  EDGE_COORDS = [[:a2,:a3,:a4,:a5,:a6,:a7],
                 [:h2,:h3,:h4,:h5,:h6,:h7],
                 [:b1,:c1,:d1,:e1,:f1,:g1],
                 [:b8,:c8,:d8,:e8,:f8,:g8]]

  def load_corners
    @corners ||= YAML.load_file( CORNERS_YAML )
  end

  def load_edges
    @edges ||= YAML.load_file( EDGE_YAML )
  end

  def load_openings
    return @openings if defined? @openings

    @openings = []
    File.open( OPENINGS_TXT ) do |file|
      while line = file.gets
        @openings << line.strip.downcase
      end
    end
  end

  def opening( position, sequence )
    possible = []
    position.moves.each do |move|
      s = sequence.join + move.to_s
      possible << move if @openings.select { |o| o =~ /^#{s}/ }.length > 0
    end
    return possible[rand(possible.length)] unless possible.empty?

    nil
  end

  def opp( position, player )
    position.players.select { |p| p != player }.first
  end

  def eval_count( position, player )
    pc = position.board.count( player )
    oc = position.board.count( opp( position, player ) )
    total = pc + oc
    score = pc - oc

    [pc, oc, total, score]
  end

  def eval_corners( position, player )
    score = 0

    corner_arrays = CORNER_COORDS.map do |c|
      corner( position, player, opp( position, player ), *c )
    end

    corner_arrays.inject(0) { |m,c| m + @corners[c] }
  end

  def corner( position, player, opp, corner, x, c, edge )
    key = [nil, player, opp]
    [corner,x,c,edge].map { |p| key.index( position.board[Coord[p]] ) }
  end

  def eval_edges( position, player )
    opp = position.players.select { |p| p != player }.first

    edge_array = EDGE_COORDS.map do |e|
      edge( position, player, opp( position, player ), e )
    end

    edge_array.inject(0) { |m,e| m + @edges[e] }
  end

  def edge( position, player, opp, pieces )
    key = [nil, player, opp]
    pieces.map { |p| key.index( position.board[Coord[p]] ) }
  end

  def eval_full_edges( position, player )
    b = position.board
    count_if_full( b[b.coords.row(Coord[:a1])], player ) +
    count_if_full( b[b.coords.column(Coord[:a1])], player ) +
    count_if_full( b[b.coords.row(Coord[:h8])], player ) +
    count_if_full( b[b.coords.column(Coord[:h8])], player )
  end

  def count_if_full( pieces, player )
    not_nil = pieces.select { |p| !p.nil? }
    not_nil.length == 8 ? not_nil.select { |p| p == player }.length : 0
  end

  def eval_frontier( position, player )
    opp = position.players.select { |p| p != player }.first
    score = 0

    position.frontier.each do |c|
      position.board.coords.neighbors( c ).each do |n|
        score += 1 if position.board[n] == opp
        score -= 1 if position.board[n] == player
      end
    end

    score
  end

  def eval_board_late( position, player )
    opp = position.players.select { |p| p != player }.first

    @comp_board ||= [[80,  -5,  7,  5,  5,  7,  -5, 80],
                     [-5, -20,  3,  2,  2, -1, -20, -5],
                     [ 7,  -1, -3, -2, -2, -3,   3,  7],
                     [ 5,   2, -2, -1, -1, -2,   2,  5],
                     [ 5,   2, -2, -1, -1, -2,   2,  5],
                     [ 7,  -1, -3, -2, -2, -3,   3,  7],
                     [-5, -20, -1,  2,  2, -1, -20, -5],
                     [80,  -5,  7,  5,  5,  7,  -5, 80]]

    score = 0
    8.times do |i|
      8.times do |j|
        piece = position.board[i,j]
        score += @comp_board[i][j] if piece == player
        score -= @comp_board[i][j] if piece != player && !piece.nil?
      end
    end

    score
  end

  def eval_board_early( position, player )
    opp = position.players.select { |p| p != player }.first

    @comp_board ||= [[ 75, -25, -6, -6, -6, -6, -25,  75],
                     [-25, -50, -5, -5, -5, -5, -50, -25],
                     [ -6,  -5, -4, -2, -2, -4,  -5,  -6],
                     [ -6,  -5, -2, -1, -1, -2,  -5,  -6],
                     [ -6,  -5, -2, -1, -1, -2,  -5,  -6],
                     [ -6,  -5, -4, -2, -2, -4,  -5,  -6],
                     [-25, -50, -5, -5, -5, -5, -50, -25],
                     [ 75, -25, -6, -6, -6, -6, -25,  75]]

    score = 0
    8.times do |i|
      8.times do |j|
        piece = position.board[i,j]
        score += @comp_board[i][j] if piece == player
        score -= @comp_board[i][j] if piece != player && !piece.nil?
      end
    end

    score
  end

end

