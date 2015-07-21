# Copyright 2015 The Cocktail Experience, S.L.
require 'gmail'
require 'rfc2047'
require_relative '../dromelib'

module Dromelib
  # Module to import auidos reading emails
  module GMail
    class MissingCredentialsError < StandardError; end

    extend self

    def username
      ENV['DROMELIB_GMAIL_USERNAME'] || Dromelib::Config.gmail.username
    end

    def password
      ENV['DROMELIB_GMAIL_PASSWORD'] || Dromelib::Config.gmail.password
    end

    def from
      ENV['DROMELIB_GMAIL_FROM'] || Dromelib::Config.gmail.from
    end

    def subject_prefix
      ENV['DROMELIB_GMAIL_PREFIX'] || Dromelib::Config.gmail.subject_prefix
    end

    def configured?
      (username && password && !username.empty? && !password.empty?) || false
    end

    def unread_count
      if configured?
        gmail = Gmail.connect!(username, password)
        unreads = gmail.inbox.count(:unread, :from => from)
        gmail.logout
        unreads
      else
        raise MissingCredentialsError 
      end
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

    def import!
      if configured?
        gmail = Gmail.connect!(username, password)
        gmail.inbox.find(:unread, :from => Dromelib::GMail.from).each do |email|
          puts "=> '#{email.subject}'"
          if tuit = Dromelib::GMail.extract_auido_from_email_subject(email.subject)
            puts 'tuiting: ' + tuit
            sleep 1
            #  email.read!
          end
        end
        gmail.logout
      else
        raise MissingCredentialsError 
      end
    end
  end
end
