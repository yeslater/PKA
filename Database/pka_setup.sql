-- ============================================================
-- PKA Personal Knowledge & CRM Database
-- Designed by Atlas for Yvé
-- SQLite compatible (PostgreSQL with minor type adjustments)
-- ============================================================


-- ============================================================
-- SECTION 1: LOOKUP / REFERENCE TABLES
-- ============================================================

CREATE TABLE IF NOT EXISTS relationship_types (
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
    -- Examples: family, friend, colleague, acquaintance, mentor
);

CREATE TABLE IF NOT EXISTS item_types (
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
    -- Examples: quote, text, article, website, book_excerpt, video, note
);

CREATE TABLE IF NOT EXISTS interaction_types (
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
    -- Examples: meeting, call, coffee, email_thread, casual_chat, event
);


-- ============================================================
-- SECTION 2: CRM — PEOPLE
-- ============================================================

CREATE TABLE IF NOT EXISTS people (
    id                   INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name           TEXT NOT NULL,
    last_name            TEXT,
    relationship_type_id INTEGER REFERENCES relationship_types(id),
    group_label          TEXT,        -- e.g. "Work", "Ultimate frisbee", "School parents"
    email                TEXT,
    phone                TEXT,
    birthday             DATE,
    notes                TEXT,
    created_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_people_name ON people(last_name, first_name);
CREATE INDEX IF NOT EXISTS idx_people_relationship ON people(relationship_type_id);


-- ============================================================
-- SECTION 3: CRM — INTERACTIONS (meetings, calls, conversations)
-- ============================================================

CREATE TABLE IF NOT EXISTS interactions (
    id                   INTEGER PRIMARY KEY AUTOINCREMENT,
    title                TEXT NOT NULL,
    interaction_type_id  INTEGER REFERENCES interaction_types(id),
    context              TEXT CHECK(context IN ('personal', 'work')),
    date                 DATE,
    notes                TEXT,        -- Full meeting notes or summary
    created_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Many-to-many: who was involved in an interaction
CREATE TABLE IF NOT EXISTS interaction_people (
    interaction_id INTEGER NOT NULL REFERENCES interactions(id) ON DELETE CASCADE,
    person_id      INTEGER NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    PRIMARY KEY (interaction_id, person_id)
);

CREATE INDEX IF NOT EXISTS idx_interactions_date ON interactions(date);
CREATE INDEX IF NOT EXISTS idx_interactions_context ON interactions(context);


-- ============================================================
-- SECTION 4: KNOWLEDGE BASE — TOPICS (Books of Thoughts)
-- ============================================================

CREATE TABLE IF NOT EXISTS topics (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- SECTION 5: KNOWLEDGE BASE — ITEMS (quotes, texts, websites, etc.)
-- ============================================================

CREATE TABLE IF NOT EXISTS items (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    title        TEXT,
    content      TEXT,         -- The quote, text body, or description of the website
    source_url   TEXT,         -- URL if applicable
    author       TEXT,         -- Author, speaker, or source name
    item_type_id INTEGER REFERENCES item_types(id),
    notes        TEXT,         -- Your personal reflection or annotation
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Many-to-many: assign items to topics (Books of Thoughts)
CREATE TABLE IF NOT EXISTS item_topics (
    item_id  INTEGER NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    topic_id INTEGER NOT NULL REFERENCES topics(id) ON DELETE CASCADE,
    PRIMARY KEY (item_id, topic_id)
);

CREATE INDEX IF NOT EXISTS idx_items_type ON items(item_type_id);
CREATE INDEX IF NOT EXISTS idx_items_created ON items(created_at);


-- ============================================================
-- SECTION 6: FLEXIBLE TAGGING
-- ============================================================

CREATE TABLE IF NOT EXISTS tags (
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

-- Tags can be applied to items
CREATE TABLE IF NOT EXISTS item_tags (
    item_id INTEGER NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    tag_id  INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (item_id, tag_id)
);

-- Tags can also be applied to people
CREATE TABLE IF NOT EXISTS people_tags (
    person_id INTEGER NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    tag_id    INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (person_id, tag_id)
);


-- ============================================================
-- SECTION 7: CROSS-DOMAIN LINKS
-- ============================================================

-- Link a knowledge item to a person (e.g. a quote from a colleague,
-- or a resource you want to share with someone)
CREATE TABLE IF NOT EXISTS item_people (
    item_id   INTEGER NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    person_id INTEGER NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    PRIMARY KEY (item_id, person_id)
);

-- Link a knowledge item to an interaction (e.g. an article discussed
-- in a meeting, or a quote that came up in a conversation)
CREATE TABLE IF NOT EXISTS interaction_items (
    interaction_id INTEGER NOT NULL REFERENCES interactions(id) ON DELETE CASCADE,
    item_id        INTEGER NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    PRIMARY KEY (interaction_id, item_id)
);


-- ============================================================
-- SECTION 8: SEED DATA — REFERENCE VALUES
-- ============================================================

INSERT OR IGNORE INTO relationship_types (name) VALUES
    ('family'),
    ('friend'),
    ('colleague'),
    ('acquaintance'),
    ('mentor'),
    ('contact');

INSERT OR IGNORE INTO item_types (name) VALUES
    ('quote'),
    ('text'),
    ('article'),
    ('website'),
    ('book_excerpt'),
    ('video'),
    ('note'),
    ('podcast_clip');

INSERT OR IGNORE INTO interaction_types (name) VALUES
    ('meeting'),
    ('call'),
    ('coffee'),
    ('email_thread'),
    ('casual_chat'),
    ('event'),
    ('presentation');


-- ============================================================
-- SECTION 9: SEED DATA — BOOKS OF THOUGHTS (Topics)
-- ============================================================

INSERT OR IGNORE INTO topics (name, description) VALUES
    ('Relationships',
     'Human connection, communication, emotional intelligence, and what makes relationships work'),

    ('Becoming a Better Lover',
     'Sensuality, physical intimacy, presence, attunement, and partnership — the full picture of intimacy'),

    ('Better Parenting',
     'Ideas, reflections, and frameworks for raising Matteo and Felix with intention and love'),

    ('Personal Growth',
     'Self-improvement, habits, resilience, identity, and becoming more intentional over time'),

    ('Health & Fitness',
     'Training, movement, recovery, nutrition, and aging well with strength and vitality'),

    ('Work & Leadership',
     'Professional craft, AI in finance, process improvement, team dynamics, and career clarity'),

    ('Philosophy & Wisdom',
     'Big ideas about how to live — values, meaning, time, and what matters most'),

    ('Communication',
     'How to express yourself clearly, listen deeply, and connect more authentically');


-- ============================================================
-- SECTION 10: USEFUL VIEWS FOR QUICK QUERIES
-- ============================================================

-- All items with their type name and topic names
CREATE VIEW IF NOT EXISTS v_items_full AS
SELECT
    i.id,
    i.title,
    i.author,
    it.name                          AS type,
    i.content,
    i.source_url,
    i.notes,
    GROUP_CONCAT(t.name, ' | ')      AS topics,
    i.created_at
FROM items i
LEFT JOIN item_types it       ON it.id = i.item_type_id
LEFT JOIN item_topics itop    ON itop.item_id = i.id
LEFT JOIN topics t            ON t.id = itop.topic_id
GROUP BY i.id;

-- All people with their relationship type
CREATE VIEW IF NOT EXISTS v_people_full AS
SELECT
    p.id,
    p.first_name,
    p.last_name,
    rt.name   AS relationship_type,
    p.group_label,
    p.email,
    p.phone,
    p.birthday,
    p.notes
FROM people p
LEFT JOIN relationship_types rt ON rt.id = p.relationship_type_id;

-- All interactions with participant names
CREATE VIEW IF NOT EXISTS v_interactions_full AS
SELECT
    i.id,
    i.title,
    it.name                              AS type,
    i.context,
    i.date,
    i.notes,
    GROUP_CONCAT(p.first_name || ' ' || COALESCE(p.last_name, ''), ', ') AS participants
FROM interactions i
LEFT JOIN interaction_types it    ON it.id = i.interaction_type_id
LEFT JOIN interaction_people ip   ON ip.interaction_id = i.id
LEFT JOIN people p                ON p.id = ip.person_id
GROUP BY i.id;
