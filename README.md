# epub-rb

[![Tests](https://github.com/fnando/epub/workflows/ruby-tests/badge.svg)](https://github.com/fnando/epub)
[![Gem](https://img.shields.io/gem/v/epub-rb.svg)](https://rubygems.org/gems/epub-rb)
[![Gem](https://img.shields.io/gem/dt/epub-rb.svg)](https://rubygems.org/gems/epub-rb)
[![MIT License](https://img.shields.io/:License-MIT-blue.svg)](https://tldrlegal.com/license/mit-license)

Create epub files using Ruby.

## Installation

```bash
gem install epub-rb
```

Or add the following line to your project's Gemfile:

```ruby
gem "epub-rb"
```

## Usage

```ruby
require "epub"

epub = Epub.new(
  root_dir: "./book",
  title: "Hello World",
  subtitle: "A Complete Beginner’s Guide to Ruby Programming",
  creators: ["John Doe"],
  publisher: "epub-rb",
  date: "2024-01-24",
  id: "d05f92ea-62f7-44d6-bb48-d94c11e660db",
  copyright: "Copyright 2024 by John Doe",
  identifiers: ["915869090000000000DD", "urn:isbn:9780000000001"],
  contributors: ["Jane Doe"],
  files: [
    "./book/book.css",
    "./book/cover.png",
    "./book/cover.html",
    "./book/toc.html",
    "./book/ch01.html",
    "./book/ch02.html",
    "./book/images/terminal.svg"
  ]
)

epub.save("hello-word.epub")
```

The epub file is compliant with the EPUB 3.3 specification. You can check it by
using [epubcheck](https://www.w3.org/publishing/epubcheck/).

> [!NOTE]
>
> epub-rb makes a few assumptions that you need to follow.
>
> 1. You need to have a file name `toc.{xhtml,html}`. This file must be
>    compliant with the EPUB 3 spec.
> 2. You'll also need a cover image named as `cover.{png,jpg,gif}`.
> 3. You'll also need a companion file called `cover.{xhtml,html}`.

### Generating the Table of Contents (navigation file)

You can use the methods `Epub::Navigation.extract(files, root_dir:)` and
`Epub::Navigation.extract_html(files, root_dir:)` to generate the `toc.html`
file. A simple way would be using something like this:

```ruby
navigation = Epub::Navigation.extract_html(
  Dir["./book/**/*.html"],
  root_dir: "./book"
)

File.open("toc.html", "w") do |file|
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
```

> [!NOTE]
>
> Notice that the order of `.html`/`.xhtml` files is important. You need to sort
> files how you'd like them to show up. If you add `toc.html` lastly, then it'll
> show up at the end of the ebook.
>
> Consider adding files in this order: `cover.html`, `toc.html`, all other html
> files your epub will have, then other assets (images, css, javascript, etc).

## Maintainer

- [Nando Vieira](https://github.com/fnando)

## Contributors

- https://github.com/fnando/epub/contributors

## Contributing

For more details about how to contribute, please read
https://github.com/fnando/epub/blob/main/CONTRIBUTING.md.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT). A copy of the license can be
found at https://github.com/fnando/epub/blob/main/LICENSE.md.

## Code of Conduct

Everyone interacting in the epub-rb project's codebases, issue trackers, chat
rooms and mailing lists is expected to follow the
[code of conduct](https://github.com/fnando/epub/blob/main/CODE_OF_CONDUCT.md).
