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
      _init_required!
      Dromelib::Env.value_for(:gmail_username) || Dromelib::Config.gmail.username
    end

    def password
      _init_required!
      Dromelib::Env.value_for(:gmail_password) || Dromelib::Config.gmail.password
    end

    def from
      _init_required!
      Dromelib::Env.value_for(:gmail_from) || Dromelib::Config.gmail.from
    end

    def subject_prefix
      _init_required!
      Dromelib::Env.value_for(:gmail_subject_prefix) || Dromelib::Config.gmail.subject_prefix
    end

    def configured?
      _init_required!
      (username && password && !username.empty? && !password.empty?) || false
    end

    def unread_count
      _init_required!

      fail MissingCredentialsError unless configured?

      gmail = Gmail.connect!(username, password)
      count = _from_or_total_unread_count(gmail)
      gmail.logout

      return count
    end

    def valid_from?
      !from.nil? && !(from =~ /.+@.+\..+/).nil?
    end

    def each_unread_email
      _init_required!
      _read_required!

      gmail = Gmail.connect!(username, password)
      gmail.inbox.find(:unread, from: from).each do |email|
        yield email
        sleep 1
      end
      gmail.logout
    end

    def show_unread
      each_unread_email do |email|
        if (auido = _extract_auido_from_email_subject(email.subject))
          puts "=> Entry: #{auido} (#{email.attachments.size} attachment/s)"
          _process_attachments email
        end
      end
    end

    def import!
      each_unread_email do |email|
        if (auido = _extract_auido_from_email_subject(email.subject))
          Dromelib.drome.create_entry!(auido)
          _process_attachments email

          email.read!
        end
      end
    end

    private

    def _init_required!
      fail Dromelib::UninitializedError unless Dromelib.initialized?
    end

    def _read_required!
      fail MissingCredentialsError,
           'Credentials not present neither env. nor Yaml' unless configured?
      fail MissingFromError,
           'Required to import only emails from there' unless valid_from?
    end

    def _extract_auido_from_email_subject(subject)
      decoded = Rfc2047.decode(subject).strip
      if subject_prefix && (subject_prefix.size > 0)
        decoded[/^#{subject_prefix} (.+)$/i, 1]
      else
        decoded
      end
    end

    def _from_or_total_unread_count(gmail)
      if from
        from.split(',').map do |address|
          gmail.inbox.count(:unread, from: address)
        end.reduce(:+)
      else
        gmail.inbox.count :unread
      end
    end

    def _process_attachments(email)
      email.attachments.each do |attachment|
        folder = Dir.pwd + '/tmp/'
        filepath = File.join(folder, attachment.filename)
        if File.exist?(filepath)
          puts "     Attachment #{filepath} exists, skipping it."
        else
          puts "     Saving attachment #{attachment.filename} in #{folder}..."
          File.write(filepath, attachment.body.decoded)
        end
      end
    end
  end
end
