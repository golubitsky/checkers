
require_relative 'board.rb'
# require 'yaml'
require 'io/console'
require 'colorize'

class Checkers
  attr_reader :board, :current_player, :players
  attr_accessor :move_vectors, :error_message

  def initialize
    @board = Board.new
    @players = {
      white: HumanPlayer.new(:white),
      black: HumanPlayer.new(:black)
    }
    @current_player = :white
    @move_vectors = []
    @error_message = nil
  end

  def play

    until board.lost?(current_player)
      system "clear"
      puts board.render
      if error_message
        puts error_message
      end
      puts "It's #{current_player}'s turn."
      input_char = read_char
      coord = board.cursor
      begin
        case input_char
        when "\r" #RETURN
          if move_vectors.length >= 2
            self.error_message = nil
            players[current_player].play_turn(move_vectors, board)
            @current_player = current_player == :white ? :black : :white
            self.move_vectors = []
          end
        when " "
          self.move_vectors << board.cursor
        when "\e"
          puts "Are you sure you want to exit the game? (y/n)"
          if gets.chomp == "y"
            exit
          end
        when "\e[A" #up arrow
          board.move_cursor(:up)
        when "\e[B" #down
          board.move_cursor(:down)
        when "\e[C" #right
          board.move_cursor(:right)
        when "\e[D" #left
          board.move_cursor(:left)
        when "s"
          save_game
        when "l"
          load_game
        when "\u0003"
          puts "CONTROL-C"
          exit 0
        else
        end
      rescue => e
        self.move_vectors = []
        self.error_message = e.message
      end
    end
    nil
  end

  def read_char
    STDIN.echo = false
    STDIN.raw!

    input = STDIN.getc.chr
    if input == "\e" then
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
    end
  ensure
    STDIN.echo = true
    STDIN.cooked!

    return input
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

  def play_turn(moves, board)
    board.move(moves, color)
  end

  def parse_user_input(input)
    Vector[ self.class.row[input[1].to_i], self.class.column[input[0].intern] ]
  end

end

p Checkers.new.play
