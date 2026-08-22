require "spec"
require "../src/file_hash_map"
require "../src/hasher"

SpecOut = IO::Memory.new(10240)
SpecErr = IO::Memory.new(10240)

def log(obj)
  SpecOut.puts obj
end

def logerr(obj)
  SpecErr.puts obj
end
