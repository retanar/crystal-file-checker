# So far I want to use this only in main, to not have classes depend on this
class Options
  class_property mode : ProgramMode = ProgramMode::Help
  class_property input_paths : Array(String) = Array(String).new
  class_property excluded_regex : Regex? = nil
  class_property hashfile_path : String = ""
  class_property hashfile : IO? = nil
  class_property match_option : File::MatchOptions = File::MatchOptions::None
  class_property? rehash = false
end

enum ProgramMode
  Help
  Hash
  Check
end
