require 'json'

class QueryBuilder

  def self.detect_duplicates_of(org_flat)
    {
        query: v2(org_flat),
        size: 5
    }
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
                        like_text: org['gov_id1'],
                        fields: ['gov_id1'],
                        max_query_terms: 1,
                        prefix_length: 3,
                        boost: 10.0
                    }
                }
            ],
            must: [],
            minimum_should_match: 1
        }
    }
  end

end