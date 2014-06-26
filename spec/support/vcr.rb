require 'vcr'

VCR.configure do |c|
  c.hook_into :webmock
  c.cassette_library_dir = 'spec/cassettes'

  c.default_cassette_options = {
    record: :none,
    allow_playback_repeats: true
  }

  c.configure_rspec_metadata!
end
