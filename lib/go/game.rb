require 'go/board'

module Go
  class Game
    attr_reader :turn

    def initialize(board_size=19)
      @turn  = :white
      @board = Board.new(board_size)
    end

    def board
      @board.layout
    end

    def pass
      @board.sync_previous_layout
      next_turn
      self
    end

    def place_stone(row, col)
      @board.place_stone(row, col, @turn)
      next_turn
      self
    end
    
    def pretty_board
      @board.layout.map{|row|
        row.map{|cell|
          case cell
          when :white
            'w'
          when :black
            'b'
          when :empty
            '.'
          end
        }.join(" ")
      }.join("\n")
    end

    private

    def next_turn
      @turn = @turn == :white ? :black : :white
    end
  end
end
