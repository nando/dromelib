# Copyright 2015 The Cocktail Experience, S.L.
require 'gmail'
require 'rfc2047'
require_relative '../dromelib'

module Dromelib
  # Module to import auidos reading emails
  module GMail
    class MissingCredentialsError < StandardError; end
    class MissingFromError < StandardError; end

    extend self

    def username
      init_required!
      Dromelib::Env.value_for(:gmail_username) || Dromelib::Config.gmail.username
    end

    def password
      init_required!
      Dromelib::Env.value_for(:gmail_password) || Dromelib::Config.gmail.password
    end

    def from
      init_required!
      Dromelib::Env.value_for(:gmail_from) || Dromelib::Config.gmail.from
    end

    def subject_prefix
      init_required!
      Dromelib::Env.value_for(:gmail_prefix) || Dromelib::Config.gmail.subject_prefix
    end

    def configured?
      init_required!
      (username && password && !username.empty? && !password.empty?) || false
    end

    def unread_count
      init_required!
      raise MissingCredentialsError unless configured?

      gmail = Gmail.connect!(username, password)
      count = gmail.inbox.count(:unread, :from => from)
      gmail.logout
      return count
    end

    def import!
      init_required!
      raise MissingCredentialsError,
            'Credentials not present neither env. nor Yaml' unless configured?
      raise MissingFromError,
            'Required to import only emails from there' unless valid_from?

      gmail = Gmail.connect!(username, password)
      gmail.inbox.find(:unread, :from => from).each do |email|
        puts "=> '#{email.subject}'"
        if tuit = extract_auido_from_email_subject(email.subject)
          puts ' Importing: ' + tuit
          sleep 1
          #  email.read!
        end
      end
      gmail.logout
    end

    private

    def init_required!
      raise Dromelib::UninitializedError unless Dromelib.initialized?
    end

    def valid_from?
      !from.nil? && !(from =~ /.+@.+/).nil?
    end

    def extract_auido_from_email_subject(subject)
      decoded = Rfc2047.decode(subject).strip
      if subject_prefix and subject_prefix.size > 0
        if decoded =~ /^#{subject_prefix} (.+)$/i
          Regexp.last_match 1
        end
      else
        decoded
      end
    end
  end
end
