require 'rss'
require 'open-uri'

class HomeController < ApplicationController
  def index
    url = 'https://pjmedia.com/instapundit/feed/'
    @feed = RSS::Parser.parse(open(url))
  end
end
