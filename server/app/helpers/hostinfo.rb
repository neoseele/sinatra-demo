require 'sinatra/base'
require 'open-uri'

module Sinatra
  module HostinfoHelper
    FORWARDED_IPS = 'network-interfaces/0/forwarded-ips/'

    def hostinfo
      info = {}
      info[:hostname] = read_metadata('hostname')[0]
      # info[:ip] = read_metadata('0/ip')[0]
      # info[:forwarded_ips] = read_metadata(FORWARDED_IPS).map do |i|
      #   read_metadata("#{FORWARDED_IPS}/#{i}")[0]
      # end
      # info
    end

    def read_metadata(path)
      open("http://metadata.google.internal/computeMetadata/v1beta1/instance/#{path}",
        'Metadata-Flavor' => 'Google').readlines.map do |l|
        l.strip
      end
    end
  end

  helpers HostinfoHelper
end
