require 'redcloth'

module Application

	module Helpers
	
		module Page

			def page; self; end
			
			def title; @title; end
			def title=(t); @title = t; end
			
			def site
				return @site if @site
				domain = @context[:request].domain #.gsub(/www\./,'')
			  domain = Waves::Server.config.server if domain == 'localhost'
			  @site = YAML.load( File.read("db/#{domain}/site.yml") )
		  end
		
			def find( type, name )
				r = YAML.load( File.read( "db/#{site['domain']}/#{type}/#{name}.yml" ) )
				if Hash === r
					r['name'] = name; r['type'] = type
				end
				return r
			end
		
			def story( name )
				find( 'story', name )
			end
			
			def show( object, options = {} )
				
				o = { :content => 'content' }.merge( options )

				case object
					when String, Symbol then object = story( object )
					when Array then return object.inject('') { |r,obj| r << show(obj,o) }
				end
				
				return '' unless Hash === object

				case object['format']
					
					when 'mab'
						assigns = { :context => @context, :name => @name, :title => @title }
						::Markaby::Template.new( object[ o[:content] ] ).render( assigns, self )
						
					when 'textile'
						::RedCloth.new( object[ o[:content] ] ).to_html
					
					else
						object[ o[:content] ]
					
				end
			end
			
		end

	end

end