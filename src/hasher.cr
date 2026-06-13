require "digest/sha256"

class Hasher
  def initialize
    @hasher = Digest::SHA256.new
  end

  def hex_hash_file(path : Path | String)
    @hasher.reset.file(path).hexfinal
  end

  def write_single(path : Path | String, output : IO)
    output << hex_hash_file(path) << "  " << Path.posix(path).normalize << '\n'
  end

  # Main method. Output should be compatible with sha256sum at least in the first iteration.
  def hash_all(paths : Array(String), output : IO)
    paths.each do |path|
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
    output.flush
  end

  def check_hashfile(path, output : IO)
    File.each_line(path) do |line|
      recorded_hash = line[0...64]
      filename = line[66..]

      if !File.file?(filename)
        output.puts "ERR Does not exist  #{filename}"
        next
      end

      calculated_hash = hex_hash_file(filename)
      if recorded_hash != calculated_hash
        output << "ERR Mismatch  "
      else
        output << "OK  "
      end

      output.puts filename
    end
    output.flush
  end
end
