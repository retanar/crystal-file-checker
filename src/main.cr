require "./data/file_hash_map"
require "./hasher"
require "./log"
require "./options"
require "./parser"
require "./path_util"

def run_hash
  if Options.input_paths.empty?
    Options.input_paths = ["."]
  end

  hfpath = Options.hashfile_path
  unless hfpath.empty?
    mode = File.file?(hfpath) ? "r+" : "w+"
    Options.hashfile = File.new(hfpath, mode)
  end

  hasher = Hasher.new(
    hashfile: Options.hashfile,
    hashfile_path: Options.hashfile_path,
    dry_run: Options.dry_run?,
    match_option: Options.match_option,
    excluded_regex: Options.excluded_regex,
  )
  hasher.add_all(Options.input_paths, Options.rehash?)
  hasher.save_hashfile
end

def run_check
  if Options.hashfile_path.empty?
    logerr "Expected a -f/--hashfile to check."
    return
  end
  Options.hashfile = File.new(Options.hashfile_path, "r")
  hasher = Hasher.new(
    hashfile: Options.hashfile,
    hashfile_path: Options.hashfile_path,
    dry_run: Options.dry_run?,
  )
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

Options.hashfile.try &.close
