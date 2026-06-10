require "./program_mode"

# So far I want to use this only in main, to not have classes depend on this
class Options
  class_property mode : ProgramMode = ProgramMode::Help
  class_property input_paths : Array(String) = Array(String).new
  class_property output : IO = STDOUT
end
