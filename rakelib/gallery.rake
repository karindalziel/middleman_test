namespace :gallery do
  desc "create a template include of images based on a folder full of images + exif data. Set paths in the rake file."

  require 'erb'
  require 'fileutils'
  require 'mini_exiftool'
  require 'active_support/all'

  # using tasks to set variables depending on task called
  #task :create, [:gallery_type] => :environment do |t, args|
  #task :my_task, [:arg1, :arg2] do |t, args|
  task :images, [:foldername, :arg2] do |t, args|
    
    @foldername    =  args.foldername
    @output_file   = "source/articles/" + args.foldername + ".html.md"
    @image_path    = "source/images/" + args.foldername
    @template_file = "rakelib/gallery.erb"

    gallery_create
    
  end

  def gallery_create
    #just want to make sure it is doing something
    puts "hello fine human"
    
    

puts '-----------'
    puts @output_file
    puts @image_path
    puts '-----------'
      # Totally stole this from http://stackoverflow.com/questions/7813694/how-to-fill-html-file-using-ruby-script
      File.open(@output_file, 'w') do |o|
        puts "Processing file: #{@template_file}"
        o << ERB.new( IO.read( @template_file ), nil, '>', 'output' ).result( binding )
      end

    end

    # ----------------------------------------

    # from Jessica's script
    def find_images(directory=@image_path)
      return Dir.glob("#{directory}/**/*.jpg")
    end

    # List the exif fields you want outputted.
    @exifs = ['identifier',
               
               'keywords']

    def exif_field_builder(photo, property)
    # public_send() allows me to call the variable property rather than the exif tag property
    # it appears just send() also works. See this blog post that I mostly don't understand: 
    # http://vaidehijoshi.github.io/blog/2015/05/05/metaprogramming-dynamic-methods-using-public-send/
          if photo.public_send(property) != nil 
            # turn date into pretty date
            if property == 'date'
              #weird way of doing this
              exiftime = photo.public_send(property)
              timeobject = DateTime.strptime(exiftime, '%Y:%m:%d')
              prettytime = timeobject.strftime("%B %d, %Y")
              return property.titlecase + ': ' + prettytime
            else

            end
            
            return property.titlecase + ': ' + photo.public_send(property)
          
          else
            
            return property.titlecase + ': None'

          end

        end

  end
