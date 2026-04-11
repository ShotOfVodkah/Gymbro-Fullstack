-- +goose Up

ALTER TABLE posts
    ALTER COLUMN author_id TYPE INTEGER
    USING author_id::text::integer;

ALTER TABLE post_comments
    ALTER COLUMN author_id TYPE INTEGER
    USING author_id::text::integer;

ALTER TABLE post_reactions
    ALTER COLUMN user_id TYPE INTEGER
    USING user_id::text::integer;

ALTER TABLE community_members
    ALTER COLUMN user_id TYPE INTEGER
    USING user_id::text::integer;


-- +goose Down

ALTER TABLE community_members
    ALTER COLUMN user_id TYPE UUID
    USING lpad(user_id::text, 32, '0')::uuid;

ALTER TABLE post_reactions
    ALTER COLUMN user_id TYPE UUID
    USING lpad(user_id::text, 32, '0')::uuid;

ALTER TABLE post_comments
    ALTER COLUMN author_id TYPE UUID
    USING lpad(author_id::text, 32, '0')::uuid;

ALTER TABLE posts
    ALTER COLUMN author_id TYPE UUID
    USING lpad(author_id::text, 32, '0')::uuid;