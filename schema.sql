CREATE TABLE users (
    id uuid DEFAULT edgedb.uuid_generate_v1mc() NOT NULL,
    name TEXT NOT NULL,
    age INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP WITHOUT TIME ZONE,
    account_balance BIGINT,
    profile JSONB,
    avatar BYTEA,
    subscription_duration INTERVAL,
    birthdate DATE,
    preferred_time TIME,
    preferred_numbers SMALLINT[],
    salary DOUBLE PRECISION,
    score REAL
);
