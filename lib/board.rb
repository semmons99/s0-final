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
  end
end
