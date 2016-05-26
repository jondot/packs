require 'sinatra'
require 'sinatra/reloader' if development?
require 'RMagick'
require 'digest/md5'

require 'net/http'
require 'uri'
require 'securerandom'

include Magick

# HTTP requester with redirection following
def http_fetch(uri_str, limit = 3)
  raise ArgumentError, 'HTTP redirect too deep' if limit <= 0

  uri = URI.parse(uri_str)
  request = Net::HTTP::Get.new(uri.path, {'User-Agent' => 'MetaBroadcast image resizer'})
  response = Net::HTTP.start(uri.host, uri.port) { |http| http.request(request) }

  case response
  when Net::HTTPRedirection then http_fetch(response['location'], limit - 1)
  else
    response
  end
end

class PackImg < Sinatra::Base

  get '/' do
    
    allowed = %w(source resize perspective profile)
    params.keep_if { |k,v| allowed.include? k.to_s }

    return "Invalid parameters. Required: \"source\"; allowed: #{allowed}" unless params[:source]
  
    etag Digest::MD5.hexdigest( params.values.sort.join(',') )


    begin
      response = http_fetch(params[:source])

      # If we got an error from the source, pass on the http error code and body
      if response.code.to_i >= 300
        status response.code
        response.body
      end

      # Attempt load the body as an image
      img = Image.from_blob(response.body)[0]

    rescue ArgumentError
      # redirect limit hit
      status 500
      return "Too many redirects fetching source image"
    rescue Magick::ImageMagickError
      # image load failed, probably not an image
      status 500
      return "No image at source"
    end
    
    ops = []
    ops << ->(image) { image }

    ops << ->(image) { image.resize_to_fit(*params[:resize].split('x'))} if params[:resize]

    ops << ->(image) { params[:flip] == 'vertical' ? image.flip : image.flop } if params[:flip]

    if params[:perspective]
      img.format = "png"
      img.virtual_pixel_method = Magick::TransparentVirtualPixelMethod
      ops << ->(image) { image.distort(Magick::PerspectiveDistortion, params[:perspective].split(',').collect{|x| x.to_f}) }
    end
    
    if params[:profile] == "monocrop"
      tempName = SecureRandom.hex
      img.write(tempName)
      # Not ideal, but RMagick doesn't seem to expose the right API to do all of the below
      system("convert #{tempName} -density 150 -threshold 60% -trim -resize 1024x576 -monochrome
          -transparent black -fill \"#EBEBEB\" -enhance -opaque white #{tempName}-monocropped")
      system("convert #{tempName}-monocropped -trim #{tempName}-monocropped")
      img = Image.read("#{tempName}-monocropped")[0]
      FileUtils.rm("#{tempName}-monocropped")
      FileUtils.rm("#{tempName}")
    end
    
    ops << ->(image) { image.rotate(params[:rotate].to_i) } if params[:rotate]

    res = ops.inject(img) {|o,proc| proc.call(o)}
    
    res.format = params[:format] if params[:format]

    res.quality = params[:quality].to_i if params[:quality]

    content_type res.mime_type

    res.to_blob
  end

  error do
    env['sinatra.error']
  end
end


