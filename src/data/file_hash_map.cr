require "./entry"
require "./file_map"
require "./number_optimized_map"

# pathes should be normalized to not duplicate entries
class FileHashMap
  @state_files = FileMap.new
  @state_hashes = NumberOptimizedMap.new

  # Returns Entry only if it was added or modified
  def add(path, hash) : Entry?
    stored = @state_files.find(path)

    if !stored
      entry = Entry.new(path, hash)
      add_unverified(entry)
      entry
    elsif stored.hash != hash
      @state_hashes.delete(stored)
      stored.hash = hash
      @state_hashes.add(stored)
      stored
    end
  end

  def add_unverified(entry)
    @state_files.add(entry)
    @state_hashes.add(entry)
  end

  def find_by_path(path)
    @state_files.find(path)
  end

  def find_by_hash(hash)
    @state_hashes.find(hash)
  end

  def sorted
    @state_files.sorted
  end

  def self.deserialize(io : IO)
    fhm = new
    io.each_line do |line|
      next if line.blank?

      unless line[64..65]? == "  "
        logerr "Invalid hashfile, no spaces at expected positions on line #{line}"
        exit
      end
      entry = Entry.parse_string(line)
      fhm.add_unverified(entry)
    end
    fhm
  rescue ArgumentError
    logerr "Invalid hashfile, couldn't convert the hash hexstring"
    exit
  end

  def serialize(io : IO)
    sorted.each do |entry|
      io.puts entry
    end
    io.flush
  end
end
