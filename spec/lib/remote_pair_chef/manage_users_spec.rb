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

  it "creates a valid user given a github user_id" do
    cudb = ManageUsers.new(users: [user], path: tmp_dir)
    cudb.create_users

    expect(File.read("#{tmp_dir}/#{ManageUsers::PREFIX}_#{user}.json")).to eq(File.read("spec/fixtures/#{user}.json").chomp)
  end

  after(:all) do
    FileUtils.remove_entry tmp_dir
  end
end
