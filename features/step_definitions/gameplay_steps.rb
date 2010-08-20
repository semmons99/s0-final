Given /^A friend and I start a game$/ do
  @game = Go.new_game
end

When /^we make the following moves:$/ do |moves|
  @captured = {"white" => 0, "black" => 0}
  moves.raw.each do |move|
    row, col = move.first.split(" ").map{|m| m.to_i}
    color = @game.turn.to_s
    @captured[color] += @game.place_stone(row, col)
  end
end

Then /^(.*) should have captured (\d+)$/ do |color, n|
  @captured[color].should == n.to_i
end

Then /^I should see:$/ do |output|
  output = output.raw.map{|row|
    row.join(" ")
  }.join("\n")
  @game.pretty_board.should == output
end
