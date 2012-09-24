class Combinatorics
  def self.permutations(n,r)
    factorial(n)/factorial(n-r)
  end

  def self.factorial(n)
    n > 0 ? (1..n).inject(:*) : 0
  end

  def self.pairs(list)
    list.map.with_index do |a, i|
      list.map.with_index do |b, j|
        if i != j
          [a,b]
        end
      end
    end.flatten(1).select{|exists| exists}
  end
end