Feature: s0-exam
  In order to pass RMU Session 0
  As a RMU Student
  I want to complete the final exam

  Scenario: Playing a game of Go
    Given A friend and I start a game
    When we make the following moves:
     |0 0|
     |0 1|
     |1 0|
     |5 5|
     |1 1|
     |5 6|
     |1 2|
     |5 7|
     |0 2|
    Then white should have captured 1
    And black should have captured 0
    And I should see:
     |w . w . . . . . . . . . . . . . . . .|
     |w w w . . . . . . . . . . . . . . . .|
     |. . . . . . . . . . . . . . . . . . .|
     |. . . . . . . . . . . . . . . . . . .|
     |. . . . . . . . . . . . . . . . . . .|
     |. . . . . b b b . . . . . . . . . . .|
     |. . . . . . . . . . . . . . . . . . .|
     |. . . . . . . . . . . . . . . . . . .|
     |. . . . . . . . . . . . . . . . . . .|
     |. . . . . . . . . . . . . . . . . . .|
     |. . . . . . . . . . . . . . . . . . .|
     |. . . . . . . . . . . . . . . . . . .|
     |. . . . . . . . . . . . . . . . . . .|
     |. . . . . . . . . . . . . . . . . . .|
     |. . . . . . . . . . . . . . . . . . .|
     |. . . . . . . . . . . . . . . . . . .|
     |. . . . . . . . . . . . . . . . . . .|
     |. . . . . . . . . . . . . . . . . . .|
     |. . . . . . . . . . . . . . . . . . .|
