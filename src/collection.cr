

class Collection
    property :items
    @items = Hash(Id, Item).new
    @text_index = Idx.new { |h, k| Set(Id).new }
    @facet_indexes = Hash( String, Idx ).new { | h, k |
          Idx.new { |h2, k2|
            Set(Id).new
          }
    }

    def initialize(@cfg : CollectionCfg)
    end


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
          toks = tokenize( val.as_s )
          toks.map { |tok|
            @text_index[ tok ].add( id )

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
