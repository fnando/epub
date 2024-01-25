# frozen_string_literal: true

require "securerandom"
require "builder"
require "zip"
require "nokogiri"

module Epub
  require "epub/version"
  require "epub/epub"
  require "epub/v3"
  require "epub/mime_type"
  require "epub/navigation"

  def self.new(**)
    Epub.new(**)
  end
end
