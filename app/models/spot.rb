class Spot < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name "#{Rails.env}-#{Rails.application.class.to_s.downcase}-#{self.name.downcase}"

  mapping do
    indexes :id, type: 'string', index: 'not_analyzed'
    indexes :spot_name, type: 'string', analyzer: 'kuromoji'
    indexes :address, type: 'string', analyzer: 'kuromoji'
    indexes :location, type: 'geo_point'
  end

  settings index: {
    number_of_shards: 1,
    number_of_replicas: 0,
  }

  def as_indexed_json(options = {})
    { 'id'        => id,
      'spot_name' => name,
      'address'   => address,
      'location'  => "#{lat},#{lon}",
    }
  end

  class << self
    def create_index!(name: )
      client = __elasticsearch__.client

      client.indices.create(
        index: name,
        body: { settings: self.settings.to_hash, mappings: self.mappings.to_hash }
      )
    end

    def switch_alias!(alias_name: , new_index: )
      client = __elasticsearch__.client

      old_indexes = client.indices.get_alias(index: alias_name).keys

      actions = []
      actions << { add: { index: new_index, alias: alias_name } }
      old_indexes.each do |old_index|
        actions << { remove: { index: old_index, alias: alias_name } }
      end

      client.indices.update_aliases(body: { actions: actions })
    end
  end
end
