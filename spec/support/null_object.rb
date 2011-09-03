class NullObject
  def method_missing(method, *args, &block)
    # ignore
  end
end
