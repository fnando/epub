# frozen_string_literal: true

module Epub
  class Epub
    # Root directory, so we can get the relative path for `:files`.
    #
    attr_accessor :root_dir

    # EPUB spec version engine. Only EPUBv3 is supported.
    #
    attr_accessor :epub_engine

    # The book's title.
    #
    attr_accessor :title

    # The book's subtitle.
    #
    attr_accessor :subtitle

    # The list of files that will be package.
    # Must include everything (fonts, stylesheets, videos, etc).
    #
    attr_reader :files

    # The path to the cover image (can be .png or .jpg).
    #
    attr_accessor :cover_image

    # The epub identifier.
    # This must be a UUIDv4. For additional ids based on identifier schemes,
    # use `Epub::Epub#identifiers`.
    #
    attr_accessor :id

    # The epub's identifier schemes. Must be a list of URN strings.
    #
    # URNs look like:
    #
    # - UUID: `urn:uuid:A1B0D67E-2E81-4DF5-9E67-A64CBE366809`
    # - ISBN: `urn:isbn:9780000000001`
    # - DOI: `doi:10.1016/j.iheduc.2008.03.001`
    # - JDCN: `915869090000000000DD`
    #
    # http://idpf.github.io/epub-registries/identifiers/identifiers.html
    #
    attr_accessor :identifiers

    # The publication date. Must be a string like `2024-01-24`.
    #
    attr_accessor :date

    # The publisher entity.
    #
    attr_accessor :publisher

    # A list of creators.
    #
    # @type String[]
    #
    attr_accessor :creators

    # A list of contributors.
    #
    # @type String[]
    #
    attr_accessor :contributors

    # The copyright notice.
    #
    attr_accessor :copyright

    # The book language.
    # Defaults to `en`.
    #
    attr_accessor :language

    # Temporary directory. Defaults to `Dir.mktmpdir`.
    #
    attr_accessor :tmpdir

    # Set debug mode.
    # It will output debugging info, and won't remove tmpdir after book is
    # generated.
    #
    attr_accessor :debug
    alias debug? debug

    def initialize(**kwargs)
      kwargs.each {|key, value| public_send(:"#{key}=", value) }

      self.date = Date.parse(date || Date.today.to_s)
      self.id ||= SecureRandom.uuid
      self.epub_engine ||= V3
      self.language ||= "en"
      self.tmpdir ||= Pathname.new(File.join(Dir.tmpdir, SecureRandom.uuid))
      self.tmpdir = Pathname.new(tmpdir)
      self.root_dir = Pathname.new(root_dir || Dir.pwd)
      self.creators = Array(creators)
      self.contributors = Array(contributors)
      self.identifiers = Array(identifiers)
      self.files ||= []
      identifiers << "urn:uuid:#{id}"
    end

    def files=(files)
      @files = Array(files).map {|file| Pathname.new(file) }
    end

    # Save the file at specified output path.
    # If a file already exists, an error will be raised.
    def save(output_path)
      FileUtils.mkdir_p(tmpdir)
      epub_engine.new(config: self, output_path:).save
    ensure
      FileUtils.rm_rf(tmpdir) unless debug?
    end
  end
end
