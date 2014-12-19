require_relative 'piece.rb'
require 'byebug'
require 'matrix'
require 'colorize'

class Board
  attr_accessor :grid, :cursor

  def self.on_board?(potential_move)
    potential_move.all? do |coord|
      coord.between?(0, 7)
    end
  end

  def initialize(populate = true)
    @grid = Array.new(8) { Array.new(8) { nil } }
    populate_board if populate
    @cursor = Vector[5,4]
  end

  def populate_board
    [0,1,2,5,6,7].each do |y|
      x = y.even? ? [1,3,5,7] : [0,2,4,6]
      x.each do |x_pos|
        color = y < 3 ? :black : :white
        @grid[y][x_pos] = Piece.new(color, self, y, x_pos)
      end
    end
  end

  def move(moves, player_color)
    if moves.length == 2
      perform_single_move(moves[0], moves[1], player_color)
    else
      raise "Invalid move" unless valid_move_seq?(moves, player_color)
      perform_moves!(moves, player_color)
    end
  end

  def perform_single_move(start, end_pos, player_color)
    raise "No piece at start position." if self[start].nil?
    move_size = (start - end_pos)[0].abs

    if move_size == 1
      self[start].perform_slide(start, end_pos, player_color)
    else
      self[start].perform_jump(start, end_pos, player_color)
    end
  end

  def valid_move_seq?(move_series, player_color)
    moves_in_series = generate_moves(move_series)
    dupped_board = self.deep_dup
    moves_in_series.each do |move|
      dupped_board.move(move, player_color)
    end
    true
  end

  def generate_moves(move_series) #generate actual start/end moves from series given by player
    i = 0
    moves_in_series = []
    while i < move_series.length - 1
      move = []
      move << move_series[i]
      move << move_series[i + 1]
      moves_in_series << move
      i += 1
    end
    moves_in_series
  end

  def perform_moves!(move_series, player_color)
    moves_in_series = generate_moves(move_series)
    moves_in_series.each do |move|
      self.move(move, player_color)
    end
  end

  def is_empty?(position)
    self[position].nil?
  end

  def lost?(color)
    grid.flatten.compact.none? { |piece| piece.color == color }
  end

  def deep_dup
    dupped_board = Board.new(false)
    grid.flatten.compact.each do |piece|
      pos = piece.position.dup
      dupped_board[pos] = Piece.new(piece.color, dupped_board, pos[0], pos[1])
    end

    dupped_board
  end

  def [](vector)
    grid[vector[0]][vector[1]]
  end

  def []=(vector, value)
    grid[vector[0]][vector[1]] = value
  end

  def render
    str  = ''
    @grid.each_with_index do |row, y|
      str << "#{[8,7,6,5,4,3,2,1][y]} "
      row.each_with_index do |col, x|
        char = col ? col.char.colorize(col.color) : " "
        char = add_background_color(char + " ", x, y)

        char = char.blue.on_yellow.blink if Vector[y,x] == self.cursor

        str << char
      end
      str << "\n"
    end
    str << "  A B C D E F G H"
    str
  end

  def add_background_color(str, x, y)
    if (x % 2 == 0 && y % 2 == 0) || (x % 2 == 1 && y % 2 == 1)
      str.colorize(:background => :light_blue)
    else
      str.colorize(:background => :blue)
    end
  end

  def inspect
    render
  end

  def move_cursor(direction)
    case direction
    when "up"
      self.cursor = cursor + Vector[-1, 0]
    when "down"
      self.cursor = cursor + Vector[1, 0]
    when "left"
      self.cursor = cursor + Vector[0, -1]
    when "right"
      self.cursor = cursor + Vector[0, 1]
    end

    self.cursor = cursor.to_a.map do |x|
      if x < 0
        x += 8
      elsif x > 7
        x -= 8
      else
        x
      end
    end
    Vector.elements(cursor)
  end
end
#
# a = Board.new
# a.move([ Vector[5,6], Vector[ 4,7] ], :white)
# a.move([ Vector[2,7], Vector[ 3,6] ], :black)
# a.move([ Vector[5,0], Vector[ 4,1] ], :white)
# a.move([ Vector[2,5], Vector[ 3,4] ], :black)
#
# a.move([ Vector[5,4], Vector[ 4,3] ], :white)
# a.move([ Vector[2,3], Vector[ 3,2] ], :black)
#
# a.move([ Vector[4,1], Vector[ 3,0] ], :white)
# a.move([ Vector[1,2], Vector[ 2,3] ], :black)
#
# a.move([ Vector[6,5], Vector[ 5,4] ], :white)
# a.move([ Vector[0,3], Vector[ 1,2] ], :black)
#
# b = a.deep_dup
# # byebug
# a.move([ Vector[4,7], Vector[ 2,5], Vector[ 0, 3] ], :white)
# # a.move([ Vector[0,5], Vector[ 1,4] ], :black)
#
# # a.move([ Vector[0,3], Vector[ 2,5] ], :white)
# puts a.render
