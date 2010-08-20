module Go
  ##
  # Error raised when a stone is played that isn't black/white.
  class UnknownStoneColor < StandardError; end

  ##
  # Error raised when a stone is placed on a non-empty space.
  class NonEmptySpace < StandardError; end

  ##
  # Error raised when attempting to remove a stone from an empty space.
  class EmptySpace < StandardError; end

  ##
  # Error raised when placing a stone would result in a Ko violation.
  class KoViolation < StandardError; end

  ##
  # Error raise when placing a stone would result in suicide.
  class SuicideAttempted < StandardError; end

  ##
  # Array for easy calculation of a stones neighbors.
  NEIGHBORS = [
    {:row => 0, :col => -1}, {:row => -1, :col => 0},
    {:row => 0, :col =>  1}, {:row =>  1, :col => 0}
  ]

  ##
  # Represents a Go board and it's current and previous state.
  class Board
    ##
    # @return [Integer] The size of the board.
    attr_reader :size

    ##
    # @return [Array[Array]] The current state of the board.
    attr_reader :layout

    ##
    # @return [Array[Array]] The previous state of the board.
    attr_reader :previous_layout

    ##
    # Creates a new instance of Go::Board, initializing +size+, +layout+ and
    # +previous_layout+.
    #
    # @param [Integer] size The size of the Go board. Standard sizes are 9x9,
    #   13x13 and 19x19.
    #
    # @return [Go::Board] +self+
    def initialize(size = 19)
      @size            = size
      @layout          = Array.new(@size){Array.new(@size)}
      @previous_layout = Array.new(@size){Array.new(@size)}
      reset
    end

    ##
    # Removes all the stones from +layout+ and +previous_layout+.
    #
    # @return [Go::Board] +self+
    def reset
      [@layout, @previous_layout].each do |board|
        (0...@size).each{|row| (0...@size).each{|col| board[row][col] = :empty}}
      end
      self
    end

    ##
    # Places a new stone of the specified +color+ on the board according to the
    # specified +row+ and +col+.
    #
    # @raise [UnknownStoneColor] Raised when a stone color other than
    #   black/white is specified.
    # @raise [NonEmptySpace] Raised when attempting to place a stone on a space
    #   already occupied.
    # @raise [KoViolation] Raised when placing a stone would result in the
    #   same layout as your previous turn.
    # @raise [SuicideAttempted] Raised when placing a stone would result in
    #   suicide.
    #
    # @param [Integer] row The row to place the stone in.
    # @param [Integer] col The column to place the stone in.
    # @param [Symbol, :black, :white] color The color of the stone.
    #
    # @return [Integer] The number of opponents stones captured after placing
    #   this stone.
    def place_stone(row, col, color)
      raise UnknownStoneColor unless [:white, :black].include?(color)
      raise NonEmptySpace unless @layout[row][col] == :empty
      raise KoViolation if ko_violation?(row, col, color)

      opposite_color = color == :white ? :black : :white

      proposed_board = Marshal.load(Marshal.dump(@layout))
      proposed_board[row][col] = color
      captured = capture(opposite_color, proposed_board)
      raise SuicideAttempted if capture(color, proposed_board) > 0

      sync_previous_layout
      @layout = Marshal.load(Marshal.dump(proposed_board))
      captured
    end

    ##
    # Removes a stone from the board specified by +row+ and +col+.
    #
    # @raise [EmptySpace] Raised when attempting to remove a stone from an
    #   empty space.
    #
    # @param [Integer] row The row to remove the stone from.
    # @param [Integer] col The column to remove the stone from.
    #
    # @return [Go::Board] +self+
    def remove_stone(row, col)
      raise EmptySpace if @layout[row][col] == :empty

      sync_previous_layout
      @layout[row][col] = :empty
      self
    end

    ##
    # Syncs +previous_layout+ with +layout+. Used to help detect Ko violations.
    #
    # @return [Go::Board] +self+
    def sync_previous_layout
      @previous_layout = Marshal.load(Marshal.dump(@layout))
      self
    end

    ##
    # Returns an array containing all stone groups on the specified +board+.
    #
    # @param [Array[Array]] board The Go board to find the groups on.
    #
    # @return [Array[Array]] The discovered groups.
    def groups(board = @layout)
      groups = []
      ct = (0...board.length).to_a
      ct.product(ct).each do |coord|
        row, col = coord
        stone = {:row => row, :col => col}
        next if board[row][col] == :empty
        next if groups.map{|g| g.include?(stone)}.include?(true)
        groups << group_for(board, row, col)
      end
      groups
    end

    ##
    # Returns the number of liberties available to the specified +group+ on the
    # specified +board+.
    #
    # @param [Array] group The group of stones to count liberties for.
    # @param [Array[Array]] board The board to use to check liberties.
    #
    # @return [Integer] The number of liberties available to the group.
    def liberties_for(group, board = @layout)
      neighbors = []
      group.each do |stone|
        NEIGHBORS.each do |neighbor|
          next unless stone[:row]+neighbor[:row]>=0
          next unless stone[:col]+neighbor[:col]>=0
          next unless stone[:row]+neighbor[:row]<board.length
          next unless stone[:col]+neighbor[:col]<board.length
          neighbors << { :row => stone[:row]+neighbor[:row],
                         :col => stone[:col]+neighbor[:col] }
        end
      end
      neighbors.uniq!
      neighbors.select{|neighbor|
        board[neighbor[:row]][neighbor[:col]] == :empty
      }.length
    end

    private

    ##
    # Recursive method to find all the members of a group of stones.
    #
    # @param [Array[Array]] board The board to check with.
    # @param [Integer] row The row of the stone to use.
    # @param [Integer] col The column of the stone to use.
    # @param [Array] group The current stones found to belong to the group.
    #
    # @return [Array] The resulting group found.
    def group_for(board, row, col, group = [])
      stone = {:row => row, :col => col}
      return group if group.include?(stone)
      group << stone
      NEIGHBORS.each do |neighbor|
        next unless row+neighbor[:row]>=0 and row+neighbor[:row]<board.length
        next unless col+neighbor[:col]>=0 and col+neighbor[:col]<board.length
        next unless board[row+neighbor[:row]][col+neighbor[:col]] == board[row][col]
        group = group_for(board, row+neighbor[:row], col+neighbor[:col], group)
      end
      group
    end

    ##
    # Returns true if the specified move would result in a Ko violation,
    # otherwise false.
    #
    # @param [Integer] row The row of the stone being placed.
    # @param [Integer] col The column of the stone being placed.
    # @param [Symbol, :black, :white] The color of the stone being placed.
    #
    # @return [true, false] Whether or not the moved results in a Ko violation.
    def ko_violation?(row, col, color)
      proposed_layout(row, col, color) == @previous_layout
    end

    ##
    # Returns the state of @layout if the moved is made.
    #
    # @param [Integer] row The row of the stone being placed.
    # @param [Integer] col The column of the stone being placed.
    # @param [Symbol, :black, :white] The color of the stone being placed.
    #
    # @return [Array[Array]] The proposed +layout+ after the move is made.
    def proposed_layout(row, col, color)
      _layout = Marshal.load(Marshal.dump(@layout))
      _layout[row][col] = color
      _layout
    end

    ##
    # Takes a +color+ and +board+ and captures any stones without liberties.
    #
    # @param [Symbol, :black, :white] The color of stone to capture.
    # @param [Array[Array]] board The board to capture from.
    #
    # @return [Integer] The number of stones captured.
    def capture(color, board = @layout)
      captured = 0
      groups(board).each do |group|
        next if board[group[0][:row]][group[0][:col]] != color
        if liberties_for(group, board) == 0
          group.each do |stone|
            captured += 1
            board[stone[:row]][stone[:col]] = :empty
          end
        end
      end
      captured
    end
  end
end
