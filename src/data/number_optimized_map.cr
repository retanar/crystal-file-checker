# Arrays of 256 nodes, node = Nil | Array(Entry) (one or more paths under one hash) | Array(Node)
class NumberOptimizedMap
  alias Entries = Array(Entry)
  alias Nodes = Array(Node?)

  class Node
    property value : Entries | Nodes

    def initialize(@value)
    end
  end

  @root = Nodes.new(256) { nil }

  # Pretty print
  def print(root = @root, tabc = 0)
    root.each_with_index do |node, i|
      next if node.nil?
      case val = node.as(Node).value
      in Entries
        log "#{" "*tabc}#{i.to_s(16)}: #{val.join("; ")}"
      in Nodes
        log "#{" "*tabc}#{i.to_s(16)}:"
        print(val, tabc + 2)
      end
    end
  end

  def add(entry : Entry, root = @root, level = 0)
    pos = entry.hash[level]
    node = root[pos]

    if node.nil?
      root[pos] = Node.new([entry])
      return
    end

    case val = node.as(Node).value
    in Entries
      if val[0].hash == entry.hash
        unless val.find(&.path.==(entry.path))
          val << entry
        end
      else
        # move old nodes down one level
        nodes = Nodes.new(256) { nil }
        nodes[val[0].hash[level + 1]] = root[pos]
        root[pos] = Node.new(nodes)

        # keep searching to add, in case (pos+1)'s byte is the same again
        # bad case is having many nested branches for too big prefixes
        add(entry, nodes, level + 1)
      end
    in Nodes
      add(entry, val, level + 1)
    end
  end

  def find(hash, root = @root, level = 0)
    pos = hash[level]
    node = root[pos]
    return if node.nil?

    case val = node.as(Node).value
    in Entries
      val if val[0].hash == hash
    in Nodes
      find(hash, val, level + 1)
    end
  end

  def delete(entry, root = @root, level = 0)
    pos = entry.hash[level]
    node = root[pos]
    return if node.nil?

    case val = node.as(Node).value
    in Entries
      return unless val[0].hash == entry.hash
      if val.size <= 1
        # this can end up with empty branches, or nested branches for one entry
        # possible efficient solution is counting deletions/creations, then rechecking everything after a threshold
        root[pos] = nil
      else
        val.delete(entry)
      end
    in Nodes
      delete(entry, val, level + 1)
    end
  end
end
