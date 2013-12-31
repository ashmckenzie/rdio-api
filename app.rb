require 'sinatra/base'
require "sinatra/json"
require 'sinatra/reloader'
require 'rdio'

require 'awesome_print'
require 'pry'

ACCESS_TOKEN_FILE = './.rdio_access_token'

class App < Sinatra::Base

  enable :sessions, :logging

  configure :development do
    register Sinatra::Reloader
  end

  get '/search' do
    content_type :json

    rdio!

    if query = params[:q]
      results = Rdio::Search.search(query, 'Track')

      json_result = results.map do |result|
        {
          artist: {
            key: result.artist_key,
            name: result.artist_name
          },
          album: {
            key: result.album_key,
            name: result.album_name,
            image: result.icon,
          },
          track: {
            key: result.key,
            name: result.name
          }
        }
      end
    else
      json_result = []
    end

    json json_result
  end

  def rdio!
    @rdio ||= Rdio.init_with_token(rdio_token)
  end

  def rdio_token
    Marshal.load(File.new(ACCESS_TOKEN_FILE))
  end

  run! if app_file == $0

end
