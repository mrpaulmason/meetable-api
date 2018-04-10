# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

Rails.logger = Logger.new(STDOUT)

Rails.logger.level = 3
ActiveRecord::Base.logger = nil
