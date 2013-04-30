require 'net/http'
require 'json'
require 'uri'

class ManageUsers
  attr_accessor :path, :users

  DATA_BAG_PREFIX = "remote_pair_chef_auto"

  def initialize(opts = nil)
    opts ||= {}
    env    = opts.fetch(:env) { ENV }

    self.path   = opts.fetch(:path)  { "data_bags/users" }
    self.users  = opts.fetch(:users) { env.values_at('RPC_HOST','RPC_PAIR').compact }
  end

  def create_users
    @users.compact.each do |u|
      create_user_data_bag(u)
    end
  end

  def add(*users)
    self.users.concat Array(users)
  end

  def remove(*users)
    self.users.delete_if{|u| users.include?(u) }
  end

  private

  def create_user_data_bag(user)
    File.open("#{@path}/#{DATA_BAG_PREFIX}_#{user}.json", "w") do |f|
      f.write(user_json(user))
    end
  end

  def user_json(user)
    { id: user,
      username: user,
      home: "/home/#{user}",
      ssh_keys: get_keys(user) }.to_json
  end

  def get_keys(user)
    uri = URI.parse("https://api.github.com/users/#{user}/keys")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    JSON.parse(http.request(request).body).map {|k| k["key"] }
  end
end
