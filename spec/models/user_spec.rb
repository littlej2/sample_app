# == Schema Information
#
# Table name: users
#
# id :integer not null, primary key
# name :string(255)
# email :string(255)
# created_at :datetime
# updated_at :datetime
# encrypted_password :string(255)
# salt :string(255)
# admin :boolean default(FALSE)
#

require 'spec_helper'

describe User do

  before(:each) do
    @attr = {
      :name => 'Example User',
      :email => 'user@example.com',
      :password => 'foobar',
      :password_confirmation => 'foobar'
    }
  end

  it 'should create a new instance given valid attributes' do
    User.create!(@attr)
  end

  it 'should require a name' do
    no_name_user = User.new(@attr.merge( :name => '' ))
    no_name_user.should_not be_valid
  end

  it 'should requre an email address' do
    no_email_user = User.new(@attr.merge( :email => '' ))
    no_email_user.should_not be_valid
  end

  it 'should reject names that are too long' do
    long_name = 'a' * 51
    long_name_user = User.new(@attr.merge( :name => long_name ))
    long_name_user.should_not be_valid
  end

  it 'should accept valid email addresses' do
    addresses = %w[ user@foo.com example_user@foo.bar.org first.last@foo.jp ]
    addresses.each do |address|
      valid_email_user = User.new( @attr.merge( :email => address ))
      valid_email_user.should be_valid
    end
  end

  it 'should reject invalid email addresses' do
    addresses = %w[ user@foo,com user_at_foo.org user@foo. ]
    addresses.each do |address|
      invalid_email_user = User.new( @attr.merge( :email => address ))
      invalid_email_user.should_not be_valid
    end
  end

  it 'should reject duplicate email addresses' do
    # Create a user record with given email address
    User.create!(@attr)
    duplicate_email_user = User.new(@attr)
    duplicate_email_user.should_not be_valid
  end

  it 'should reject emails identical up to case' do
    upcased_email = @attr[:email].upcase
    User.create(@attr.merge( :email => upcased_email ))
    duplicate_email_user = User.new(@attr)
    duplicate_email_user.should_not be_valid
  end


  describe 'password validations' do

    it 'should require a password' do
      User.new(@attr.merge( :password => '', :password_confirmation => '')).
        should_not be_valid
    end

    it 'should require a valid matching password' do
      User.new(@attr.merge( :password_confirmation => 'invalid' )).
        should_not be_valid
    end

    it 'should reject short passwords' do
      short_password = 'a' * 5
      User.new(@attr.merge( :password => short_password,
                            :password_confirmation => short_password)).
        should_not be_valid
    end

    it 'should reject long passwords' do
      long_password = 'a' * 41
      User.new(@attr.merge( :password => long_password,
                            :password_confirmation => long_password)).
        should_not be_valid
    end
  end

  describe 'password encryption' do

    before(:each) do
      @user = User.create!(@attr)
    end

    it 'should have an encrypted password attribute' do
      @user.should respond_to(:encrypted_password)
    end

    it 'should set the encrypted password' do
      @user.encrypted_password.should_not be_blank
    end

    describe 'has_password? method' do

      it 'should be true if the passwords match' do
        @user.has_password?(@attr[:password]).should be_true
      end

      it "should be false if the passwords don't match" do
        @user.has_password?('invalid').should be_false
      end
    end

    describe 'authenticate method' do

      it 'should return nil on user/password mismatch' do
        wrong_password_user = User.authenticate(@attr[:email],
                                                'wrong_password')
        wrong_password_user.should be_nil
      end

      it 'should return nil for na email with no associated user' do
        nonexistent_user = User.authenticate('bar@foo.com', @attr[:password])
        nonexistent_user.should be_nil
      end

      it 'should return a matching user given valid credentials' do
              matching_user = User.authenticate(@attr[:email],
                                                @attr[:password])
              matching_user.should == @user
      end
    end
  end

  describe "admin attribute" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should respond to admin" do
      @user.should respond_to(:admin)
    end

    it "should not be and admin by default" do
      @user.should_not be_admin
    end

    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end

  describe "micropost associations" do

    before(:each) do
      @user = User.create(@attr)
      @mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
    end

    it "should have a microposts attribute" do
      @user.should respond_to(:microposts)
    end

    it "should have the right microposts in the right order" do
      @user.microposts.should == [@mp2, @mp1]
    end

    it "should destroy associated microposts" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end

    describe "status feed" do

      it "should have a feed" do
        @user.should respond_to(:feed)
      end

      it "should have the user's microposts" do
        @user.feed.should include(@mp1)
        @user.feed.should include(@mp2)
      end

      it "should not include a different user's microposts" do
        mp3 = Factory(:micropost,
                      :user => Factory(:user, :email => Factory.next(:email)))
        @user.feed.should_not include(mp3)
      end
    end
  end
end
