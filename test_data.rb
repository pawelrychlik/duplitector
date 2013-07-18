require_relative 'org_helper'

class TestData

  def initialize(log)
    @log = log
  end

  def read_organizations(filename, n = nil)

    def limits_exceeded(counter, n)
      !n.nil? && counter >= n
    end

    def prepare_test_data(filename)
      file = File.new(filename, 'r')
      # skip headers:
      file.gets
      file
    end

    organizations = []

    file = prepare_test_data filename

    counter = 0
    while !limits_exceeded(counter, n) and line = file.gets
      org = OrgHelper.from_array(line.split(/\t/))
      @log.debug "Entry parsed: #{org}"

      organizations.push org
      counter += 1
    end

    file.close

    organizations
  end
end