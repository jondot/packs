require 'sinatra'
require 'sinatra/reloader' if development?
require 'RMagick'
require 'digest/md5'


include Magick

class PackImg < Sinatra::Base

  get '/' do
    
    return "" unless params[:source]
  
    etag Digest::MD5.hexdigest("#{params[:source]}:#{params[:resize]}:#{params[:flip]}:#{params[:perspective]}:#{params[:rotate]}:#{params[:format]}:#{params[:quality]}:#{params[:version]}")
    img = Image.read(params[:source]).first
    
    ops = []
    ops << ->(image) { image }
    ops << ->(image) { image.resize_to_fit(*params[:resize].split('x'))} if params[:resize]
    ops << ->(image) { params[:flip] == 'vertical' ? image.flip : image.flop } if params[:flip]

    if params[:perspective]
      img.format = "png"
      img.virtual_pixel_method = Magick::TransparentVirtualPixelMethod
      ops << ->(image) { image.distort(Magick::PerspectiveDistortion, params[:perspective].split(',').collect{|x| x.to_f}) }
    end

    ops << ->(image) { image.rotate(params[:rotate].to_i) } if params[:rotate]

    res = ops.inject(img){|o,proc| proc.call(o)}
    
    res.format = params[:format] if params[:format]
    res.quality = params[:quality].to_i if params[:quality]
    
    content_type res.mime_type

    res.to_blob
  end

  error do
    env['sinatra.error']
  end
end


