require 'rspotify'
require 'net/http'
require 'uri'
require 'base64'

module SpotifyPlaylists
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

  def get_access_token
    auth_info = ENV["SPOT_ID"] + ":" + ENV["SPOT_SECRET"]
    encoded_auth_info = Base64.strict_encode64(auth_info)
    redirect_uri = "http://localhost:8082/"
    uri = URI.parse("https://accounts.spotify.com/api/token")
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Basic " + encoded_auth_info
    request.set_form_data(
    "grant_type" => "refresh_token",
    "refresh_token" => ENV["SPOT_REFRESH_TOKEN"]
    )
    puts request["Authorization"]
    req_options = {
    use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|

      http.request(request)
    end

    return JSON.parse(response.body)["access_token"]
  end

  def spotify_api_request(uri,body,access_token,type)
    uri = URI.parse(uri)
    if type == "post"
      request = Net::HTTP::Post.new(uri)
    elsif type == "put"
      request = Net::HTTP::Put.new(uri)
    end
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{access_token}"
    request.body = JSON.dump(body)

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end

  def replace_spotify_playlist(user_name, access_token, playlist_uri, tracks)
    uri = "https://api.spotify.com/v1/users/#{user_name}/playlists/#{playlist_uri}/tracks"
    body = {
        "uris" => tracks
      }
    puts tracks
    response = spotify_api_request(uri, body, access_token, "put")
    puts response.body
    return JSON.parse(response.body)["uri"]
  end


  def create_spotify_playlist(user_name, access_token, playlist_name, public)
    uri = "https://api.spotify.com/v1/users/#{user_name}/playlists"
    body = {
        "name" => playlist_name,
        "public" => public
      }
    response = spotify_api_request(uri, body, access_token, "post")
    puts response.body
    puts JSON.parse(response.body)["uri"].to_s.split(":")[4]
    puts JSON.parse(response.body)["uri"]
    return JSON.parse(response.body)["uri"].to_s.split(":")[4]
  end
end
