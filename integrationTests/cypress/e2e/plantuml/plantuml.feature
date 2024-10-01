Feature: PlantUML
Background:
  Given the user opens the dogu start page

Scenario: PlantUML gets opened
  Then plantuml is shown

Scenario: Warp menu exists
  Then warp menu exists

Scenario: Change existing diagram
  And diagram type is set to ascii
  When diagram gets edited
  Then diagram matches

Scenario: Export diagram
  When diagram gets exported
  Then diagram matches existing .puml

Scenario: picture link
  When picture link gets clicked
  Then picture gets downloaded
