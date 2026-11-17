# log verbose
# log imp-ortant
# log err-or

def log(obj)
  puts obj unless Options.quiet?
end

def logimp(obj)
  puts obj
end

def logerr(obj)
  STDERR.puts obj
end
