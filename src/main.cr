require "option_parser"

require "./hasher"
require "./options"

parser = OptionParser.parse do |parser|
  parser.banner = "File hasher and checker."

  parser.on("hash", "Produce a hashfile with hash of the passed file or all files in the dir. Defaults to current dir.") do
    parser.banner = "Usage: hash [path]"
    Options.mode = ProgramMode::Hash
  end

  parser.on("help", "Print help.") do
    # because this is a subcommand, it wouldn't print any meaningful help if called at this point
    Options.mode = ProgramMode::Help
  end

  parser.on("-o PATH", "--output PATH", "Output file") do |path|
    Options.output = File.new(path, "w")
  end

  parser.unknown_args do |args|
    Options.input_paths = args
  end

  parser.invalid_option do |opt|
    STDERR.puts "Invalid option #{opt}."
    run_help(parser)
  end
end

def run_help(parser)
  puts parser
  exit
end

def run_hash
  if Options.input_paths.empty?
    STDERR.puts "Expected path to hash."
    return
  end

  hasher = Hasher.new(Options.input_paths)
  hasher.process_all(Options.output)
end

case Options.mode
in .help?
  run_help(parser)
in .hash?
  run_hash
end
