# 📱 Social Media Analytics Backend

## 🎯 Objective  
A PostgreSQL-based project to analyze **user engagement** (likes & comments) on social media posts.  
Covers schema design, sample data, views, triggers, window functions, and reporting.

---

## 📂 Repository Contents  
- **social_management.sql** → Full SQL (schema + sample data + views + triggers + rankings + reports)  
- **social_schema.sql** → Database schema only  
- **social_views.sql** → Views for top posts & engagement analysis  
- **social_triggers.sql** → Triggers for updating like counts  
- **social_rankings.sql** → Ranking queries using window functions  
- **social_reports.sql** → Report queries (top posts, active users, daily engagement)  
- **social_reports.xlsx** → Reports in Excel format  
- **social_reports.pdf** → Reports in PDF format  

---

## 🚀 Features  
1. **Schema**: Users, Posts, Likes, Comments.  
2. **Sample Data**: Preloaded dataset with 5 users, multiple posts, likes, and comments.  
3. **Views**:  
   - `vw_top_posts_by_likes` → top posts ranked by likes.  
   - `vw_post_engagement` → engagement score (likes + comments).  
4. **Window Functions**:  
   - `vw_post_rankings` → ranks posts using RANK, DENSE_RANK, and ROW_NUMBER.  
5. **Triggers**:  
   - Auto-update `like_count` in Posts when a like is added or removed.  
6. **Reports**:  
   - Post engagement summary.  
   - Top 5 posts by engagement.  
   - Daily engagement (likes & comments per day).  
   - Most active users (by likes + comments).  

---

## 📊 Sample Reports  
- **Excel** → [social_reports.xlsx](social_reports.xlsx)  
- **PDF** → [social_reports.pdf](social_reports.pdf)  

---

## 📌 Usage  
1. Import `social_management.sql` into PostgreSQL.  
2. Explore the schema and insert your own test data if needed.  
3. Example queries:  

```sql
-- Get top posts by engagement
SELECT * FROM vw_post_rankings ORDER BY rank LIMIT 5;

-- See engagement per post
SELECT * FROM vw_post_engagement;

-- Most active users
-- (likes + comments made)
SELECT u.username, COUNT(l.*) + COUNT(c.*) AS total_interactions
FROM users u
LEFT JOIN likes l ON l.user_id = u.user_id
LEFT JOIN comments c ON c.user_id = u.user_id
GROUP BY u.username
ORDER BY total_interactions DESC;