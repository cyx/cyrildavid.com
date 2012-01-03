module Cuba::Helpers
  def taglist(tags)
    ret = ""

    tags.each do |tag|
      ret << %{<a class='label' href='/articles/tagged/#{tag}'>#{tag}</a>\n}
    end

    ret
  end

  def format_date(date)
    date.strftime("%Y.%m.%d")
  end
end