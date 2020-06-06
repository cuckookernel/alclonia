

class Item
    property :rec, :raw
    @is_deleted: Bool = false

    def initialize(@rec : Hash(String, JSON::Any), @raw : String )
    end
end


alias Msg = Hash(String, String)

# type used for individual document ids
alias Id = Int64

# The result of applying a filter
alias FilterResult = Set(Id)

# A fld name
alias FldName = String

# mapping from indexed string value to the
# documents ids that contain this value
alias Idx = Hash(String, FilterResult)

