
struct Node(T)
    property :data, :nexts

    def initialize(@data: T)
        @nexts = Array(Int).build( capacity: 10 )
    end
end


class SkipList(T)
    def initialize
    end
end