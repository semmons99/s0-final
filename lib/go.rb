require 'go/game'

module Go
  def self.new_game(board_size=19)
    Go::Game.new(board_size)
  end
end
