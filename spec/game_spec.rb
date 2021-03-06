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

    describe "with `board_size` given" do
      it "should create a new board of the specified size" do
        @game = Go::Game.new(13)
        @game.board.length.should == 13
      end
    end
  end

  describe "#board" do
    it "should return the current layout" do
      @game.board.each{|row| row.each{|cell| cell.should == :empty}}
    end
  end

  describe "#pass" do
    it "should call Board#pass" do
      # Revealing @board to a user could lead to potentially circumventing game
      # logic. Therefore to test #pass we have to use  #instance_variable_get.
      @game.instance_variable_get(:@board).should_receive(:sync_previous_layout).once
      @game.pass
    end

    it "should change the current player turn to the opposite color" do
      @game.pass
      @game.turn.should == :black
      @game.pass
      @game.turn.should == :white
    end
  end

  describe "#place_stone" do
    it "should place the current players stone in the request position" do
      @game.place_stone(0, 0)
      @game.board[0][0].should == :white
      @game.place_stone(0, 1)
      @game.board[0][1].should == :black
    end

    it "should change the current player turn to the opposite color" do
      @game.place_stone(0, 0)
      @game.turn.should == :black
      @game.place_stone(0, 1)
      @game.turn.should == :white
    end

    it "should return the number of stones captured" do
      @game.place_stone(0, 0).should == 0
      @game.place_stone(0, 1).should == 0
      @game.place_stone(1, 0).should == 0
      @game.pass
      @game.place_stone(1, 1).should == 0
      @game.pass
      @game.place_stone(1, 2).should == 0
      @game.pass
      @game.place_stone(0, 2).should == 1
    end
  end

  describe "#pretty_board" do
    it "should return a console style board" do
      board = <<EOF
w b . . . . . . . . . . . . . . . . .
. . . . . . . . . . . . . . . . . . .
. . . . . . . . . . . . . . . . . . .
. . . . . . . . . . . . . . . . . . .
. . . . . . . . . . . . . . . . . . .
. . . . . . . . . . . . . . . . . . .
. . . . . . . . . . . . . . . . . . .
. . . . . . . . . . . . . . . . . . .
. . . . . . . . . . . . . . . . . . .
. . . . . . . . . . . . . . . . . . .
. . . . . . . . . . . . . . . . . . .
. . . . . . . . . . . . . . . . . . .
. . . . . . . . . . . . . . . . . . .
. . . . . . . . . . . . . . . . . . .
. . . . . . . . . . . . . . . . . . .
. . . . . . . . . . . . . . . . . . .
. . . . . . . . . . . . . . . . . . .
. . . . . . . . . . . . . . . . . . .
. . . . . . . . . . . . . . . . . . .
EOF
      @game.place_stone(0, 0)
      @game.place_stone(0, 1)
      @game.pretty_board.should == board.chop
    end
  end
end
