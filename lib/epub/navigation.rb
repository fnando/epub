# frozen_string_literal: true

module Epub
  class Navigation
    Node = Struct.new(:level, :entry, :parent, keyword_init: true)
    Entry = Struct.new(:title, :link, :navigation, keyword_init: true)
    SELECTOR = "h1, h2[id], h3[id], h4[id], h5[id], h6[id]"

    # Go through each files, sequentially and extract the table of contents
    # hierarchy, so you don't have to do it yourself.
    #
    # Notice that only `h2-h6` headings with an `id` attribute will be added to
    # the list. `h1` headings will always be added; if they don't have an id,
    # then they'll be linked to the file itself.
    #
    # The output structure doesn't look like the one you're expecting, make sure
    # your headings have the `id` attribute.
    #
    def self.extract_html(files, root_dir:)
      navigation = extract(files, root_dir:)
      html = renderer(navigation)
      <<~HTML
        <nav epub:type="toc">
          #{html}
        </nav>
      HTML
    end

    def self.renderer(navigation)
      return "" if navigation.empty?

      html = []
      html << "<ol>"

      navigation.each do |item|
        title = CGI.escape_html(item.title)

        html << "<li>\n"
        html << %[<a href="#{item.link}">#{title}</a>]
        html << renderer(item.navigation)
        html << "\n</li>"
      end

      html << "</ol>"

      html.join
    end

    def self.extract(files, root_dir:)
      root = Node.new(level: 0, entry: Entry.new(navigation: []))
      current = root

      sections = files.map do |file|
        {
          html: Nokogiri::HTML(File.read(file)),
          path: Pathname.new(file).relative_path_from(root_dir).to_s
        }
      end

      sections.each do |section|
        section[:html].css(SELECTOR).each do |node|
          title = node.text.strip
          level = node.name[1].to_i

          entry = Entry.new(
            title:,
            link: "#{section[:path]}##{node.attributes['id']}",
            navigation: []
          )

          if level > current.level
            current = Node.new(level:, entry:, parent: current)
          elsif level == current.level
            current = Node.new(level:, entry:, parent: current.parent)
          else
            while current.parent && current.parent.level >= level
              current = current.parent
            end

            current = Node.new(level:, entry:, parent: current.parent)
          end

          current.parent.entry[:navigation] << entry
        end
      end

      root.entry[:navigation]
    end
  end
end
