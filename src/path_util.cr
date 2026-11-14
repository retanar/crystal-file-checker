class String
  def normalize
    Path.posix(self).normalize.to_s
  end
end
