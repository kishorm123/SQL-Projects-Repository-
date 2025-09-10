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
