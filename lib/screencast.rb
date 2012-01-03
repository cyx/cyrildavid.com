class ScreenCast
  include Comparable

  attr :title
  attr :date
  attr :thumbnail
  attr :embed_html

  def initialize(atts)
    @title      = atts[:title]
    @date       = atts[:date]
    @thumbnail  = atts[:thumbnail]
    @embed_html = atts[:embed_html]
  end

  def <=>(other)
    other.date <=> date
  end

  def self.all
    DB.screencasts.map { |atts| new(atts) }.sort
  end
end