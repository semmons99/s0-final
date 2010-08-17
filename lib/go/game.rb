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
      @turn = @turn == :white ? :black : :white
      self
    end
  end
end
