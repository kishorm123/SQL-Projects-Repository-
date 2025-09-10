-- Views: top posts and engagement view

-- Top posts by like_count
CREATE OR REPLACE VIEW vw_top_posts_by_likes AS
SELECT
    p.post_id,
    u.username AS author,
    p.content,
    p.created_at,
    p.like_count
FROM posts p
JOIN users u ON u.user_id = p.user_id
ORDER BY p.like_count DESC, p.created_at DESC;

-- Engagement view (likes + comments)
CREATE OR REPLACE VIEW vw_post_engagement AS
WITH lc AS (
  SELECT post_id, COUNT(*) AS like_total FROM likes GROUP BY post_id
),
cc AS (
  SELECT post_id, COUNT(*) AS comment_total FROM comments GROUP BY post_id
)
SELECT
  p.post_id,
  u.username AS author,
  p.content,
  p.created_at,
  COALESCE(lc.like_total, 0)    AS likes,
  COALESCE(cc.comment_total, 0) AS comments,
  COALESCE(lc.like_total, 0) + COALESCE(cc.comment_total, 0) AS engagement_score
FROM posts p
JOIN users u ON u.user_id = p.user_id
LEFT JOIN lc ON lc.post_id = p.post_id
LEFT JOIN cc ON cc.post_id = p.post_id;
