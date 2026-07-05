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

  # Adds all new files and hashes to the FileHashMap.
  # Output should be compatible with sha256sum at least in the first iteration.
  # Skips files already existing in the FileHashMap (hashfile).
  def add_all(paths)
    paths.each do |path|
      if File.file?(path)
        add_single(path)
      elsif File.directory?(path)
        # tree walk
        Dir.glob("#{path}/**/*", match: File::MatchOptions::All) do |nested_path|
          next if File.directory?(nested_path)
          add_single(nested_path)
        end
      else
        logerr "#{path} is neither file, nor directory, can't work with it."
      end
    end
  end

  def add_single(path)
    return if @file_map.find_by_path(FileHashMap.normalize_s(path))
    @file_map.add(path, hash_file(path))
  end

  def check_hashfile
    @file_map.each do |entry|
      recorded_hash = entry.hash
      filename = entry.path

      if !File.file?(filename)
        log "ERR Does not exist  #{filename}"
        next
      end

      calculated_hash = hash_file(filename)
      if recorded_hash != calculated_hash
        log "ERR Mismatch  #{filename}"
      else
        log "OK  #{filename}"
      end
    end
  end

  def save_hashfile(io = @hashfile)
    io.seek(0) unless io == STDOUT
    @file_map.serialize(io)
  end
end
