require_relative 'org_helper'

class TestData
  def self.read_organizations

    def self.prepare_test_data
      file = File.new('FoundationCenter.txt', 'r')
      # skip headers:
      file.gets
      file
    end

    organizations = []

    file = prepare_test_data
    while (line = file.gets)
      org = OrgHelper.from_array(line.split(/\t+/))
      puts "Entry parsed: #{org}"

      organizations.push org
    end

    organizations
  end
end