CREATE TABLE animes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    shikimori_id UNSIGNED INT NOT NULL UNIQUE,
    sr_id UNSIGNED INT DEFAULT NULL UNIQUE,
    name_en VARCHAR(255) COLLATE RTRIM NOT NULL,
    name_ru VARCHAR(255) COLLATE RTRIM DEFAULT NULL,
    last_episode UNSIGNED INT2 DEFAULT NULL,
    status TEXT CHECK( status IN ('anons','ongoing','released') ),
    kind TEXT CHECK( kind IN ('tv','movie','ova','ona','special','music') ) DEFAULT NULL,
    main_genre INT DEFAULT NULL,
    age_rating TEXT CHECK(age_rating IN ('g', 'pg', 'pg_13', 'r', 'r_plus', 'rx')) DEFAULT NULL,
    rating UNSIGNED INT2
);

CREATE TABLE genres (
    id INTEGER PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE anime_genres (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    anime_id INT NOT NULL,
    genre_id INT NOT NULL,
    FOREIGN KEY (anime_id) REFERENCES animes(id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres(id) ON DELETE CASCADE
);
CREATE UNIQUE INDEX anime_genre_id ON anime_genres (anime_id, genre_id);

CREATE TABLE episodes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    number UNSIGNED INT2,
    anime_id INTEGER NOT NULL,
    name VARCHAR(255) COLLATE RTRIM DEFAULT NULL,
    UNIQUE(anime_id, number),
    FOREIGN KEY (anime_id) REFERENCES animes(id) ON DELETE CASCADE
);

CREATE TABLE arches (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    anime_id INTEGER,
    start UNSIGNED INT2 NOT NULL,
    end UNSIGNED INT2 DEFAULT NULL,
    name VARCHAR(255)  COLLATE RTRIM,
    type TEXT CHECK( type IN('filler','default') ) NOT NULL,
    FOREIGN KEY (anime_id) REFERENCES animes(id) ON DELETE CASCADE
);

CREATE TABLE videos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    vendor_id INTEGER NOT NULL,
    anime_id INTEGER NOT NULL,
    episode_id INTEGER NOT NULL,
    video_id CHARINT NOT NULL,
    author_id INTEGER DEFAULT NULL,
    uploader_id INTEGER DEFAULT NULL,
    kind INTEGER NOT NULL,
    lang INTEGER DEFAULT NULL,
    FOREIGN KEY (anime_id) REFERENCES animes(id) ON DELETE CASCADE,
    FOREIGN KEY (episode_id) REFERENCES episodes(id),
    FOREIGN KEY (author_id) REFERENCES authors(id) ON DELETE SET NULL,
    FOREIGN KEY (uploader_id) REFERENCES users(id) ON DELETE SET NULL
);
CREATE INDEX anime_id_episode_idx ON videos (anime_id, episode_id);

CREATE TABLE vendors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(255) NOT NULL,
    domain VARCHAR(32) NOT NULL UNIQUE,
    template VARCHAR(128) NOT NULL,
    last_episode_id INT DEFAULT NULL
);

CREATE TABLE authors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(255) COLLATE RTRIM NOT NULL UNIQUE,
    regex VARCHAR(255) DEFAULT NULL
);

CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(255) COLLATE RTRIM NOT NULL UNIQUE,
    hash VARCHAR(32) DEFAULT NULL,
    avatar VARCHAR(255) DEFAULT NULL,
    sex TEXT CHECK( sex IN('male','female') ) DEFAULT 'male',
    scopes VARCHAR(255) DEFAULT NULL,
    last_active UNSIGNED INT,
    created_at UNSIGNED INT
);

CREATE TABLE user_settings(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL UNIQUE,
    preferred_video_kind TEXT CHECK(preferred_video_kind IN('dub', 'sub', 'nat')) DEFAULT 'dub',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE user_oauth(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    credits VARCHAR(512) DEFAULT NULL,
    FOREIGN KEY (service_id) REFERENCES oauth_services(id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
CREATE UNIQUE INDEX unique_user_service ON user_oauth (user_id, service_id);

CREATE TABLE oauth_services(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(255),
    client_id VARCHAR(128),
    client_secret VARCHAR(128)
);

CREATE TABLE rates (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    anime_id INTEGER DEFAULT NULL,
    user_id INTEGER NOT NULL,
    type TEXT CHECK( type IN('planned','watching','rewatching','on_hold','completed','dropped') ),
    episodes UNSIGNED INT2 DEFAULT 0,
    created_at UNSIGNED INTEGER,
    updated_at UNSIGNED INTEGER,
    FOREIGN KEY (anime_id) REFERENCES animes(id) ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);