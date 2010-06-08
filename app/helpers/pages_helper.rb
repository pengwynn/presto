# Helper methods defined here can be accessed in any controller or view in the application

Presto.helpers do
  
  def theme_partial(partial, options={})
    partial "themes/default/#{partial}", options
  end
  
  def nesta_atom_id_for_page(page)
    published = page.date.strftime('%Y-%m-%d')
    "tag:#{request.host},#{published}:#{page.abspath}"
  end
  
  def atom_id(page = nil)
    if page
      page.atom_id || nesta_atom_id_for_page(page)
    else
      "tag:#{request.host},2009:/"
    end
  end
  
  def url_for(page)
    File.join(base_url, page.path)
  end
  
  def base_url
    url = "http://#{request.host}"
    request.port == 80 ? url : url + ":#{request.port}"
  end
  
  def absolute_urls(text)
    text.gsub!(/(<a href=['"])\//, '\1' + base_url + '/')
    text
  end
  
  def format_date(date)
    date.strftime("%d %B %Y")
  end
  
end