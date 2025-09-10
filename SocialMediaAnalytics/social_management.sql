-- Complete Social Media Analytics Backend (PostgreSQL)
-- schema + sample data + views + triggers + rankings + reports

-- Social Media Analytics Backend - Schema (PostgreSQL)
-- Tables: users, posts, likes, comments

DROP TABLE IF EXISTS likes CASCADE;
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS posts CASCADE;
DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (
    user_id     SERIAL PRIMARY KEY,
    username    VARCHAR(50) NOT NULL UNIQUE,
    email       VARCHAR(120) NOT NULL UNIQUE,
    join_date   DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE posts (
    post_id     SERIAL PRIMARY KEY,
    user_id     INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    content     TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    like_count  INT NOT NULL DEFAULT 0
);

CREATE TABLE likes (
    user_id     INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    post_id     INT NOT NULL REFERENCES posts(post_id) ON DELETE CASCADE,
    liked_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, post_id)
);

CREATE TABLE comments (
    comment_id  SERIAL PRIMARY KEY,
    user_id     INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    post_id     INT NOT NULL REFERENCES posts(post_id) ON DELETE CASCADE,
    content     TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_posts_user ON posts(user_id, created_at DESC);
CREATE INDEX idx_likes_post ON likes(post_id, liked_at DESC);
CREATE INDEX idx_comments_post ON comments(post_id, created_at DESC);


-- ===== SAMPLE DATA =====
INSERT INTO users (username, email, join_date) VALUES
('alice','alice@example.com', CURRENT_DATE - INTERVAL '10 days'),
('bob','bob@example.com', CURRENT_DATE - INTERVAL '9 days'),
('chloe','chloe@example.com', CURRENT_DATE - INTERVAL '8 days'),
('dan','dan@example.com', CURRENT_DATE - INTERVAL '7 days'),
('emma','emma@example.com', CURRENT_DATE - INTERVAL '6 days');

INSERT INTO posts (user_id, content, created_at) VALUES
(1, 'Hello world! First post 🎉', NOW() - INTERVAL '5 days'),
(2, 'Coffee or tea? ☕️', NOW() - INTERVAL '3 days'),
(3, 'Hiking photos from the weekend 🏔️', NOW() - INTERVAL '2 days'),
(1, 'Learning PostgreSQL window functions!', NOW() - INTERVAL '1 day'),
(4, 'What book should I read next?', NOW() - INTERVAL '12 hours');

INSERT INTO likes (user_id, post_id, liked_at) VALUES
(2,1, NOW() - INTERVAL '4 days'),
(3,1, NOW() - INTERVAL '4 days'),
(4,1, NOW() - INTERVAL '3 days'),
(1,2, NOW() - INTERVAL '3 days'),
(3,2, NOW() - INTERVAL '2 days'),
(5,2, NOW() - INTERVAL '2 days'),
(1,3, NOW() - INTERVAL '2 days'),
(2,3, NOW() - INTERVAL '2 days'),
(5,3, NOW() - INTERVAL '1 day'),
(2,4, NOW() - INTERVAL '20 hours'),
(3,4, NOW() - INTERVAL '18 hours');

INSERT INTO comments (user_id, post_id, content, created_at) VALUES
(3,1,'Congrats!', NOW() - INTERVAL '4 days'),
(4,1,'Welcome 🎉', NOW() - INTERVAL '3 days'),
(1,2,'Both 😄', NOW() - INTERVAL '3 days'),
(5,2,'Tea!', NOW() - INTERVAL '2 days'),
(2,3,'Amazing pics', NOW() - INTERVAL '2 days'),
(5,3,'Love this trail', NOW() - INTERVAL '1 day'),
(1,4,'Same here!', NOW() - INTERVAL '20 hours'),
(3,4,'Window funcs rock', NOW() - INTERVAL '18 hours'),
(4,5,'Try Dune!', NOW() - INTERVAL '10 hours');

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


-- Trigger function and triggers to maintain like_count in posts (PostgreSQL)

CREATE OR REPLACE FUNCTION trg_update_like_count() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE posts SET like_count = like_count + 1 WHERE post_id = NEW.post_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE posts SET like_count = GREATEST(like_count - 1, 0) WHERE post_id = OLD.post_id;
        RETURN OLD;
    ELSE
        RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS likes_after_insert ON likes;
CREATE TRIGGER likes_after_insert
AFTER INSERT ON likes
FOR EACH ROW
EXECUTE FUNCTION trg_update_like_count();

DROP TRIGGER IF EXISTS likes_after_delete ON likes;
CREATE TRIGGER likes_after_delete
AFTER DELETE ON likes
FOR EACH ROW
EXECUTE FUNCTION trg_update_like_count();


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

