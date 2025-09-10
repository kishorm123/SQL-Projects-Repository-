-- Report queries

-- Top 5 posts by engagement
-- SELECT * FROM vw_post_rankings WHERE row_number <= 5 ORDER BY row_number;

-- Daily engagement summary (likes & comments per day)
-- SELECT date_trunc('day', created_at) AS day,
--   COUNT(*) FILTER (WHERE src = 'like') AS likes,
--   COUNT(*) FILTER (WHERE src = 'comment') AS comments
-- FROM (
--   SELECT liked_at AS created_at, 'like' AS src FROM likes
--   UNION ALL
--   SELECT created_at AS created_at, 'comment' AS src FROM comments
-- ) t
-- GROUP BY 1
-- ORDER BY 1;

-- Most active users (by interactions made)
-- SELECT u.user_id, u.username,
--   COUNT(l.*) AS likes_made,
--   COUNT(c.*) AS comments_made,
--   COUNT(l.*) + COUNT(c.*) AS total_interactions
-- FROM users u
-- LEFT JOIN likes l ON l.user_id = u.user_id
-- LEFT JOIN comments c ON c.user_id = u.user_id
-- GROUP BY u.user_id, u.username
-- ORDER BY total_interactions DESC;
