# frozen_string_literal: true

require 'digest'

$assets = {}

module AssetHashing
  class AssetFile < Jekyll::StaticFile
    def destination(destination)
      File.join(destination, @dir.sub('_', ''), hashed_name)
    end

    def asset_name
      File.join(@dir.sub('_assets', ''), @name).sub('/', '')
    end

    def hashed_path
      File.join('/', @dir.sub('_', ''), hashed_name)
    end

    def hashed_name
      @hashed_name ||=
        begin
          basename, _, ext = @name.rpartition('.')

          "#{basename}-#{hexdigest}.#{ext}"
        end
    end

    def hexdigest
      @hexdigest ||= Digest::MD5.file(path).hexdigest
    end
  end

  class Generator < Jekyll::Generator
    def generate(site)
      paths = Dir.glob('_assets/**/*').reject { File.directory?(_1) }
      paths.each do |path|
        path, _, name = path.rpartition('/')
        next if name.start_with?('_')

        file = AssetFile.new(site, site.source, path, name)
        site.static_files << file
        $assets[file.asset_name] = file
      end
    end
  end

  class AssetTag < Liquid::Tag
    def initialize(_tag_name, asset, _tokens)
      super
      @asset = asset.strip
    end

    def render(_context)
      $assets[@asset]&.hashed_path || raise("Asset #{@asset} not found")
    end
  end
end

Liquid::Template.register_tag('asset', AssetHashing::AssetTag)
