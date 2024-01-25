# frozen_string_literal: true

module Epub
  module MimeType
    # https://www.w3.org/TR/epub/#sec-core-media-types
    def self.list
      @list ||= {
        ".html" => "application/xhtml+xml",
        ".xhtml" => "application/xhtml+xml",
        ".png" => "image/png",
        ".jpeg" => "image/jpeg",
        ".jpg" => "image/jpeg",
        ".gif" => "image/gif",
        ".webp" => "image/webp",
        ".svg" => "image/svg+xml",
        ".woff" => "font/woff",
        ".woff2" => "font/woff2",
        ".ttf" => "font/ttf",
        ".otf" => "font/otf",
        ".css" => "text/css",
        ".mp3" => "audio/mpeg",
        ".m4a" => "audio/mp4",
        ".ogg" => "audio/ogg; codecs=opus",
        ".js" => "application/javascript",
        ".ncx" => "application/x-dtbncx+xml"
      }
    end

    def self.[](file)
      list[File.extname(file).downcase]
    end
  end
end
