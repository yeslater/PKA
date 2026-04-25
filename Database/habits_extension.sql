-- ============================================================
-- Habits Tracking Extension
-- Atlas — added to PKA database
-- Run after pka_setup.sql
-- ============================================================

CREATE TABLE IF NOT EXISTS habits (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    name          TEXT NOT NULL UNIQUE,
    category      TEXT,
    score         INTEGER NOT NULL DEFAULT 1,
    display_order INTEGER DEFAULT 0,
    active        INTEGER DEFAULT 1,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS habit_logs (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    habit_id   INTEGER NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
    log_date   DATE NOT NULL,
    done       INTEGER DEFAULT 0,
    notes      TEXT,
    UNIQUE(habit_id, log_date)
);

CREATE INDEX IF NOT EXISTS idx_habit_logs_date  ON habit_logs(log_date);
CREATE INDEX IF NOT EXISTS idx_habit_logs_habit ON habit_logs(habit_id);

-- ============================================================
-- VIEW — daily score summary per habit
-- ============================================================

CREATE VIEW IF NOT EXISTS v_habit_stats AS
SELECT
    h.id,
    h.name,
    h.score,
    h.category,
    COUNT(CASE WHEN l.done = 1 THEN 1 END)                        AS days_done,
    COUNT(l.id)                                                    AS days_logged,
    ROUND(COUNT(CASE WHEN l.done = 1 THEN 1 END) * 100.0
          / NULLIF(COUNT(l.id), 0), 1)                            AS completion_pct,
    COUNT(CASE WHEN l.done = 1 THEN 1 END) * h.score              AS total_score_earned
FROM habits h
LEFT JOIN habit_logs l ON l.habit_id = h.id
WHERE h.active = 1
GROUP BY h.id;

-- ============================================================
-- HABITS — Yvé's list (total max = 100 pts/day)
-- ============================================================

INSERT OR IGNORE INTO habits (name, score, display_order) VALUES
    ('Sommeil',    8,  1),
    ('Lumiere',    4,  2),
    ('Journal',    4,  3),
    ('Training',   6,  4),
    ('Challenge',  2,  5),
    ('Méditation', 4,  6),
    ('Gratitude',  1,  7),
    ('Protéines',  4,  8),
    ('H2O + Vit',  4,  9),
    ('Big P',      8, 10),
    ('Lecture',    6, 11),
    ('QT G K F',   6, 12),
    ('Musique',    2, 13),
    ('Photo',      1, 14),
    ('Big W',      8, 15),
    ('Plan',       4, 16),
    ('Étirements', 4, 17),
    ('SC',         4, 18),
    ('Exter',      4, 19),
    ('Bouffe',     4, 20),
    ('Entretien',  2, 21),
    ('DS',         5, 22),
    ('NFW60',      5, 23);
