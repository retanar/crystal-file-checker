# But a wrapper around Hash
class FileMap
  @state = Hash(String, Entry).new(initial_capacity: 64)

  def add(entry)
    @state[entry.path] = entry
  end

  def find(path)
    @state[path]?
  end

  def sorted
    @state.values.unstable_sort_by!(&.path)
  end
end
