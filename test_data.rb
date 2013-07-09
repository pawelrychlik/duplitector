require_relative 'org_helper'

class TestData
  def self.read_organizations(n)

    def self.limits_exceeded(counter, n)
      if n.nil? || n <= 0 then
        false
      else
        counter >= n
      end
    end

    def self.prepare_test_data
      file = File.new('FoundationCenter.txt', 'r')
      # skip headers:
      file.gets
      file
    end

    organizations = []

    file = prepare_test_data

    counter = 0
    while !limits_exceeded(counter, n) and line = file.gets
      org = OrgHelper.from_array(line.split(/\t+/))
      #puts "Entry parsed: #{org}"

      organizations.push org
      counter += 1
    end

    organizations
  end
end