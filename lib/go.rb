require 'go/game'

module Go
  ##
  # Creates a new +Go::Game+ using the specified +board_size+.
  #
  # @param [Integer] board_size The size of the Go board. Standard sizes are
  #   9x9, 13x13 and 19x19.
  #
  # @return [Go::Game] The new +Go::Game+.
  #
  # @example
  #   game = Go.new_game(13) #=> <game#Go::Game...>
  def self.new_game(board_size=19)
    Go::Game.new(board_size)
  end
end
