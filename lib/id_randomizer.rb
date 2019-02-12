require 'id_randomizer/generator'
require 'id_randomizer/acts_as_id_randomizer'

ActiveRecord::Base.send(:include, IdRandomizer::ActsAsIdRandomizer)
