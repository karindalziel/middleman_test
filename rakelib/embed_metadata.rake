namespace :embed_metadata do

#####################################
#    Insert metadata into images    #
##################################### 
#  Written 2015 by Jessica Dussault
#    jdussault4@gmail.com
#  For Carrie Heitman at UNL
#
# Parse CSV, embed information into jpegs
#
# ruby 2.2.0
# install exiftool (http://www.sno.phy.queensu.ca/~phil/exiftool/)
# `gem install mini_exiftool -v 2.5.1`
# `ruby embed_exif.rb`

  desc "A rake task to embed metadata. Set paths in the rake file."
  task images: :environment do

    require 'csv'
    require 'fileutils'
    require 'mini_exiftool'

    @csv_location = "public/data/hopewell_images_metadata.csv"
    @image_directory = 'public/images/images'

    main

  end

  desc "TODO"
  task embed2: :environment do
  end

end

def main

  csv = map_csv(@csv_location) # array of arrays
  csv_info = {}
  orphaned_images = []

  csv.each do |item|
    if item["Title"] && item["Title"].length > 0
      csv_info[item["Title"]] = item
    else
      puts "Id (title) incorrect or missing for row of csv #{item[0]}"
    end
  end

  # for each image attach metadata
  images = find_images(@image_directory)
  puts @image_directory
  images.each do |image|
    # should return the name of the parent directory, not the path
    id = File.basename(image, ".*")
    puts "Embedding data for #{id}"
    metadata = csv_info[id]
    if (metadata)
      exif = map_metadata_to_image(id, image, metadata)
      save_ok = exif.save
      if !save_ok || !exif.errors.empty?
        puts "Could not save exif info for #{id}" if !save_ok
        puts "Errors with exif for #{id}: #{exif.errors.to_s}" if !exif.errors.empty?
      end
    else
      puts "No metadata found for image with id #{id}"
      orphaned_images << id
    end
  end
  orphaned_print = orphaned_images.join(",\n")
  puts "The following images have no associated metadata:\n #{orphaned_print}"
end

###########
# Helpers #
###########

def find_images(directory=".")
  return Dir.glob("#{directory}/**/*.jpg")
end

def format_date(id, aDate)
  # change MM/dd/YYYY to YYYY:MM:DD
  # verify that the raw data is date-like
  if aDate =~ /^\d{1,2}\/\d{1,2}\/\d{4}$/
    date = aDate.split("/")
    return "#{date[2]}:#{date[0]}:#{date[1]}"
  else
    puts "Could not parse date for #{id}: #{aDate}"
    return nil
  end
end

def map_csv(csv, separator=",")
  return CSV.read(csv, { 
    :col_sep => separator, 
    # :quote_char => "®",     # probably don't need this for Carrie's project
    :headers => true,         # this will skip the first row and use it as keys
    :encoding => "ISO8859-1"
    })
end

def map_metadata_to_image(id, image, metadata)
  exif = MiniExiftool.new(image)
  # Identifiers
  exif.Title = id
  exif.Identifier = id
  # Description
  exif.Description = metadata["Description"] if metadata_exists?(metadata["Description"])
  # Keywords
  exif.Comment = metadata["Keyword"] if metadata_exists?(metadata["Keyword"])
  exif.Keyword = metadata["Keyword"] if metadata_exists?(metadata["Keyword"])
  # Date Created
  date_formatted = format_date(id, metadata["DateCreated"])
  exif.Date = date_formatted if date_formatted
  exif.DateTime = date_formatted if date_formatted
  # Creator
  exif.Artist = metadata["Creator"] if metadata_exists?(metadata["Creator"])
  exif.Creator = metadata["Creator"] if metadata_exists?(metadata["Creator"])
  # Source and Copyright
  exif.Source = metadata["Source"] if metadata_exists?(metadata["Source"])
  exif.Copyright = metadata["Copyright\sNotice"] if metadata_exists?(metadata["Copyright\sNotice"])
  return exif
end

def metadata_exists?(item)
  return item && !item.empty?
end

