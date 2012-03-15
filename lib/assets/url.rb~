module Url
  def encode(id)
    url = ""
    index = id - adj(len(id))
    len(id).times do
      dm = index.divmod(base)
      url += chars[dm[1]]
      index = dm[0]
    end
    url.reverse
  end

  def decode(url)
    id = 0
    str = url.reverse
    len = str.length
    len.times do
      id *= base
      id += chars.index(str[-1])
      str.chop!
    end
    id + adj(len)
  end

  protected
  def chars
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-"
  end
  def base
    chars.length
  end
  def len(index)
    Math.log(index*(base - 1) + 1, base).floor
  end
  def adj(len)
    (base**len - 1).div(base - 1)
  end
end
