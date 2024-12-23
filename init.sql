CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  title VARCHAR(100) NOT NULL,
  content TEXT NOT NULL,
  user_id INTEGER NOT NULL REFERENCES users(id),
  category_id INTEGER NOT NULL REFERENCES categories(id),
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE comments (
  id SERIAL PRIMARY KEY,
  content TEXT NOT NULL,
  user_id INTEGER NOT NULL REFERENCES users(id),
  post_id INTEGER NOT NULL REFERENCES posts(id),
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

INSERT INTO users (name, email, password) VALUES
  ('John Doe', 'john@example.com', 'password123'),
  ('Jane Doe', 'jane@example.com', 'password123');

INSERT INTO categories (name) VALUES
  ('Technology'),
  ('Personal'),
  ('Travel');

INSERT INTO posts (title, content, user_id, category_id) VALUES
  ('My First Post', 'This is my first post.', 1, 1),
  ('My Second Post', 'This is my second post.', 2, 2),
  ('My Third Post', 'This is my third post.', 1, 3);

INSERT INTO comments (content, user_id, post_id) VALUES
  ('This is a great post!', 2, 1),
  ('I agree with this post.', 1, 2),
  ('This post is awesome!', 2, 3);
