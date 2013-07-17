class QueryBuilder

  def self.detect_duplicates_of(org_flat)
    {
        query: v2(org_flat),
        size: 5
    }
  end

  private

  def self.v2(org)
    {
        bool: {
            should: [
                #{
                #    fuzzy_like_this: {
                #        like_text: org['id'] || '',
                #        fields: ['id'],
                #        max_query_terms: 1,
                #        min_similarity: 0.9
                #    }
                #},
                {
                    fuzzy_like_this: {
                        like_text: org['name'] || '',
                        fields: %w(name),
                        min_similarity: 0.5,
                        boost: 5.0
                    }
                },
                {
                    fuzzy_like_this: {
                        like_text: org['gov_id1'] || '',
                        fields: %w(gov_id1),
                        prefix_length: 4,
                        min_similarity: 0.9,
                        boost: 10.0
                    }
                },
                {
                    fuzzy_like_this: {
                        like_text: org['city'] || '',
                        fields: %w(city),
                        min_similarity: 0.6,
                        boost: 4.0
                    }
                },
                {
                    fuzzy_like_this: {
                        like_text: org['state'] || '',
                        fields: %w(state),
                        max_query_terms: 1,
                        min_similarity: 0.5,
                        boost: 4.0
                    }
                },
                #{
                #    fuzzy_like_this: {
                #        like_text: org['country'] || '',
                #        fields: ['country'],
                #        max_query_terms: 3,
                #        min_similarity: 0.8,
                #        boost: 1
                #    }
                #},
            ],
            must: [],
            minimum_should_match: 1
        }
    }
  end

end