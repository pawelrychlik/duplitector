class Normalizer

  # works in-place
  def normalize(org)
    handle_no_values org
  end

  private
  def handle_no_values(org)
    org.each { |k, v| org[k] = v.strip unless v.nil? }.delete_if { |k, v| v.nil? or v.empty? }
  end
end