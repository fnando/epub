# frozen_string_literal: true

require "test_helper"

class NavigationTest < Minitest::Test
  let(:root_dir) { Pathname.new(File.join(__dir__, "..", "support")) }
  let(:files) { root_dir.glob("ch*.html") }

  test "generates hierarchy" do
    toc = Epub::Navigation.extract(files, root_dir:)

    # Two pages, 3×h1
    assert_equal 3, toc.size

    assert_path toc, [0, :title], "Introduction"
    assert_path toc, [0, :link], "ch01.html#ch01-1"
    assert_path toc, [0, :navigation, 0, :title],
                "Welcome to the World of Programming"
    assert_path toc, [0, :navigation, 0, :link],
                "ch01.html#ch01-2"
    assert_path toc, [0, :navigation, 1, :title],
                "Why Choose Ruby?"
    assert_path toc, [0, :navigation, 1, :link],
                "ch01.html#ch01-3"
    assert_path toc, [0, :navigation, 2, :title],
                "Setting Up Your Development Environment"
    assert_path toc, [0, :navigation, 2, :link],
                "ch01.html#ch01-4"
    assert_path toc, [0, :navigation, 2, :navigation, 0, :title],
                "Installing Ruby"
    assert_path toc, [0, :navigation, 2, :navigation, 0, :link],
                "ch01.html#ch01-5"
    assert_path toc, [0, :navigation, 2, :navigation, 1, :title],
                "Choosing a Text Editor or IDE"
    assert_path toc, [0, :navigation, 2, :navigation, 1, :link],
                "ch01.html#ch01-6"

    assert_path toc, [1, :title], "Getting Started with Ruby"
    assert_path toc, [1, :link], "ch02.html#ch02-1"
    assert_path toc, [1, :navigation, 0, :title], "Hello, Ruby!"
    assert_path toc, [1, :navigation, 0, :link], "ch02.html#ch02-2"
    assert_path toc, [1, :navigation, 0, :navigation, 0, :title],
                "Your First Ruby Program"
    assert_path toc, [1, :navigation, 0, :navigation, 0, :link],
                "ch02.html#ch02-3"
    assert_path toc, [1, :navigation, 0, :navigation, 1, :title],
                %[Understanding the "Hello, World!" Tradition]
    assert_path toc, [1, :navigation, 0, :navigation, 1, :link],
                "ch02.html#ch02-4"
    assert_path toc, [1, :navigation, 1, :title], "Variables and Data Types"
    assert_path toc, [1, :navigation, 1, :link], "ch02.html#ch02-5"
    assert_path toc, [1, :navigation, 1, :navigation, 0, :title],
                "Understanding Variables"
    assert_path toc, [1, :navigation, 1, :navigation, 0, :link],
                "ch02.html#ch02-6"
    assert_path toc, [1, :navigation, 1, :navigation, 1, :title],
                "Exploring Different Data Types in Ruby"
    assert_path toc, [1, :navigation, 1, :navigation, 1, :link],
                "ch02.html#ch02-7"

    assert_path toc, [2, :title], "Control Flow and Logic"
    assert_path toc, [2, :link], "ch02.html#ch02-8"
    assert_path toc, [2, :navigation, 0, :title], "Conditional Statements"
    assert_path toc, [2, :navigation, 0, :link], "ch02.html#ch02-9"
    assert_path toc, [2, :navigation, 0, :navigation, 0, :title],
                "Statements"
    assert_path toc, [2, :navigation, 0, :navigation, 0, :link],
                "ch02.html#ch02-10"
    assert_path toc, [2, :navigation, 0, :navigation, 1, :title],
                "Case Statements"
    assert_path toc, [2, :navigation, 0, :navigation, 1, :link],
                "ch02.html#ch02-11"
  end

  test "generates html snippet" do
    html = Epub::Navigation.extract_html(files, root_dir:)

    assert_equal root_dir.join("../expected/toc.html").read, html
  end

  def assert_path(target, path, expected_value)
    assert_equal expected_value, target.dig(*path)
  end
end
