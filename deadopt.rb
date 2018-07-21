require "set"
class DeadOpt
  def initialize(code)
    @code=code
    @always=["call","func"]
    @ignore=["call","func"]
  end
  def optimize()
    optimized=false
    while true
      table=Set.new
      @code.each do |quad|
        next if @ignore.include? quad[1]
        if quad[2]
          table.add quad[2] if quad[2].is_a? String
        end
        if quad[3]
          table.add quad[3] if quad[2].is_a? String
        end
      end
      dupcode=@code.clone
      @code=[]
      dupcode.each do |quad|
        if @always.include? quad[1]
          if quad[0]
            if !(table.include? quad[0])
              quad[0]=nil
              optimized=true
            end
          end
          @code.push quad
        else
          if quad[0]
            if table.include? quad[0]
              @code.push quad
            else
              optimized=true
            end
          else
            @code.push quad
          end
        end
      end
      break if optimized==false
      optimized=false
    end
    return @code
  end
end
