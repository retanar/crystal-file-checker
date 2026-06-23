require "./hasher"
require "./options"
require "./parser"
require "./file_hash_map"

def run_hash
  if Options.input_paths.empty?
    Options.input_paths = ["."]
  end

  hasher = Hasher.new(Options.hashfile)
  hasher.hash_all(Options.input_paths)
  # should append new findings instead of serializing the entire thing
  hasher.save_hashfile
end

def run_check
  if Options.input_paths.empty?
    STDERR.puts "Expected a hashfile to check."
    return
  end

  Options.hashfile = File.open(Options.input_paths.first)
  hasher = Hasher.new(Options.hashfile)
  hasher.check_hashfile
end

# Main execution

PARSER.parse

case Options.mode
in .help?
  run_help
in .hash?
  run_hash
in .check?
  run_check
end

Options.hashfile.close unless Options.hashfile == STDOUT
