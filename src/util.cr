
module Util
  def self.tokenize( a : String ) : Array(String)
    a.split(" ").map { |w| w.downcase }
  end
end
