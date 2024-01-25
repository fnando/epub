# frozen_string_literal: true

epub = Epub.new
epub.files += []
epub.cover_image = "cover.png"
epub.cover_page = "cover.html"
epub.toc_page = "toc.html"
epub.id = {}
epub.date = Time.now
epub.publisher = "O'Reilly"
epub.creator = "Author 1, Author 2, and Author 3"
epub.navigation = navigation
epub.save("file.epub")

# epub.title        config[:title]
# epub.language     config[:language]
# epub.creator      config[:authors].to_sentence
# epub.publisher    config[:publisher]
# epub.date         config[:published_at]
# epub.uid          "id"
# epub.identifier   config[:identifier][:id],
#                   scheme: config[:identifier][:type]

# # epubchecker complains when assigning an image directly,
# # but if we don't, then Apple Books doesn't render the cover.
# # Need to investigate some more.
# # epub.cover_page   cover_image if cover_image && File.exist?(cover_image)
# epub.cover_page   "output/epub/cover.html"
# epub.files(sections.map(&:filepath) + assets)
# epub.nav(hierarchy)
# epub.toc_page(toc_path)
# epub.save(epub_path)
