require 'net/http'
require 'yaml'

module Application
	class SVG
    
	  attr_accessor :data  
	  Defaults = { :format => :png }

  
	  def initialize( data = nil, options = {} )
	    @data = data; set options
	  end
  
	  def convert( options = {} )
	    Net::HTTP.start( service['host'], service['port'] ) do |session|
	      response, image = session.post( service['path'], data )
	      image if response.code == '200'
	    end
	  end
  
	  private
  
	  def service
	    Waves::Server.config['image_generator']
	  end

	  def set(options)
	    if defined? @options
	      @options.merge! options
	    else
	      @options = Defaults.merge options
	    end
	  end

	end
end