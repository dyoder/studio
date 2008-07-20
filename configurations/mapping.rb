module Application
	
	module Configurations
		
		module Mapping
			
			extend Waves::Mapping
			
			path /^\/s\/([\w\-]+)\/?$/ do | name |
				use( :blueprint ) | controller { get( name ) }
			end

		end
	
	end

end
