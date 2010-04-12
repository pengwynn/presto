# Enables support for SASS template reloading for rack.
# Store SASS files by default within 'app/stylesheets/sass'
# See http://nex-3.com/posts/88-sass-supports-rack for more details.

module SassInitializer
  def self.registered(app)
    require 'sass/plugin/rack'
    Sass::Plugin.options[:template_location] = Padrino.root("app/stylesheets")
    Sass::Plugin.options[:css_location] = Padrino.root("public/stylesheets")
    app.use Sass::Plugin::Rack
  end
end
