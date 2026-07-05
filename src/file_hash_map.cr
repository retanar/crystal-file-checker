class FileHashMap
  class Entry
    property path : String
    property hash : Bytes

    def initialize(@path, @hash)
    end

    def ==(other : self)
      @path == other.path && @hash == other.hash
    end

    def self.parse_string(s)
      hash = s[...64].hexbytes
      path = s[66..]
      Entry.new(path, hash)
    end

    # Made to support `IO.<<`
    def to_s(io)
      io << @hash.hexstring << "  " << @path
    end
  end

  include Enumerable(Entry)

  @state = Array(Entry).new

  def initialize
  end

  # TODO: overwrite? parameter
  # Checks if exists and normalizes the path before adding
  def add(path, hash)
    path_norm = self.class.normalize_s(path)
    stored = find_by_path(path_norm)
    if stored
      stored.hash = hash
    else
      add_unverified(Entry.new(path_norm, hash))
    end
  end

  # Doesn't do the checks `add` does
  def add_unverified(entry)
    @state.push(entry)
  end

  def delete(path)
    @state.reject! { |entry| entry.path == path }
  end

  def find_by_path(path)
    find { |entry| entry.path == path }
  end

  def find_by_hash(hash)
    find { |entry| entry.hash == hash }
  end

  def each(&)
    @state.each do |entry|
      yield entry
    end
  end

  def self.normalize_s(s)
    Path.posix(s).normalize.to_s
  end

  def self.deserialize(io : IO)
    fhm = new
    io.each_line do |line|
      fhm.add_unverified(Entry.parse_string(line))
    end
    fhm
  end

  def serialize(io : IO)
    each do |entry|
      io.puts entry
    end
    io.flush
  end
end
