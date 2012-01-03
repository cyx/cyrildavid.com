class Frank
  def self.get(path, &block)
    handlers["GET"] << [matcher(path), block]
  end

  def self.post(path, &block)
    handlers["POST"] << [matcher(path), block]
  end

  def self.put(path, &block)
    handlers["PUT"] << [matcher(path), block]
  end

  def self.delete(path, &block)
    handlers["DELETE"] << [matcher(path), block]
  end

  def self.matcher(path)
    # handle the case where the path has a variable
    # e.g. /post/:id
    re = path.gsub(/\:[^\/]+/, "([^\\/]+)")

    %r{\A#{re}\z}
  end

  def self.handlers
    @handlers ||= Hash.new { |h, k| h[k] = [] }
  end

  def self.call(env)
    res = Rack::Response.new

    handlers[env["REQUEST_METHOD"]].each do |matcher, block|
      if match = env["PATH_INFO"].match(matcher)
        break res.write(block.call(*match.captures))
      end
    end

    res.status = 404 if res.empty?
    res.finish
  end
end