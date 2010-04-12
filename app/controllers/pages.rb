Presto.controllers :pages do
  # get :index, :map => "/foo/bar" do
  #   session[:foo] = "bar"
  #   render 'index'
  # end

  # get :sample, :map => "/sample/url", :respond_to => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  # get :foo, :with => :id do
  #   "Maps to url '/foo/#{params[:id]}'"
  # end

  # get "/example" do
  #   "Hello world!"
  # end
  
  before do
    @menu_items = Page.menu_items
    @title = Nesta::Config.title
    @subtitle = Nesta::Config.subtitle
    @keywords = Nesta::Config.keywords
    @description = Nesta::Config.description
    @author = Nesta::Config.author
    @google_analytics_code = Nesta::Config.google_analytics_code
    @heading = @title
    
  end

  get :index, :map => '/' do

    @title = "#{@title} - #{@subtitle}"
    @articles = Page.find_articles[0..7]
    @body_class = "home"
    render 'pages/index'
  end
  
  get :feed, :map => '/feed' do
    content_type :xml, :charset => "utf-8"
    @articles = Page.find_articles.select { |a| a.date }[0..9]
    render 'pages/atom'
  end
  
  get :sitemap, :map => "/sitemap.xml" do
    content_type :xml, :charset => "utf-8"
    @pages = Page.find_all
    @last = @pages.map { |page| page.last_modified }.inject do |latest, page|
      (page > latest) ? page : latest
    end
    render 'pages/sitemap'
  end
  
  get :attachments, :map => '/attachments/{:filename,(\w|\-|\.)}' do
    puts params[:filename]
    file = File.join(
        Nesta::Config.attachment_path, params[:filename])
    send_file(file, :disposition => nil)
  end
  
  get :catchall, :map => '*splat' do
    @page = Page.find_by_path(File.join(params[:splat]))
    raise Sinatra::NotFound if @page.nil?
    @title = @page.title
    @description = @page.description
    @keywords = @page.keywords
    render 'pages/page'
  end

end