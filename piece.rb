class Piece
  attr_accessor :char, :king, :position, :board, :slides, :jumps
  attr_accessor :all_available_slides, :all_available_jumps
  attr_reader :color, :moves

  def self.vectors(color, king = false)
    white = [ [-1, 1], [-1, -1] ]
    black = [ [1, 1], [1, -1] ]

    if king
      (white + black).map{ |arr| Vector.elements(arr) }
    elsif color == :white
      white.map{ |arr| Vector.elements(arr) }
    else
      black.map{ |arr| Vector.elements(arr) }
    end

  end


  def initialize(color, board, x,y)
    @color = color
    @char = color == :white ? "⛀" : "⛂"
    @king = false
    @position = Vector[x, y]
    @board = board
    @slides = []
    @jumps = []
    @all_available_slides = []
    @all_available_jumps = []
  end

  def determine_moves(start)
    self.slides = []
    self.jumps = []
    vectors = self.class.vectors(color, king)
    vectors.each do |vector|
      potential_move = start + vector
      next unless board.class.on_board?(potential_move)
      if board.is_empty?(potential_move)
        self.slides << potential_move
      else #jump logic
        potential_move = potential_move + vector #still need to delete the "jumped" piece
        if board.is_empty?(potential_move)
          self.jumps << potential_move
        end
      end
    end
  end

  def perform_slide(start, end_pos, player_color)
    determine_moves(start)
    ##line 57 needs to check for ALL available jump moves, not just this piece's
    # raise "Must jump when jump is available." if board.has_jumps?(player_color)
    raise "Can't move opponent pieces." unless board[start].color == player_color
    raise "Invalid move." unless slides.include?(end_pos)

    manipulate_board(start, end_pos, player_color)
  end

  def has_jumps?(start)
    vectors = self.class.vectors(color, king)
    vectors.each do |vector|
      potential_move = start + vector
      next unless board.class.on_board?(potential_move)
      if !board.is_empty?(potential_move)
        potential_move = potential_move + vector #still need to delete the "jumped" piece
        return true if board.is_empty?(potential_move)
      end
    end
  end

  def perform_jump(start, end_pos, player_color)
    determine_moves(start)
    raise "Can't move opponent's pieces." unless board[start].color == player_color
    raise "Invalid move." unless jumps.include?(end_pos)

    manipulate_board(start, end_pos, player_color)

    remove_jumped_opponent(start, end_pos)
  end

  def manipulate_board(start, end_pos, player_color)
    board[end_pos] = board[start] #changes the grid
    board[start] = nil #start position becomes empty square
    board[end_pos].position = end_pos #tells piece its new position
    case player_color
    when :white
      board[end_pos].king, board[end_pos].char = true, "⛁" if end_pos[0] == 0
    when :black
      board[end_pos].king, board[end_pos].char = true, "⛃" if end_pos[0] == 7
    end
  end

  def remove_jumped_opponent(start, end_pos)
    y_dir = end_pos[0] > start[0] ? 1 : -1 #moving DOWN THE BOARD or UP?
    x_dir = end_pos[1] > start[1] ? 1 : -1 #moving RIGHT or LEFT?

    opponent = start + Vector[y_dir, x_dir]
    board[opponent] = nil
  end

end
