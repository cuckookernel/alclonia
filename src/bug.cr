require "json"

module Bug
    class Buggy
        @a : JSON::Any = JSON.parse("{}")
    end
end