# Need the digest library for hash calculation.
require 'digest'

class User < ActiveRecord::Base
  # Create a virtual attribute "password"
  # A virtual attribute is an attribute not corresponding to a column in DB.
  attr_accessor :password
  attr_accessible :email, :name, :password, :password_confirmation

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name, :presence => true, 
                   :length => { :maximum => 50 }

  validates :email, :presence => true,
                    :format => { :with => email_regex },
                    :uniqueness => { :case_sensitive => false }

  # Add validations to the "password" attribute.
  # Also automatically create the virtual attribute "password_confirmation".
  validates :password, :presence => true,
                       :confirmation => true, # create "password_confirmation"
                       :length => { :within => 6..40 }

  before_save :encrypt_password

  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil if user.nil?
    return user if user.has_password?(submitted_password)
    return nil
  end

  private
    
    def encrypt_password
      self.encrypted_password = encrypt(password)
    end

    def encrypt(string)
      Digest::SHA2.hexdigest(string)
    end
end
