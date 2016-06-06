# Resources

- After some trial and error, I hit upon this multiple blog starter and switched to using it. https://github.com/nukos/multiple.middleman-blog.skeleton


# middleman_test
This is a test of middleman + a few rake tasks. When/if I get it working I'll start a new repo for the finished product. 

Embed metadata using exiftool:
exiftool -keywords="raccoon, mammal, animal, rescue, bottle" -overwrite_original IMG_7917.jpg
#todo: write a yaml data ingest script

rake gallery:images['FOLDERNAME']

#TODO


- Create two blogs: one for galleries, one for individual photos
	- change script to write .md files to both blogs 
- add a check to see if photo folder is empty/exists
- Create a way to add an option description file in the gallery photos. Probably Markdown? Maybe YAML? Could possibly format full blog posts this way, and just do a photo dump the rest of the time?
- Add bootstrap 4 and style. 
- Package as gem

