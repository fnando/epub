# frozen_string_literal: true

require "English"
require "test_helper"

class V3Test < Minitest::Test
  let(:tmpdir) { Pathname.new(File.join(__dir__, "..", "output", "tmp")) }
  let(:output_path) { tmpdir.join("..", "file.epub") }
  let(:source_dir) { Pathname.new(File.join(__dir__, "..", "support")) }

  setup do
    FileUtils.rm_rf(tmpdir)
  end

  test "generates epub file" do
    navigation = Epub::Navigation.extract_html(
      [
        source_dir.join("ch01.html"),
        source_dir.join("ch02.html")
      ],
      root_dir: source_dir
    )

    source_dir.join("toc.html").open("w") do |file|
      file << <<~HTML
        <?xml version='1.0' encoding='utf-8'?>
        <html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" xml:lang="en" lang="en">
          <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
            <title>Table of Contents</title>
          </head>
          <body>
            #{navigation}
          </body>
        </html>

      HTML
    end

    epub = Epub.new(
      root_dir: source_dir.to_s,
      title: "Hello World",
      subtitle: "A Complete Beginner’s Guide to Ruby Programming",
      creators: ["John Doe"],
      publisher: "epub-rb",
      date: "2024-01-24",
      id: "d05f92ea-62f7-44d6-bb48-d94c11e660db",
      copyright: "Copyright 2024 by John Doe",
      identifiers: ["915869090000000000DD"],
      contributors: ["Jane Doe"],
      files: [
        source_dir.join("cover.png"),
        source_dir.join("cover.html"),
        source_dir.join("toc.html"),
        source_dir.join("ch01.html"),
        source_dir.join("ch02.html"),
        source_dir.join("terminal.svg")
      ].map(&:to_s),
      tmpdir: tmpdir.to_s
    )

    epub.save(output_path)

    assert File.file?(output_path)
    refute Dir.exist?(epub.tmpdir)

    system "epubcheck", output_path.to_s, "--failonwarnings", "--quiet"

    assert $CHILD_STATUS.success?
  end

  test "fails to import file that's not within root dir" do
    epub = Epub.new(
      root_dir: source_dir,
      title: "Hello World",
      subtitle: "A Complete Beginner’s Guide to Ruby Programming",
      creators: ["John Doe"],
      publisher: "epub-rb",
      date: "2024-01-24",
      id: "d05f92ea-62f7-44d6-bb48-d94c11e660db",
      copyright: "Copyright 2024 by John Doe",
      identifiers: ["915869090000000000DD"],
      contributors: ["Jane Doe"],
      files: [
        source_dir.join("cover.png"),
        source_dir.join("cover.html"),
        source_dir.join("toc.html"),
        source_dir.join("ch01.html"),
        source_dir.join("ch02.html"),
        source_dir.join("../terminal.svg")
      ],
      tmpdir:
    )

    assert_raises(Epub::ContainerBreakoutError) { epub.save(output_path) }
  end
end
