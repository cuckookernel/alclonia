require "./core"
require "./collection"


alias FilterResult = Set(Id)


module Filter
    # run this filter over a collection returning the collection of document ids that match
    def run( coll : Collection ) : FilterResult
    end
end


class EqFilterStr
    def initialize( @fld : String, @value : String )
    end

    def run( coll : Collection ) : FilterResult
        if coll.is_facet( @fld )
            return coll.facet_indexes[@fld][@value]
        else
            raise Exception.new("EqFilter doesn't work yet for non-faceted fields")
        end
    end
end


class GtFilter
    def initialize( @field, @value )
    end

    def run( coll : Collection ) : FilterResult
        if coll.is_numeric( @fld )
            return coll.numeric_indexes[@fld]
        else
            raise Exception.new("GtFilter doesn't work yer for non-numeric fields")
        end
    end
end
