require "./hasher"
require "./options"
require "./parser"

def run_hash
  if Options.input_paths.empty?
    Options.input_paths = ["."]
  end

  hasher = Hasher.new
  hasher.hash_all(Options.input_paths, Options.hashfile)
end

# add hashfile validation
def run_check
  if Options.input_paths.empty?
    STDERR.puts "Expected a hashfile to check."
    return
  end

  hashfile_path = Options.input_paths.first
  hasher = Hasher.new
  hasher.check_hashfile(hashfile_path)
end

PARSER.parse

case Options.mode
in .help?
  run_help
in .hash?
  run_hash
in .check?
  run_check
end

Options.hashfile.close
