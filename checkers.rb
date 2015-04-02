require 'byebug'
require 'colorize'
class Piece
  DELTAS = [
    [1, 1],
    [1, -1]
  ]

  KING_DELTAS = [
    [-1, 1],
    [-1, -1]
  ]

  attr_accessor :color, :board, :pos, :king

  def initialize(color, board, pos)
    @king = false
    @color, @board, @pos = color, board, pos
  end

  def inspect
    self.render
  end

  def king?
    @king
  end

  def perform_moves(move_sequence)
    perform_moves!(move_sequence) if valid_move_seq?(move_sequence)


  def perform_moves!(move_sequence)
    if move_sequence[0].is_a?(Fixnum)
      if legal_slide?(move_sequence[0])
        self.perform_slide(move_sequence[0])
      elsif legal_jump?(move_sequence[0])
        self.perform_jump(move_sequence[0])
      else
        raise InvalidMoveError "You can't perform this move!"
      end

    else
      move_sequence.each_with_index do |move, index|
        raise InvalidMoveError "Invalid move, move no. #{index}." if !self.legal_jump?(move)
        self.perform_jump(move)
      end
    end
  end

  def valid_move_seq?(move_seq)
    begin
        new_board = @board.dup
        current_pos = self.pos.dup
        new_board[*current_pos].perform_moves!(move_seq)
    rescue InvalidMoveError
      false

    else
      true
    end


  end



    # dup_board = @board.dup
    # new_self = self.dup(dup_board)
    # return new_self.legal_jump?(move_seq[0]) if move_seq.count == 1
    # result = valid_move_seq?(move_seq[0...-1])
    # dup_board[*new_self.pos].
    # result = false if result = false || new_self.legal_jump?(move_seq.last)
    #
    #
    # # move_seq.each_with_index do |move, index|
    # #   p "#{new_self.pos}"
    #   dup_board = dup_board.dup
    #   new_self = new_self.dup(dup_board)
    #   current_pos = new_self.pos.dup
    #   p "test #{dup_board[*current_pos]}"
    #   return false if !dup_board[*current_pos].legal_jump?(move)
    #   # raise index if !dup_board[*current_pos].legal_jump?(move)
    #   dup_board[*current_pos].perform_jump(move)
    #   p "#{new_self.pos}"
    # end
  # rescue StandardError => e
  #   puts "Error at #{e}"






  def maybe_promote
    return if king?
    current_row = self.pos[0]
    self.color == :red ? back_row = 7 : back_row = 0

    @king = true if current_row == back_row
  end


  def deltas
    @king == true ? DELTAS + KING_DELTAS : forward(DELTAS)
  end

  def forward(deltas)
    deltas.map do |(dx, dy)|
      self.color == :red ? [dx, dy] : [dx * -1, dy]
    end
  end


  def perform_slide(to)
    if legal_slide?(to)
      from = self.pos
      board[*to] = self
      board[*from] = nil
      self.pos = to
      maybe_promote
    else
      raise InvalidMoveError "Illegal slide!"
    end
  end

  def legal_slide?(to)
    #checks if to place is empty & on board
    on_board = @board.on_board?(to)
    to_empty = @board[*to].nil?
    #checks if move is in the available moves for that position
    x_from, y_from = self.pos
    x_to, y_to = to
    delta = x_to - x_from, y_to - y_from
    valid = self.deltas.include?(delta)
    # byebug

    [on_board, to_empty, valid].all?
  end

  def perform_jump(to)
    if legal_jump?(to)

      x_from, y_from = self.pos
      x_to, y_to = to
      opponent_pos = (x_from + x_to) / 2, (y_from + y_to) / 2

      @board[*to] = self
      @board[*opponent_pos] = nil
      @board[*self.pos] = nil
      self.pos = to
      maybe_promote
    else
      raise InvalidMoveError "Illegal jump!"
    end
  end


  def legal_jump?(to)
    # byebug
    #checks if to position is on the board
    on_board = @board.on_board?(to)

    #checks if to position is empty
    to_empty = @board[*to].nil?

    #checks if there is an opponent between from & to positions
    x_from, y_from = self.pos
    x_to, y_to = to
    opponent_pos = (x_from + x_to) / 2, (y_from + y_to) / 2
    has_opponent = !@board[*opponent_pos].nil? && @board[*opponent_pos].color != self.color

    [on_board, to_empty, has_opponent].all?
  end



  def render
    if king?
      color == :red ? "☆".red : "★".black
    else
      color == :red ? "◎".red : "◉".black
    end
  end

  def dup(board)
    new_piece = Piece.new(self.color, board, self.pos.dup)
  end



end


class Board
  BOARD = 8

  attr_accessor :grid

  def initialize(grid = nil)
    if grid
      @grid = grid
    else
      @grid = make_starting_grid
    end
  end

  def on_board?(pos)
    row, col = pos
    pos.all? { |coord| coord.between?(0,7) }
  end

  def [](*pos)
    i,j = pos
    @grid[i][j]
  end

  def []=(*pos, piece)
    i,j = pos
    @grid[i][j] = piece
  end

  def valid_pos?(pos)
    pos.all? { |coord| coord.between?(0,7) }
  end

  def make_starting_grid
    grid = Array.new(BOARD) {Array.new(BOARD)}
    p "test 1"
    8.times do |row|
      case row
      when 0, 2
        grid[row] = even_row(:red, row)
        p "test 2"
      when 1
        grid[row] = odd_row(:red, row)
      when 5, 7
        grid[row] = odd_row(:black, row)
      when 6
        grid[row] = even_row(:black, row)
      end
    end
    grid
  end

  def odd_row(color, row)
    new_row = Array.new(BOARD)
    (0..7).each do |col|
      new_row[col] = Piece.new(color, self, [row, col]) if col.odd?
      new_row[col] = nil if col.even?
    end
    new_row
  end

  def even_row(color, row)
    new_row = Array.new(BOARD)
    (0..7).each do |col|
      new_row[col] = Piece.new(color, self, [row, col]) if col.even?
      new_row[col] = nil if col.odd?
    end
    new_row
  end

  def render
    render_str = "      0 1 2 3 4 5 6 7\n"
    @grid.each_with_index do |row, index|
      count = index
      render_str << "   #{index} "
      row.each do |el|
        count.even? ? background = :white : background = :light_white
        el.nil? ? r = "  ".colorize(:background => background) : r = "#{el.render} ".colorize(:background => background) #if count.even?
        render_str << r
        count += 1
      end
      render_str << "\n"
    end
    render_str
  end

  def display
    puts render
  end

  def dup
    new_grid = Array.new(BOARD) { Array.new(BOARD) }
    dup_board = Board.new(new_grid)
    BOARD.times do |row|
      BOARD.times do |col|
        pos = [row, col]
        # byebug
        self[*pos].nil? ? dup_board[*pos] = nil : dup_board[*pos] = self[*pos].dup(dup_board)
      end
    end
    dup_board
  end
end

class Checkers

  def initialize
    @players = { white: HumanPlayer.new(:white),
                black: HumanPlayer.new(:black) }
  end

end

class InvalidMoveError < StandardError

end
