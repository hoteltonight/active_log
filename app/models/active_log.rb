class ActiveLog < ActiveRecord::Base
  belongs_to :ar, :polymorphic => true
  serialize :changed_content, Hash
  serialize :meta_data, Hash
  
end