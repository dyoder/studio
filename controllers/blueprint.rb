require 'lib/svg'
require 'lib/font'

module Application
	
	module Controllers
	
		class Blueprint

			include Waves::Controllers::Mixin
			include Waves::ResponseMixin
			def get(name)
				path = :db / :blueprint / ( name + '.yml' )
				key = [ :blueprint, name, 
					params.keys.sort.map{|k|"#{k}=#{params[k]}" unless k=='path'}.join('&')  
				].join('.')
				cache_path = :db / :cache / key
				begin
					data = File.read( cache_path ) if File.exist?( cache_path )
				rescue 
					Waves.log.warn "Problem reading from cache."
				end
				unless ( data )
					@blueprint = YAML.load( File.read( path ))
					data = ::Application::SVG.new( svg ).convert
					data = smooth( data ) if @blueprint['smoothing']
					File.write( cache_path, data )
 				end
				expires = ( Date.today + 365 ).strftime('%a, %d %b %Y 00:00:00 GMT')
				[ data, { 'Expires' => expires, 'Content-Type' => 'image/png' } ]
			end
			
			protected

		  def smooth(data)
		    Image.new( data ).resize!( [ real_width, real_height ] ).to_blob
		  end

		  def svg
		    <<-SVG
<?xml version="1.1" standalone="no"?> 
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.0//EN"
  "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd" >

<svg xmlns="http://www.w3.org/2000/svg" width='#{width}' height='#{height}'>
  <defs>
    <style type='text/css'>
      #{font_declaration if fonts}
      #{css}
    </style>
  </defs>
  #{content}
</svg>
				SVG
			end

		  def font_declaration
				::Application::Font::SVG.import( font )
				<<-FONT
@font-face {
  font-family: '#{font}' ;
  src: url( file://#{ File.expand_path( :db / :font / font + '.svg' ) }#font ) ;
} 
        FONT
		  end

		  def content
		    @blueprint['content'].gsub(/\$\{(.*?)\}/) { value_of( $1 ) }.
          gsub(/\#\{(.*?)\}/) { color_value( value_of( $1 ) ) } + "\n"
		  end

		  def css
				@blueprint['css'].gsub(/\$\{(.*?)\}/) { value_of( $1 ) }.
	        gsub(/\#\{(.*?)\}/) { color_value( value_of( $1 ) ) } + "\n"
		  end

		  def color_value(value)
		    ( ( r = value.scan( /^[0-f]+$/ ).first and r.length == value.length ) ? 
		      "##{value}" : value )
		  end

			def params
				@request.params
			end
			
		  def value_of(what)
		    name, default = what.split(':')
		    params[name] || dynamic_value(name) || default
		  end

		  def dynamic_value(name)
		    case name
		      when 'baseline' then baseline
		      when 'font-family' then fonts
		      when 'font-size' then font_size
		      when 'height' then height
		      when 'width' then width
		    end
		  end

		  def font
		    fonts.split(',').first.strip
		  end

		  def fonts
		    params['f'] || @blueprint['fonts']
		  end

		  def baseline
		    ( height - ( height * 0.25 ) )
		  end

		  def height
		    @blueprint['smoothing'] ? ( real_height * 4 ) : real_height
		  end

		  def width
		    @blueprint['smoothing'] ? ( real_width * 4 ) : real_width
		  end

		  def real_height
		    params['h'].to_i
		  end

		  def real_width
		    params['w'].to_i
		  end

		  def font_size
		    @blueprint['smoothing'] ? ( real_font_size * 4 ) : real_font_size
		  end

		  def real_font_size
		    params['p'].to_i
		  end

		end
	end
end
