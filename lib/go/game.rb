require 'go/board'

module Go
  ##
  # Stores the state of a game of Go and provided methods for players to
  # interact with the board.
  class Game
    ##
    # @return [Symbol, :black, :white] The color of the current players turn.
    attr_reader :turn

    ##
    # Starts a new game of Go.
    #
    # @param [Integer] board_size The size of the Go board. Standard sizes are
    #   9x9, 13x13 and 19x19.
    #
    # @return [Go::Game] +self+
    def initialize(board_size=19)
      @turn  = :white
      @board = Board.new(board_size)
    end

    ##
    # Returns the current state of the board.
    #
    # @return [Array[Array]] Current state of the board.
    def board
      @board.layout
    end

    ##
    # Passes the current players turn.
    #
    # @return [Go::Game] +self+
    def pass
      @board.sync_previous_layout
      next_turn
      self
    end

    ##
    # Places a stone at the specified +row+/+col+ for the current player.
    #
    # @param [Integer] row The row to place the stone in.
    # @param [Integer] col The column to place the stone in.
    #
    # @return [Integer] The number of stones captured
    def place_stone(row, col)
      captured = @board.place_stone(row, col, @turn)
      next_turn
      captured
    end
    
    ##
    # Returns a string representation of the board which can be output to the
    # console.
    #
    # @return [String] Pretty version of the board for use in console output.
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

    ##
    # Updates the current players turn to the next
    #
    # @return [Symbol, :black, :white] The color of the new turns player.
    def next_turn
      @turn = @turn == :white ? :black : :white
    end
  end
end
