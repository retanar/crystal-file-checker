require "./hasher"
require "./options"
require "./parser"
require "./file_hash_map"
require "./log"

def run_hash
  if Options.input_paths.empty?
    Options.input_paths = ["."]
  end

  hfpath = Options.hashfile_path
  unless hfpath.empty?
    mode = File.file?(hfpath) ? "r+" : "w+"
    Options.hashfile = File.new(hfpath, mode)
  end

  hasher = Hasher.new(Options.hashfile, Options.hashfile_path, Options.excluded_regex)
  hasher.add_all(Options.input_paths, Options.rehash?)
  # should append new findings instead of serializing the entire thing
  hasher.save_hashfile
end

def run_check
  if Options.hashfile_path.empty?
    logerr "Expected a -f/--hashfile to check."
    return
  end
  Options.hashfile = File.new(Options.hashfile_path, "r")
  hasher = Hasher.new(Options.hashfile, Options.hashfile_path)
  hasher.check_all
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
