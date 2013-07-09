require 'json'

class QueryBuilder

  # @query_template = JSON.parse(IO.read('query-template.json'))

  def self.detect_duplicates_of(org_flat)
    v1(org_flat)
  end

  private

  def self.v1(org)
    {
        bool: {
            should: [
                {
                    fuzzy_like_this: {
                        like_text: org['name'],
                        fields: ['name']
                    }
                }
            ],
            must: []
        }
    }
  end

  def self.v2(org)
    {
        filtered: {
            query: {
                bool: {
                    should: [
                        {
                            fuzzy_like_this: {
                                like_text: org['name'],
                                fields: ['name'],
                                max_query_terms: 3,
                                min_similarity: 0.4
                            }
                        },
                        {
                            fuzzy_like_this: {
                                like_text: org['id'],
                                fields: ['id'],
                                max_query_terms: 1,
                                prefix_length: 3,
                                boost: 10.0
                            }
                        }
                    ],
                    must: [],
                    minimum_should_match: 1
                }
            },
            filter: {
                term: {IsActive: false}
            }
        }
    }
  end

end