-- Ranking queries using window functions

-- Post rankings by engagement
CREATE OR REPLACE VIEW vw_post_rankings AS
SELECT
  post_id,
  author,
  content,
  created_at,
  likes,
  comments,
  engagement_score,
  RANK()       OVER (ORDER BY engagement_score DESC, created_at DESC) AS rank,
  DENSE_RANK() OVER (ORDER BY engagement_score DESC)                  AS dense_rank,
  ROW_NUMBER() OVER (ORDER BY engagement_score DESC, created_at DESC) AS row_number
FROM vw_post_engagement;
