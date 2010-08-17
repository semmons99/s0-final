module Go
  class UnknownStoneColor < StandardError; end
  class NonEmptySpace < StandardError; end
  class EmptySpace < StandardError; end

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
  end
end
