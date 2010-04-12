## [Nesta](http://github.com/gma/nesta) + [Padrino](http://www.padrinorb.com) = Presto

Presto is an effort to play around with Padrino, the new [Sinatra](http://www.sinatrarb.com/)-based Ruby web framework and make NestaCMS mountable as a sub-app.

To mount in Padrino:

    # apps.rb
    Padrino.mount("presto", :app_file => "presto/app/app.rb").to("/blog")
    
