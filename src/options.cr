require "./program_mode"

# To test STDOUT and STDERR I can do two options
# 1. Create own variables representing out and err,
#    and replace everything in the classes to print to them.
#    Pros: very easy testing.
# 2. Replace out and err global constants in tests.
#    Pros: not touching anything inside. Cons: have to consider test framework itself trying to print.

# So far I want to use this only in main, to not have classes depend on this
class Options
  class_property mode : ProgramMode = ProgramMode::Help
  class_property input_paths : Array(String) = Array(String).new
  class_property hashfile : IO = STDOUT
  class_property? rehash = false
end
