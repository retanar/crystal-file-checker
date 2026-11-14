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
