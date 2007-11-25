
require 'optparse'
require 'vying'

CLI::SUBCOMMANDS << "play"

module CLI
  class HumanBot < Bot
    def select( sequence, position, player )
      puts position

      puts "Ops: #{position.moves.inspect}"
      print "Select: "

      move = $stdin.gets.chomp

      if move == ""
        puts "exiting..."
        exit
      end

      until position.move?( move )
        puts "'#{move}' not a valid move!"

        print "Select: "

        move = $stdin.gets.chomp

        if move == ""
          puts "exiting..."
          exit
        end
      end
      move 
    end
  end

  def CLI.summarize( games )
    players = {}
    games.each do |g|
      g.players.each do |p|
        players[p] ||= [0,0,0]
        players[p][0] += 1 if g.winner?( p )
        players[p][1] += 1 if g.loser?( p )
        players[p][2] += 1 if g.draw?
      end
    end
    players.each_pair { |k,v| puts "#{k} #{v[0]}-#{v[1]}-#{v[2]}" }
  end

  def CLI.play

    rules = Othello
    p2b = {}
    number = 1

    opts = OptionParser.new

    opts.on( "-r", "--rules RULES" ) { |r| rules = Kernel.const_get( r ) }
    opts.on( "-n", "--number NUMBER" ) { |n| number = Integer(n) }
    opts.on( "-p", "--player PLAYER=BOT" ) do |s|
      s =~ /(\w*)=([\w:]*)/
      #p2b[$1.downcase.intern] = Kernel.const_get( $2 ).new
      p2b[$1.downcase.intern] = Bot.find( $2 ).new
    end


    opts.parse( ARGV )


    games = []
    number.times do |n|

      g = Game.new( rules )
      g.register_users( p2b )
      results = g.play
    
      games << g
    
      puts "completed game #{n}"
    end

    summarize( games )

  end
end
