require 'id_randomizer/generator'
require 'id_randomizer/acts_as_random_id'

ActiveRecord::Base.send(:include, IdRandomizer::ActsAsIdRandomizer)
