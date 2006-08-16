require 'rubygems'
require 'random'

class Random::MersenneTwister
  def dup
    Marshal.load( Marshal.dump( self ) )
  end

  def eql?( o )
    state.eql? o.state
  end

  def ==( o )
    eql? o
  end
end

class Rules
  def initialize_copy( original )
    nd = [Symbol, NilClass, Fixnum, TrueClass, FalseClass]
    instance_variables.each do |iv|
      v = instance_variable_get( iv )
      if !nd.include?( v.class )
        instance_variable_set( iv, v.dup )
      end
    end
  end

  def initialize( seed=nil )
    if info[:random] ||= false
      @seed = seed.nil? ? rand( 10000 ) : seed
      @rng = Random::MersenneTwister.new( @seed )
    end
    @turn = players.dup
  end

  def eql?( o )
    return false if instance_variables.sort != o.instance_variables.sort
    instance_variables.each do |iv|
      return false if instance_variable_get(iv) != o.instance_variable_get(iv)
    end
    true
  end

  def ==( o )
    eql?( o )
  end

  def self.info( i={} )
    @info = i
    class << self; attr_reader :info; end
  end

  def self.random
    info[:random] = true
    attr_reader :seed, :rng
  end

  def self.censor( h={}, p=nil )
    @censored = h
    class << self
      undef_method :censor
      attr_reader :censored
    end
  end

  def censor( player )
    pos = self.dup

    pos.instance_eval( "@rng = :hidden" ) if pos.info[:random]

    return pos unless pos.respond_to? :censored
    return pos if     censored[player].nil?

    censored[player].each do |f|
      pos.instance_eval( "@#{f} = :hidden" )
    end

    pos
  end

  def self.players( p )
    @players = p
    class << self; attr_reader :players; end
    p
  end

  def method_missing( m, *args )
    self.class.send( m, *args ) if self.class.respond_to?( m )
  end

  def respond_to?( m )
    super || self.class.respond_to?( m )
  end

  def turn( action=:now )
    case action
      when :now    then return @turn[0]
      when :next   then return @turn[1] if @turn.size > 1
      when :rotate
        @turn << @turn.delete_at( 0 )
    end
    @turn[0]
  end

  def op?( op, player=nil )
    (ops( player ) || []) .include?( op )
  end

  def draw?
    false
  end

  def score( player )
    return  0 if draw?
    return  1 if winner?( player )
    return -1 if loser?( player )
  end

  def has_ops
    [turn]
  end

  def apply( op )
    self.dup.apply!( op )
  end

  def Rules.find( path=$: )
    required = []
    path.each do |d|
      Dir.glob( "#{d}/rules/**/*.rb" ) do |f|
        f =~ /(.*)\/rules\/(.*\.rb)$/
        if ! required.include?( $2 ) && !f["test_"] && !f["ts_"]
          required << $2
          require "#{f}"
        end
      end
    end
  end

  @@rules_list = []

  def self.inherited( child )
    @@rules_list << child
  end

  def Rules.list
    @@rules_list
  end

  def to_s
    s = ''
    fs = instance_variables.map { |iv| iv.to_s.length }.max + 2
    instance_variables.each do |iv|
      v = instance_variable_get( iv )
      iv = iv.sub( /@/, '' )
      case v
        when Hash  then s += "#{iv}:".ljust(fs) + "#{v.inspect}\n"
        when Array then s += "#{iv}:".ljust(fs) + "#{v.inspect}\n"
        else
          s += "#{iv}:\n#{v}\n"               if v.to_s =~ /\n/
          s += "#{iv}:".ljust(fs) + "#{v}\n"  if v.to_s !~ /\n/
      end
    end
    s
  end
end
