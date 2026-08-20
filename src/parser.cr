require "option_parser"

PARSER = OptionParser.new do |op|
  op.banner = "File hasher and checker."

  op.on("hash", "Create or update a hashfile with hashes of passed files and files in dirs. Defaults to current dir.") do
    op.banner = "Usage: hash [path...]"
    Options.mode = ProgramMode::Hash

    op.on("-f PATH", "--hashfile PATH", "Path to a new or existing hashfile to write file hashes to. If ommitted, prints to STDOUT.") do |path|
      path_norm = FileHashMap.normalize_s(path)
      Options.hashfile_path = path_norm
    end

    op.on("--rehash", "Also check existing hashes. On any differing hash, replace it and print notification about the mismatch.") do
      Options.rehash = true
    end

    op.on("--exclude REGEX", "Skip files, relative paths of which fully match the regex.") do |regex|
      Options.excluded_regex = Regex.new(regex)
    end

    # TODO include hidden, quiet
  end

  op.on("help", "Print help. Same as -h without a subcommand.") do
    # as a subcommand, it would print options only for help subcommand if run_help was called now
    Options.mode = ProgramMode::Help
  end

  op.on("check", "Checks all entries in a hashfile.") do
    Options.mode = ProgramMode::Check

    op.on("-f PATH", "--hashfile PATH", "Path to an existing hashfile to check") do |path|
      path_norm = FileHashMap.normalize_s(path)
      Options.hashfile_path = path_norm
    end

    # TODO option remove incorrect from hashfile, only errors
  end

  op.on("-h", "--help", "Print help for a given subcommand") do
    run_help(op)
  end

  op.unknown_args do |args|
    Options.input_paths = args
  end

  op.invalid_option do |opt|
    logerr "Invalid option #{opt}."
    run_help(op)
  end
end

def run_help(parser = PARSER)
  log parser
  exit
end
