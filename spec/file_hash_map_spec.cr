require "./helper"

describe FileHashMap do
  test_hash = Slice(UInt8).new(32, &.to_u8)
  memfile = IO::Memory.new(1024)

  it "deserializes its output" do
    memfile.clear
    fhm = FileHashMap.new
    (1..4).each { |i| fhm.add("path#{i}", test_hash) }

    fhm.serialize(memfile)
    memfile.size.should be > 0

    memfile.seek(0)
    fhm2 = FileHashMap.deserialize(memfile)
    fhm.zip(fhm2.to_a) do |e1, e2|
      e1.hash.should eq e2.hash
      e1.path.should eq e2.path
    end
  end

  it "matches the serialized output with expected" do
    memfile.clear
    fhm = FileHashMap.new
    fhm.add("./file1.txt", test_hash)
    fhm.add("file2.txt", test_hash)

    fhm.serialize(memfile)
    memfile.to_s.should eq "#{test_hash.hexstring}  file1.txt\n#{test_hash.hexstring}  file2.txt\n"
  end
end
