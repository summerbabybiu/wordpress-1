# Require any additional compass plugins here.

# Set this to the root of your project when deployed:

css_dir = "css"
sass_dir = "scss"
images_dir = "imgs"
javascripts_dir = "js"
fonts_dir = "fonts"

output_style = :compact
environment = :development

# To enable relative paths to assets via compass helper functions. Uncomment:
relative_assets = true

line_comments = false
color_output = false


# If you prefer the indented syntax, you might want to regenerate this
# project again passing --syntax sass, or you can uncomment this:
# preferred_syntax = :sass
# and then run:
# sass-convert -R --from scss --to sass scss scss && rm -rf sass && mv scss sass

require 'autoprefixer-rails'

on_stylesheet_saved do |file|
    css = File.read(file)
    map = file + '.map'
    
    if File.exists? map
        result = AutoprefixerRails.process(css,
        from: file,
        to:   file,
        map:  { prev: File.read(map), inline: false })
        File.open(file, 'w') { |io| io << result.css }
        File.open(map,  'w') { |io| io << result.map }
    else
        File.open(file, 'w') { |io| io << AutoprefixerRails.process(css) }
    end
end

module Compass::SassExtensions::Functions::Sprites
    def sprite_url(map)
        verify_map(map, "sprite-url")
        map.generate
        generated_image_url(Sass::Script::String.new(map.name_and_hash))
    end
end

module Compass::SassExtensions::Sprites::SpriteMethods
    def name_and_hash
        "#{path}.png"
    end
    
    def cleanup_old_sprites
        Dir[File.join(::Compass.configuration.generated_images_path, "sprite-#{path}.png")].each do |file|
        log :remove, file
        FileUtils.rm file
        ::Compass.configuration.run_sprite_removed(file)
        end
    end
end

module Compass
  class << SpriteImporter
    def find_all_sprite_map_files(path)
      glob = "sprite-*{#{self::VALID_EXTENSIONS.join(",")}}"
      Dir.glob(File.join(path, "**", glob))
    end
  end
end