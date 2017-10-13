require 'net/http'
require 'uri'
require 'base64'

module SpotifyPlaylists
  class SpotifyPlaylists

    def initialize
      @refresh_token = ENV["SPOT_REFRESH_TOKEN"]
      @spotify_user = "islandersdid"
    end

    def encoded_auth_info
      auth_info = ENV["SPOT_ID"] + ":" + ENV["SPOT_SECRET"]
      encoded_auth_info = Base64.strict_encode64(auth_info)
    end

    def get_access_token
      uri = URI.parse("https://accounts.spotify.com/api/token")
      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = "Basic " + encoded_auth_info
      request.set_form_data(
      "grant_type" => "refresh_token",
      "refresh_token" => @refresh_token
      )
      req_options = {
      use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      return JSON.parse(response.body)["access_token"]
    end




    def get_refresh_token
      redirect_uri = "http://localhost:8082/"
      step_one = RestClient.get 'https://accounts.spotify.com/authorize/', {params: {:client_id => ENV["SPOT_ID"], :redirect_uri => redirect_uri, :response_type => 'code', :scope => "playlist-modify-private playlist-modify-public playlist-read-private"} }
      puts step_one.request.url
      code = gets.split("=")[1][0..-2]
      puts code
      begin
        step_four = RestClient.post 'https://accounts.spotify.com/api/token', {:client_id => ENV["SPOT_ID"], :client_secret => ENV["SPOT_SECRET"], grant_type: 'authorization_code', code: code, redirect_uri: redirect_uri }
      rescue RestClient::ExceptionWithResponse => e
        puts  e.response
      end
      puts step_four
    end



    def spotify_api_request(uri,body,type)
      uri = URI.parse(uri)
      if type == "post"
        request = Net::HTTP::Post.new(uri)
      elsif type == "put"
        request = Net::HTTP::Put.new(uri)
      elsif type == "get"
        request = Net::HTTP::Get.new(uri)
      end
      request.content_type = "application/json"
      request["Authorization"] = "Bearer #{get_access_token}"
      request.body = JSON.dump(body)

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
      return response
    end

    def replace_spotify_playlist(user_name, playlist_uri, tracks)
      uri = "https://api.spotify.com/v1/users/#{user_name}/playlists/#{playlist_uri}/tracks"
      body = { "uris" => tracks}
      response = spotify_api_request(uri, body, "put")
      return JSON.parse(response.body)["uri"]
    end

    def add_tracks_to_spotify_playlist(user_name, playlist_uri, tracks)
      uri = "https://api.spotify.com/v1/users/#{user_name}/playlists/#{playlist_uri}/tracks"
      tracks.each_slice(100) do |batch|
        body = { "uris" => tracks}
        response = spotify_api_request(uri, body, "post")
        return JSON.parse(response.body)["uri"]
      end
    end



    def create_spotify_playlist(user_name, playlist_name, public_status)
      uri = "https://api.spotify.com/v1/users/#{user_name}/playlists"
      body = {
          "name" => playlist_name[0..120],
          "public" => public_status
        }
      response = spotify_api_request(uri, body, "post")
      return JSON.parse(response.body)["uri"].to_s.split(":")[4]
    end

    def search_spotify_tracks(track, artist)
      formatted_track = track.gsub(" ","%20").downcase
      formatted_artist = artist.gsub(" ","%20").downcase
      if formatted_track.to_s != ""
        options = {limit: 50, offset: 0, market: "GB", type: "track"}

        body = nil
        uri = "https://api.spotify.com/v1/search/?q=track:#{formatted_track}%20artist:#{formatted_artist}&limit=#{options[:limit]}&offset=#{options[:offset]}&type=#{options[:type]}&market=#{options[:market]}"

        response = spotify_api_request(uri, body, "get")
        return JSON.parse(response.body)["tracks"]["items"]
      end
    end
  end
end
