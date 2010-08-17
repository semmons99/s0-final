require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'board'

describe "Board" do
  before :each do
    @board = Board.new
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
        @board = Board.new(13)
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
      # TODO replace #instance_variable_get once #place_stone is implemented
      @board.instance_variable_get(:@layout)[0][0] = :white
      @board.reset
      @board.layout.each{|row| row.each{|cell| cell.should == :empty}}
    end

    it "should initialize the previous board" do
      # TODO replace #instance_variable_get once #place_stone is implemented
      @board.instance_variable_get(:@previous_layout)[0][0] = :white
      @board.reset
      @board.previous_layout.each{|row| row.each{|cell| cell.should == :empty}}
    end
  end
end
