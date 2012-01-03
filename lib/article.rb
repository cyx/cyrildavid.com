class Article
  include Comparable

  attr :title
  attr :date
  attr :file
  attr :data
  attr :tags

  def initialize(atts)
    @title = atts[:title]
    @date  = atts[:date]
    @tags  = atts[:tags].split(/\s*,\s*/)
    @file  = atts[:file]
    @data  = File.read(root("articles", file))
  end

  def content
    if file.end_with?(".markdown")
      BlueCloth.new(data).to_html
    else
      data
    end
  end

  def <=>(other)
    other.date <=> date
  end

  def slug
    date.strftime("%Y/%m/%d/#{self.class.slugged(title)}")
  end

  def self.all
    DB.articles.map { |atts| new(atts) }.sort
  end

  def self.slugged(str)
    str.downcase.gsub(/[^a-z]/i, "-")
  end

  def self.[](slug)
    all.detect { |article| slugged(article.title) == slug }
  end
end