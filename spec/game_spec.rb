require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'go/game'

describe "Game" do
  before :each do
    @game = Go::Game.new
  end

  describe "#new" do
    it "should set the current player turn to white" do
      @game.turn.should == :white
    end

    it "should create a new board" do
      Go::Board.should_receive(:new).once
      @game = Go::Game.new
    end
  end

  describe "#board" do
    it "should return the current layout" do
      @game.board.each{|row| row.each{|cell| cell.should == :empty}}
    end
  end
end
