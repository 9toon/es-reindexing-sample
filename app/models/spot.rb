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

  def self.create_index!(name: )
    client = __elasticsearch__.client

    client.indices.create(
      index: name,
      body: { settings: self.settings.to_hash, mappings: self.mappings.to_hash }
    )
  end
end
