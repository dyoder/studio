module Application

	module Configurations
			
		class Development < Default

			host '0.0.0.0'
			port 3030
			reloadable [ Application ]

			#database :host => host, :adapter => :mysql, :database => :c2,
			#	:username => cruiser, :password => '43elephants'	
			
			attribute :image_generator 
			image_generator 'host' => 'localhost', 'port' => '8080', 
				'path' => '/fresco/image-generator'

		      application do
				use Rack::ShowExceptions
				run Waves::Dispatchers::Default.new
			end				
		end

	end
	
end
