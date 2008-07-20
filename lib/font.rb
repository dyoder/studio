module Application

	class Font

	  module SVG
    
	    def SVG.import(font)
				path = :db / :font / font
				unless File.exist?( path + '.svg' )
	      `svg-import-font #{path}.ttf -id font -o #{path}.svg -testcard`
				end
	    end

	  end

	end
	
end
