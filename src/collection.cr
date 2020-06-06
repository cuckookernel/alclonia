
require "./core"
require "./numeric_idx"
require "./util"

class Collection
    property :items

    # mapping an item id to its content
    @items = Hash(Id, Item).new

    # mapping of term -> Set(Id) = { document ids that contain term in any of the text fields}
    @term_index = Idx.new { |term, _k | FilterResult.new }

    # @facet_indexes[fld][val] will contain the set of document ids which
    # contain value `val` in field `fld`
    @facet_indexes = Hash( FldName, Idx ).new
    @numeric_indexes = Hash( FldName, NumericIdx ).new

    @all_fields : Set(FldName)

    def initialize(@cfg : CollectionCfg)
      @cfg.facet_fields.map { |fld|
        @facet_indexes[fld] = Idx.new { |val, _id| FilterResult.new }
      }

      @cfg.numeric_fields.map { |fld| @numeric_indexes[fld] = NumericIdx.new }

      @all_fields = @cfg.facet_fields.to_set + @cfg.numeric_fields.to_set + @cfg.text_fields.to_set
    end

    # whether the named field is a facet field
    def is_facet(@fld : FieldName) : Bool
      @facet_indexes.has_key?( fld )
    end

    # populate collection from a file in which each line is a separate json
    def populate_from_file( fp : String )
      file_size = File.size(fp)
      puts "reading json lines from #{fp} (#{file_size} bytes)"

      elapsed = Time.measure do
        File.open( fp ).each_line do |line|
          add_one_from_json( line )
        end
      end

      el_secs = elapsed.total_seconds
      puts ( "collection populated with #{@items.size} in #{el_secs} s:" +
             "#{@items.size / el_secs} items/s, #{file_size / el_secs} bytes/s," +
             " #{file_size / @items.size} bytes/item" )
    end


    def add_one_from_json( line : String )
      obj = Hash(String, JSON::Any).from_json( line )
      item = Item.new( obj, line )

      id = obj[ @cfg.id_field ].as_i64
      @items[ id ] = item

      @cfg.text_fields.map { |fld|
        val = obj[fld]?

        unless val.nil?
          terms = Util.tokenize( val.as_s )
          terms.map { |term|
            @term_index[ term ].add( id )
          }
        end
      }

      @cfg.facet_fields.map { |fld|
        val = obj[fld]?

        unless val.nil?
          @facet_indexes[fld][val.as_s].add( id )
        end
      }
    end

    def run_filter(filter_str : String)

      parts = filter_str.split(':')

      filter_fld = parts[0]
      filter_val = parts[1]

      puts "search cmd filter: #{filter_fld} == #{filter_val}"

      @items.select { |item|
          rec = item.rec
          rec[filter_fld] == filter_val
      }
    end

  end
