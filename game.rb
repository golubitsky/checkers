
require_relative 'board.rb'
# require 'yaml'
require 'io/console'
require 'colorize'

class Checkers
  attr_reader :board, :current_player, :players

  def initialize
    @board = Board.new
    @players = {
      white: HumanPlayer.new(:white),
      black: HumanPlayer.new(:black)
    }
    @current_player = :white
  end

  def play
    until board.lost?(current_player)
        system "clear"
        puts board.render
        begin
          players[current_player].play_turn(board)
        rescue => e
          puts e.message
          retry
        end
      @current_player = current_player == :white ? :black : :white
    end
    nil
  end

  
end

class HumanPlayer
  attr_accessor :board, :color

  def self.column
    columns = Hash.new(0)
    [*"a".."h"].each_with_index do |letter, index|
      columns[letter.intern] = letter.ord - 97
    end
    columns
  end

  def self.row
    [nil, 7,6,5,4,3,2,1,0]
  end


  def initialize(color)
    @board = board
    @color = color
  end

  def play_turn(board)
    puts "It's #{color}'s turn. Enter coordinates of next move or series of moves (format: e2 e4)"
    user_input = gets.chomp.downcase

    desired_moves = user_input.scan(/\w{2}/)
    unless desired_moves.size >= 2 && desired_moves.all? { |pos| pos =~ /[a-h][1-8]/ }
      raise "Please enter at least 2 coordinates in specified format."
    end
    desired_moves.map!{ |move| parse_user_input(move) }

    board.move(desired_moves, color)
  end

  def parse_user_input(input)
    Vector[ self.class.row[input[1].to_i], self.class.column[input[0].intern] ]
  end

end

p Checkers.new.play
