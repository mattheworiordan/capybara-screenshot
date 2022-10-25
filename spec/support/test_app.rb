require 'sinatra/base'

Sinatra::Application.root = '.'

class TestApp < Sinatra::Base
  get '/' do
    'This is the root page'
  end

  get '/different_page' do
    'This is a different page'
  end

  get '/has_frame' do
    'This is the has_frame page
    <iframe src="/different_page" id="different_page_frame">
    </iframe'
  end
end
