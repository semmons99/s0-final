require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'go/board'

describe "Board" do
  before :each do
    @board = Go::Board.new
  end

  describe "#new" do
    it "should store the default board size" do
      @board.size.should == 19
    end

    it "should create the board with the default dimensions" do
      @board.layout.length.should == 19
      @board.layout.each{|row| row.length.should == 19}
    end

    it "should create the previous board with the default dimensions" do
      @board.previous_layout.length.should == 19
      @board.previous_layout.each{|row| row.length.should == 19}
    end

    it "should initialize the board" do
      @board.layout.each{|row| row.each{|cell| cell.should == :empty}}
    end

    it "should initialize the previous board" do
      @board.previous_layout.each{|row| row.each{|cell| cell.should == :empty}}
    end

    describe "with `size` given" do
      before :each do
        @board = Go::Board.new(13)
      end

      it "should store the given board size" do
        @board.size.should == 13
      end

      it "should create the board with the given dimensions" do
        @board.layout.length.should == 13
        @board.layout.each{|row| row.length.should == 13}
      end

      it "should create the previous board with the given dimensions" do
        @board.previous_layout.length.should == 13
        @board.previous_layout.each{|row| row.length.should == 13}
      end
    end
  end

  describe "#reset" do
    it "should initialize the board" do
      @board.place_stone(0, 0, :white)
      @board.reset
      @board.layout.each{|row| row.each{|cell| cell.should == :empty}}
    end

    it "should initialize the previous board" do
      @board.place_stone(0, 0, :white)
      @board.reset
      @board.previous_layout.each{|row| row.each{|cell| cell.should == :empty}}
    end
  end

  describe "#place_stone" do
    it "should raise `UnknownStoneColor` when `color` isn't black/white" do
      lambda{@board.place_stone(0, 0, :purple)}.should raise_error Go::UnknownStoneColor
    end

    it "should not raise `UnknownStoneColor` when `color is black/white" do
      lambda{@boad.place_stone(0, 0, :white)}.should_not raise_error Go::UnknownStoneColor
      lambda{@boad.place_stone(0, 0, :black)}.should_not raise_error Go::UnknownStoneColor
    end

    it "should raise `NonEmptySpace` when stone is placed on a non-empty cell" do
      @board.place_stone(0, 0, :white)
      lambda{@board.place_stone(0, 0, :white)}.should raise_error Go::NonEmptySpace
    end

    it "should not raise `NonEmptySpace` when stone is placed on a empty cell" do
      lambda{@board.place_stone(0, 0, :white)}.should_not raise_error Go::NonEmptySpace
    end

    it "should raise `KoViolation` when Ko is violated" do
      @board.place_stone(0, 0, :white)
      @board.remove_stone(0, 0)
      lambda{@board.place_stone(0, 0, :white)}.should raise_error Go::KoViolation
    end

    it "should copy the current layout into the previous layout" do
      @board.place_stone(0, 0, :white)
      @board.previous_layout[0][0].should == :empty
      @board.place_stone(0, 1, :white)
      @board.previous_layout[0][0].should == :white
      @board.previous_layout[0][1].should == :empty
    end

    it "should place the stone on the board" do
      @board.place_stone(0, 0, :white)
      @board.layout[0][0].should == :white
    end
  end  

  describe "#remove_stone" do
    it "should raise `EmptySpace` when attempting to remove a stone that doesn't exist" do
      lambda{@board.remove_stone(0, 0)}.should raise_error Go::EmptySpace
    end

    it "should copy the current layout into the previous layout" do
      @board.place_stone(0, 0, :white)
      @board.remove_stone(0, 0,)
      @board.previous_layout[0][0].should == :white
    end

    it "should remove requested stone" do
      @board.place_stone(0, 0, :white)
      @board.remove_stone(0, 0)
      @board.layout[0][0].should == :empty
    end
  end

  describe "#sync_previous_layout" do
    it "should copy layout into previous layout" do
      @board.place_stone(0, 0, :white)
      @board.sync_previous_layout
      @board.previous_layout.should == @board.layout
    end
  end

  describe "#groups" do
    before :each do
      @board.place_stone(0, 0, :white)
      @board.place_stone(1, 0, :white)
      @board.place_stone(1, 1, :white)
      @board.place_stone(1, 2, :white)
      @board.place_stone(0, 1, :black)
      @board.place_stone(0, 2, :black)
      @board.place_stone(0, 4, :black)

      @groups = @board.groups
    end

    it "should return the correct number of group" do
      @groups.length.should == 3
    end

    it "should correctly report stone groupings" do
      @groups.should include(
        [
          {:row => 0, :col => 0},
          {:row => 1, :col => 0},
          {:row => 1, :col => 1},
          {:row => 1, :col => 2}
        ]
      )

      @groups.should include(
        [
          {:row => 0, :col => 1},
          {:row => 0, :col => 2}
        ]
      )

      @groups.should include(
        [
          {:row => 0, :col => 4}
        ]
      )
    end

    describe "with `board` given" do
      before :each do
        @groups = @board.groups(@board.previous_layout)
      end

      it "should return the correct number of group" do
        @groups.length.should == 2
      end

      it "should correctly report stone groupings" do
        @groups.should include(
          [
            {:row => 0, :col => 0},
            {:row => 1, :col => 0},
            {:row => 1, :col => 1},
            {:row => 1, :col => 2}
          ]
        )

        @groups.should include(
          [
            {:row => 0, :col => 1},
            {:row => 0, :col => 2}
          ]
        )
      end
    end
  end

  describe "#liberties_for" do
    before :each do
      @board.place_stone(0, 0, :white)
      @board.place_stone(1, 0, :white)
      @board.place_stone(1, 1, :white)
      @board.place_stone(1, 2, :white)
      @board.place_stone(0, 1, :black)
      @board.place_stone(0, 2, :black)
      @board.place_stone(0, 4, :black)

      @groups = @board.groups
    end

    it "should return the correct number of liberties for a group" do
      @board.liberties_for(@groups[0]).should == 4
      @board.liberties_for(@groups[1]).should == 1
      @board.liberties_for(@groups[2]).should == 3
    end

    describe "with `board` given" do
      before :each do
        @groups = @board.groups(@board.previous_layout)
      end

      it "should return the correct number of liberties for a group" do
        @board.liberties_for(@groups[0], @board.previous_layout).should == 4
        @board.liberties_for(@groups[1], @board.previous_layout).should == 1
      end
    end
  end
end
