class MappingProvider

  def mapping
    {
        temp: {
            properties: {
                address1: {
                    type: "string"
                },
                address2: {
                    type: "string"
                },
                city: {
                    type: "string"
                },
                country: {
                    type: "string"
                },
                date_updated: {
                    type: "string"
                },
                es_id: {
                    type: "long",
                    index: "not_analyzed"
                },
                fax: {
                    type: "string"
                },
                gov_id1: {
                    type: "string",
                    index: "not_analyzed"
                },
                gov_id2: {
                    type: "string",
                    index: "not_analyzed"
                },
                gov_id3: {
                    type: "string",
                    index: "not_analyzed"
                },
                id: {
                    type: "string",
                    index: "not_analyzed"
                },
                mail: {
                    type: "string"
                },
                name: {
                    type: "string"
                },
                postal_code: {
                    type: "string"
                },
                state: {
                    type: "string"
                },
                telephone: {
                    type: "string"
                },
                url: {
                    type: "string"
                }
            }
        }
    }
  end
end