module Go
  class UnknownStoneColor < StandardError; end
  class NonEmptySpace < StandardError; end
  class EmptySpace < StandardError; end
  class KoViolation < StandardError; end

  NEIGHBORS = [
    {:row => 0, :col => -1}, {:row => -1, :col => 0},
    {:row => 0, :col =>  1}, {:row =>  1, :col => 0}
  ]

  class Board
    attr_reader :size, :layout, :previous_layout

    def initialize(size = 19)
      @size            = size
      @layout          = Array.new(@size){Array.new(@size)}
      @previous_layout = Array.new(@size){Array.new(@size)}
      reset
    end

    def reset
      [@layout, @previous_layout].each do |board|
        (0...@size).each{|row| (0...@size).each{|col| board[row][col] = :empty}}
      end
      self
    end

    def place_stone(row, col, color)
      raise UnknownStoneColor unless [:white, :black].include?(color)
      raise NonEmptySpace unless @layout[row][col] == :empty
      raise KoViolation if ko_violation?(row, col, color)

      sync_previous_layout
      @layout[row][col] = color
      self
    end

    def remove_stone(row, col)
      raise EmptySpace if @layout[row][col] == :empty

      sync_previous_layout
      @layout[row][col] = :empty
      self
    end

    def sync_previous_layout
      @previous_layout = Marshal.load(Marshal.dump(@layout))
      self
    end

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

    private

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

    def ko_violation?(row, col, color)
      proposed_layout = Marshal.load(Marshal.dump(@layout))
      proposed_layout[row][col] = color
      proposed_layout == @previous_layout
    end
  end
end
