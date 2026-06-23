require "digest/sha256"

class Hasher
  @hasher = Digest::SHA256.new

  def initialize(@hashfile : IO)
    @file_map = if @hashfile != STDOUT
                  FileHashMap.deserialize(@hashfile)
                else
                  FileHashMap.new
                end
  end

  def hash_file(path)
    @hasher.reset.file(path).final
  end

  # def hex_hash_file(path)
  #   hash_file.hexstring
  # end

  # Adds all new files to the FileHashMap
  # Output should be compatible with sha256sum at least in the first iteration.
  # Skips files already existing in the FileHashMap (hashfile). TODO: doesn't seem to work
  def hash_all(paths)
    paths.each do |path|
      if File.file?(path)
        next if @file_map.find_by_path(Path.posix(path).normalize)
        @file_map.add(path, hash_file(path))
      elsif File.directory?(path)
        # tree walk
        Dir.glob("#{path}/**/*", match: File::MatchOptions::All) do |nested_path|
          next if File.directory?(nested_path)
          next if @file_map.find_by_path(Path.posix(nested_path).normalize)

          @file_map.add(nested_path, hash_file(nested_path))
        end
      else
        STDERR.puts "#{path} is neither file, nor directory, can't work with it."
      end
    end
  end

  # TODO
  def check_hashfile(output = STDOUT)
    # return
    @file_map.each do |entry|
      recorded_hash = entry.hash
      filename = entry.path

      if !File.file?(filename)
        output.puts "ERR Does not exist  #{filename}"
        next
      end

      calculated_hash = hash_file(filename)
      if recorded_hash != calculated_hash
        output << "ERR Mismatch  "
      else
        output << "OK  "
      end

      output.puts filename
    end
    output.flush
  end

  def save_hashfile(io = @hashfile)
    io.seek(0) unless io == STDOUT
    @file_map.serialize(io)
  end
end
