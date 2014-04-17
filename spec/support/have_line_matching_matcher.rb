RSpec::Matchers.define :have_line_matching do |expected|
  match do |actual|
    actual.readlines.any? {|line| Regexp.new(expected) =~ line }
  end
end
