require "option_parser"

require "./options"

PARSER = OptionParser.new do |op|
  op.banner = "File hasher and checker."

  op.on("hash", "Create or update a hashfile with hashes of passed files and files in dirs. Defaults to current dir.") do
    op.banner = "Usage: hash [path...]"
    Options.mode = ProgramMode::Hash

    # TODO finish the options and then UI for this
    op.on("-hf PATH", "--hashfile PATH", "Path to a new or existing hashfile to write file hashes to. If ommitted, prints to STDOUT.") do |path|
      Options.hashfile = File.new(path, "a+")
    end

    op.on("--rehash", "Also check existing hashes. On any differing hash, replace it and print notification about the mismatch.") do
      Options.rehash = true
    end
  end

  op.on("help", "Print help. Same as -h without a subcommand.") do
    # as a subcommand, it would print options only for help subcommand if run_help was called now
    Options.mode = ProgramMode::Help
  end

  op.on("check", "Checks all entries in a hashfile.") do
    Options.mode = ProgramMode::Check
  end

  op.on("-h", "--help", "Print help for a given subcommand") do
    run_help(op)
  end

  op.unknown_args do |args|
    Options.input_paths = args
  end

  op.invalid_option do |opt|
    STDERR.puts "Invalid option #{opt}."
    run_help(op)
  end
end

def run_help(parser = PARSER)
  puts parser
  exit
end
