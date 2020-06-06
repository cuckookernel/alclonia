
class CollectionCfg
    property :id_field, :text_fields, :numeric_fields, :facet_fields

    def initialize(@id_field : String,
                   @text_fields : Array(String),
                   @numeric_fields : Array(String),
                   @facet_fields : Array(String))
    end

    def self.from_file( fp : String )
      json_content = File.read( fp )
      obj = Hash(String, JSON::Any).from_json( json_content )

      xtract_strs = ->( j : JSON::Any) { j.as_a.map &.as_s }

      CollectionCfg.new(id_field: obj["id_field"].as_s,
                        text_fields: xtract_strs.call( obj["text_fields"] ),
                        numeric_fields: xtract_strs.call( obj["numeric_fields"] ),
                        facet_fields: xtract_strs.call( obj["facet_fields"] ) )
    end

end