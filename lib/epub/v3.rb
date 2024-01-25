# frozen_string_literal: true

module Epub
  ContainerBreakoutError = Class.new(StandardError)

  class V3
    # The configuration object (`Epub::Epub`).
    #
    attr_reader :config

    # The output path.
    #
    attr_reader :output_path

    attr_reader :oebps_dir, :meta_inf_dir

    def initialize(config:, output_path:)
      @config = config
      @output_path = Pathname.new(output_path)
      @oebps_dir = config.tmpdir.join("OEBPS")
      @meta_inf_dir = config.tmpdir.join("META-INF")
    end

    def save
      create_dirs
      create_mimetype_file
      create_container_file
      create_opf_file
      copy_files
      create_epub_file
    end

    private def create_epub_file
      FileUtils.rm_rf(output_path)

      Zip::File.open(output_path, Zip::File::CREATE) do |zip|
        # The `mimetype` file must be stored first and it should be
        # uncompressed.
        zip.add_stored("mimetype", config.tmpdir.join("mimetype"))

        config.tmpdir.glob("**/*").each do |source_path|
          relative_path = source_path.relative_path_from(config.tmpdir)

          next if source_path.directory?
          next if relative_path.to_s == "mimetype"

          zip.add(relative_path, source_path)
        end
      end
    end

    private def copy_files
      config.files.each do |source_path|
        relative_path = source_path.relative_path_from(config.root_dir)
        target_path = oebps_dir.join(relative_path)

        if relative_path.to_s.start_with?("..")
          raise ContainerBreakoutError,
                "Cannot copy #{source_path.expand_path}, " \
                "as it breaks out the epub container (#{relative_path}).\n" \
                "Ensure your files exist within #{config.root_dir.expand_path}."
        end

        FileUtils.mkdir_p(target_path.dirname)
        FileUtils.cp(source_path, target_path)
      end
    end

    private def create_mimetype_file
      config.tmpdir.join("mimetype").open("w") do |file|
        file << "application/epub+zip"
      end
    end

    private def create_dirs
      oebps_dir.mkdir
      meta_inf_dir.mkdir
    end

    private def create_container_file
      meta_inf_dir.join("container.xml").open("w") do |file|
        file << <<~XML
          <?xml version="1.0"?>
          <container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
            <rootfiles>
              <rootfile full-path="OEBPS/content.opf"
                media-type="application/oebps-package+xml" />
            </rootfiles>
          </container>
        XML
      end
    end

    private def create_opf_file
      xml = Builder::XmlMarkup.new(indent: 2)
      xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
      xml.package(
        xmlns: "http://www.idpf.org/2007/opf",
        version: "3.0",
        "xmlns:opf" => "http://www.idpf.org/2007/opf",
        "unique-identifier" => "book-id"
      ) do
        render_opf_metadata(xml)
        render_opf_manifest(xml)
        render_opf_spine(xml)
      end

      oebps_dir.join("content.opf").open("w") do |file|
        file << xml.target!
      end
    end

    private def render_opf_metadata(xml)
      xml.metadata("xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
        xml.dc(:identifier, config.id, id: "book-id")

        config.identifiers.each do |id|
          xml.dc(:identifier, id)
        end

        xml.dc(:title, config.title, id: "book-title")
        xml.meta("main", refines: "#book-title", property: "title-type")

        xml.meta(config.title, property: "dcterms:title")

        if config.subtitle
          xml.dc(:title, config.subtitle, id: "book-subtitle")
          xml.meta("subtitle", refines: "#book-subtitle",
                               property: "title-type")
        end

        xml.meta name: "cover", content: "cover-image"

        xml.dc(:date, config.date.iso8601)
        xml.meta("#{config.date.iso8601}T00:00:00Z",
                 property: "dcterms:modified")
        xml.dc(:language, config.language)
        xml.meta(config.language, property: "dcterms:language")

        config.creators.each_with_index do |creator, index|
          xml.dc(:creator, creator, id: "creator-#{index}")
          xml.meta(creator, id: "creator-#{index}-meta",
                            property: "dcterms:creator")
        end

        config.contributors.each_with_index do |contributor, index|
          xml.dc(:contributor, contributor, id: "contributor-#{index}")
          xml.meta(contributor,
                   id: "contributor-#{index}-meta",
                   property: "dcterms:contributor")
        end

        xml.dc(:publisher, config.publisher)
        xml.meta(config.publisher, property: "dcterms:publisher")

        if config.copyright
          xml.dc(:rights, config.copyright)
          xml.meta(config.copyright, property: "dcterms:rights")
        end
      end
    end

    private def render_opf_manifest(xml)
      xml.manifest do
        config.files.each do |file|
          id = guess_id(file)
          props = {}
          props[:properties] = "cover-image" if id == "cover-image"
          props[:properties] = "nav" if id == "toc"

          xml.item href: file.relative_path_from(config.root_dir),
                   "media-type" => guess_media_type(file),
                   id:,
                   **props
        end
      end
    end

    private def guess_id(filename)
      filename = filename.basename.to_s

      case filename
      when /^cover\.(png|jpe?g|gif|svg)$/i
        "cover-image"
      when /^cover\.x?html$/i
        "cover"
      when /^toc\.x?html$/i
        "toc"
      else
        filename.tr(".", "-")
      end
    end

    private def guess_media_type(file)
      MimeType[file]
    end

    private def render_opf_spine(xml)
      xml.spine do
        config.files.each do |file|
          next unless file.extname.match?(/\.x?html$/i)

          xml.itemref idref: guess_id(file)
        end
      end
    end
  end
end
