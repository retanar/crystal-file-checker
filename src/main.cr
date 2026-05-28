require "option_parser"

require "./hasher"

enum ProgramMode
  Help
  Hash
end

files_arg = nil
out_arg = STDOUT

program_mode = ProgramMode::Help

parser = OptionParser.parse do |parser|
  parser.banner = "File hasher and checker."

  parser.on("hash", "Produce a hashfile with hash of the passed file or all files in the dir. Defaults to current dir.") do
    parser.banner = "Usage: hash [path]"
    program_mode = ProgramMode::Hash
  end

  parser.on("help", "Print help.") do
    run_help(parser)
  end

  parser.on("-o PATH", "--output PATH", "Output file") do |path|
    out_arg = File.new(path, "w")
  end

  parser.unknown_args do |args|
    if args.size == 0
      STDERR.puts "Expected path to hash."
      exit
    end

    files_arg = args
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

def run_hash(input_path, output = STDOUT)
  if input_path.nil?
    STDERR.puts "Expected path to hash."
    return
  else
    hasher = Hasher.new(input_path)
    hasher.process_all(output)
  end
end

case program_mode
in .help?
  run_help(parser)
in .hash?
  run_hash(files_arg, out_arg)
end
