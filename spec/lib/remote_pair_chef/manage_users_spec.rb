require 'spec_helper'
require_relative '../../../lib/remote_pair_chef/manage_users'

require 'tmpdir'
describe ManageUsers do
  let(:user)    { "rondale-sc" }
  let(:tmp_dir) { Dir.mktmpdir }

  before do
    stub_request(:get, "https://api.github.com/users/#{user}/keys")
                .to_return(:body => [{"id"=>138663,"key"=>"dummysshkey" }].to_json)
  end

  subject(:manager) { ManageUsers.new }

  context "#initialize" do
    it "defaults #path properly" do
      expect(manager.path).to eql('data_bags/users')
    end

    it "initializes #users" do
      expect(manager.users).to eql([])
    end

    it "accepts a list of valid users" do
      manager = ManageUsers.new(users: [user])

      expect(manager.users).to eql([user])
    end

    it "accepts a data_bag path" do
      manager = ManageUsers.new(path: tmp_dir)

      expect(manager.path).to eql(tmp_dir)
    end

    it "populates #users from ENV vars" do
      manager = ManageUsers.new(env: {'RPC_HOST' => 'rjackson','RPC_PAIR' => 'rondale-sc'})

      expect(manager.users).to eql(['rjackson','rondale-sc'])
    end
  end

  it "creates a valid user given a github user_id" do
    pending
    manger = ManageUsers.new(users: [user], path: tmp_dir)
    manger.create_users

    expect(File.read("#{tmp_dir}/#{ManageUsers::DATA_BAG_PREFIX}_#{user}.json")).to eq(File.read("spec/fixtures/#{user}.json").chomp)
  end

  context "#add" do
    it "adds the user provided to the list of valid users" do
      manager.add(user)

      expect(manager.users).to eql([user])
    end

    it "allows passing an array of users" do
      manager.add('user_1', 'user_2')

      expect(manager.users).to eql(['user_1','user_2'])
    end
  end

  context "#remove" do
    it "removes the user provided from the list of valid users" do
      manager = ManageUsers.new(users: [user, 'user_1'])

      manager.remove(user)

      expect(manager.users).to eql(['user_1'])
    end

    it "removes all users provided from the list of valid users" do
      manager = ManageUsers.new(users: [user, 'user_1'])

      manager.remove(user, 'user_1')

      expect(manager.users).to eql([])
    end
  end

  after(:all) do
    FileUtils.remove_entry tmp_dir
  end
end
