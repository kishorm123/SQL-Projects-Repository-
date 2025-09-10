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
