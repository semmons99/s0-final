require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'go'

describe "Go" do
  describe "#new_game" do
    it "should start a new game of Go" do
      @game = Go.new_game
      @game.should be_an Go::Game
    end

    describe "with `board_size` given" do
      it "should start a new game of Go with specified board size" do
        @game = Go.new_game(13)
        @game.board.length.should == 13
      end
    end
  end
end
