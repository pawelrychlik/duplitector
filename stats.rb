class Stats

  def initialize
    @not_duplicated = 0
    @duplicated = 0
  end

  def not_duplicate
    @not_duplicated += 1
  end

  def duplicate
    @duplicated += 1
  end

  def to_s
    "Organizations created: #{@not_duplicated}, Organizations resolved as duplicates: #{@duplicated}"
  end
end