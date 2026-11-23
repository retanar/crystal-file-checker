require "./data/file_hash_map"
require "./hasher"
require "./log"
require "./options"
require "./parser"
require "./path_util"

def run_hash
  Options.input_paths = ["."] if Options.input_paths.empty?
  hfpath = Options.hashfile_path
  hashfile : IO? = nil

  if !hfpath.empty? && File.file?(hfpath)
    hashfile = File.new(hfpath, "r")
  end

  hasher = Hasher.new(
    hashfile: hashfile,
    hashfile_path: Options.hashfile_path,
    dry_run: Options.dry_run?,
    match_option: Options.match_option,
    excluded_regex: Options.excluded_regex,
  )
  hashfile.try &.close
  hasher.add_all(Options.input_paths, Options.rehash?)

  if !hfpath.empty? && !Options.dry_run?
    File.open(hfpath, "w") do |hashfile|
      hasher.save_hashfile(hashfile)
    end
  end
end

def run_check
  hfpath = Options.hashfile_path
  if hfpath.empty? || !File.file?(hfpath)
    logerr "Expected a -f/--hashfile to check or provided file doesn't exist."
    return
  end
  hashfile = File.new(hfpath, "r")
  hasher = Hasher.new(
    hashfile: hashfile,
    hashfile_path: Options.hashfile_path,
    dry_run: Options.dry_run?,
  )
  hashfile.close
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
