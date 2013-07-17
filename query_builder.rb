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
                {
                    fuzzy_like_this: {
                        like_text: org['name'] || '',
                        fields: %w(name),
                        min_similarity: 0.5,
                        boost: 5.0
                    }
                },
                {
                    term: {
                        gov_id1: {
                            term: org['gov_id1'] || '',
                            boost: 10.0
                        }
                    }
                },
                {
                    fuzzy_like_this: {
                        like_text: org['city'] || '',
                        fields: %w(city),
                        min_similarity: 0.7,
                        boost: 4.0
                    }
                },
                {
                    match_phrase: {
                        state: {
                            query: org['state'] || '',
                            boost: 4.0
                        }
                    }
                },
            ],
            must: [],
            minimum_should_match: 2
        }
    }
  end

end