require 'sinatra'
require 'sinatra/reloader' if development?
require 'lib/includes_packer'
require 'rainpress'


class PackCSS < Sinatra::Base

  include IncludesPacker

  get '/' do
    content_type 'text/stylesheet', :charset => 'utf-8'
    return "" unless package_valid?
  
    package_etag
  
    pack(params[:host], params[:include].split(',')) { |text| Rainpress.compress(text.force_encoding('UTF-8')) }
  end
end
