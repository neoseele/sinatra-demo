require 'sinatra/base'
require 'open-uri'

module Sinatra
  module MetadataHelper
    METADATA = 'http://metadata.google.internal/computeMetadata/v1beta1/instance/'

    def fetch_instance(uri, result={})
      read_metadata(uri, result).map do |var|
        if var =~ /\/$/
          fetch_instance(uri+var, result) unless var =~ /service-accounts/
        else
          read_metadata(uri+var, result)
        end
      end
    end

    def read_metadata(path, result)
      uri = "#{METADATA}#{path}"
      open(uri, 'Metadata-Flavor' => 'Google').readlines.map do |line|
        result[path] = line unless path =~ /\/$/
        line.strip
      end
    end

  end

  helpers MetadataHelper
end
