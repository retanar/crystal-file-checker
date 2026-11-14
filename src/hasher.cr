require "digest/sha256"

# TODO maybe this needs a third mode for hashfile maintenance

class Hasher
  @hasher = Digest::SHA256.new

  def initialize(
    @hashfile : IO?,
    @hashfile_path : String,
    @dry_run : Bool = false,
    @match_option : File::MatchOptions = File::MatchOptions::None,
    @excluded_regex : Regex? = nil,
  )
    @fhm = @hashfile.try { |hf| FileHashMap.deserialize(hf) } || FileHashMap.new
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
        add_single(path.normalize, rehash)
      elsif File.directory?(path)
        Dir.glob("#{path}/**/*", match: @match_option) do |nested_path|
          next if File.directory?(nested_path)
          path_norm = nested_path.normalize
          next if excluded?(path_norm)
          add_single(path_norm, rehash)
        end
      else
        logerr "#{path} is neither a file nor a directory, can't work with it."
      end
    end
  end

  # path should be normalized already
  def add_single(path, rehash = false)
    stored = @fhm.find_by_path(path)

    if @dry_run
      log Entry.new(path, Bytes.new(32)) if !stored || rehash
      return
    end

    unless stored
      entry = @fhm.add(path, hash_file(path))
      log entry if entry
      return
    end

    return unless rehash

    # Exists but matches - nothing. Mismatch - update.
    case result = check_single(path, stored.hash)
    when CheckResult::NotExist
      log "ERR This code shouldn't usually trigger. Does not exist #{path}"
    when CheckResult::Mismatch
      log "Mismatch, rewrote stored #{stored.hash.hexstring}, with actual #{result.calculated_hash.hexstring}  #{path}"
      @fhm.add(path, result.calculated_hash)
    end
  end

  def excluded?(path)
    @excluded_regex.try do |regex|
      return true if path.matches_full?(regex)
    end
    path == @hashfile_path
  end

  def check_all
    @fhm.sorted.each do |entry|
      path = entry.path
      hash = entry.hash

      case result = check_single(path, hash)
      when CheckResult::NotExist then log "ERR Does not exist  #{path}"
      when CheckResult::Mismatch then log "ERR Mismatch, stored #{hash.hexstring}, actual #{result.calculated_hash.hexstring}  #{path}"
      when CheckResult::Ok       then log "OK  #{path}"
      end
    end
  end

  def check_single(path, stored_hash)
    return CheckResult::NotExist.new unless File.file?(path)
    calculated_hash = @dry_run ? stored_hash : hash_file(path)
    return CheckResult::Mismatch.new(calculated_hash) unless stored_hash == calculated_hash
    CheckResult::Ok.new
  end

  # Rewrites the hashfile completely
  def save_hashfile(io = @hashfile)
    if io && !@dry_run
      io.seek(0)
      @fhm.serialize(io)
    end
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
