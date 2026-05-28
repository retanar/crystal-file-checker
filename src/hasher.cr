require "digest/sha256"

class Hasher
  def initialize(paths : Array(String))
    @hasher = Digest::SHA256.new
    @paths = paths
  end

  def hex_hash_file(path : Path | String)
    @hasher.reset.file(path).hexfinal
  end

  def write_single(path : Path | String, output : IO)
    output << hex_hash_file(path) << "  " << Path.posix(path).normalize << '\n'
  end

  # Main method. Output should be compatible with sha256sum at least in the first iteration.
  def process_all(output : IO)
    @paths.each do |path|
      if File.file?(path)
        write_single(path, output)
      elsif File.directory?(path)
        # tree walk
        Dir.glob("#{path}/**/*", match: File::MatchOptions::All) do |nested_path|
          next if File.directory?(nested_path)
          write_single(nested_path, output)
        end
      else
        STDERR.puts "#{path} is neither file, nor directory, can't work with it."
      end
    end
  end
end
