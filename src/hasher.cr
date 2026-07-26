require "digest/sha256"

# TODO maybe this needs a third mode for hashfile maintenance

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
  def add_all(paths, rehash = false)
    paths.each do |path|
      if File.file?(path)
        add_single(path, rehash)
      elsif File.directory?(path)
        Dir.glob("#{path}/**/*", match: File::MatchOptions::All) do |nested_path|
          next if File.directory?(nested_path)
          add_single(nested_path, rehash)
        end
      else
        logerr "#{path} is neither file, nor directory, can't work with it."
      end
    end
  end

  def add_single(path, rehash = false)
    # TODO fixme double search
    path = FileHashMap.normalize_s(path)
    stored = @file_map.find_by_path(path)
    if !rehash || !stored
      @file_map.add(path, -> { hash_file(path) })
      return
    end

    # Exists but matches - nothing. Mismatch - update.
    case result = check_single(path, stored.hash)
    when CheckResult::NotExist
      log "ERR Does not exist  #{path}"
      @file_map.delete(path)
    when CheckResult::Mismatch
      log "ERR Mismatch, stored #{stored.hash.hexstring}, actual #{result.calculated_hash.hexstring}  #{path}"
      @file_map.add_force(path, result.calculated_hash)
    end
  end

  def check_all
    @file_map.each do |entry|
      stored_hash = entry.hash
      path = entry.path

      case result = check_single(path, stored_hash)
      when CheckResult::NotExist then log "ERR Does not exist  #{path}"
      when CheckResult::Mismatch then log "ERR Mismatch, stored #{stored_hash.hexstring}, actual #{result.calculated_hash.hexstring}  #{path}"
      when CheckResult::Ok       then log "OK  #{path}"
      end
    end
  end

  def check_single(path, stored_hash)
    return CheckResult::NotExist.new unless File.file?(path)
    calculated_hash = hash_file(path)
    return CheckResult::Mismatch.new(calculated_hash) unless stored_hash == calculated_hash
    CheckResult::Ok.new
  end

  def save_hashfile(io = @hashfile)
    io.seek(0) unless io == STDOUT
    @file_map.serialize(io)
  end

  class CheckResult
    class Ok
    end

    class NotExist
    end

    class Mismatch
      getter calculated_hash : Bytes

      def initialize(@calculated_hash)
      end
    end
  end
end
