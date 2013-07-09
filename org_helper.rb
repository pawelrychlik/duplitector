class OrgHelper
  @@keys = %w( id name address1 address2 city state postal_code country gov_id1 gov_id2 gov_id3 url telephone fax mail
                date_updated group_id )

  def self.from_array(array)
    @@keys.zip(array).inject({}) do |k, v|
      k.merge!({ v[0] => v[1] })
    end
  end

  # e.g. { id: "abc" } becomes { id: [ "abc" ] }
  def self.with_attributes_as_arrays(org)
    Hash[org.map { |k, v| [ k, [v] ] } ]
  end

  def self.merge(hash1, hash2)
    hash1.merge(hash2) do |key, a, b|
      if a.kind_of?(Array) then
        # merging duplicate keys is about putting all their values to a common array
        # e.g. given:
        # hash1 = { id: [ "1" ], name: [ "abc" ], es_id: 3 }
        # hash2 = { id: [ "1" ], name: [ "def" ] }
        # output is { id: [ "1", "1" ], name: [ "abc", "def" ], es_id: 3 }
        a.push(*b)
      else
        a != nil ? a : b
      end
    end
  end

end