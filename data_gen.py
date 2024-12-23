import psycopg2
from faker import Faker
import time

# Establish a database connection
connection = psycopg2.connect(
    dbname="test_db",
    user="postgres",
    password="postgres",
    host="localhost",
    port="5432"
)

# Create a Faker instance
faker = Faker()


# Generate sample data
def generate_posts(cursor, user_id: int, category_id: int):
    query = """
        INSERT INTO posts (title, content, user_id, category_id)
        VALUES (%s, %s, %s, %s);
    """
    post = (
        faker.sentence(nb_words=6),
        faker.text(max_nb_chars=200),
        user_id,
        category_id
    )
    cursor.execute(query, post)


def generate_comments(cursor, user_ids: int, post_ids: int, count=50):
    comment = (
        faker.text(max_nb_chars=100),
        user_ids,
        post_ids
    )
    query = """
        INSERT INTO comments (content, user_id, post_id)
        VALUES (%s, %s, %s);
    """
    cursor.execute(query, comment)


def get_n_posts(cursor) -> int:
    query = """
        SELECT MAX(id) FROM posts;
    """
    cursor.execute(query, ())
    results = cursor.fetchone()
    return results[0]


if __name__ == '__main__':
    try:
        with connection:
            while True:
                with connection.cursor() as cs:
                    # Generate and insert data
                    print("Generating posts...")
                    generate_posts(cs, faker.random_int(1, 2), faker.random_int(1, 3))
                    print("Posts generated.")
                    connection.commit()

                with connection.cursor() as cs:
                    print("Generating comments...")
                    max_posts = get_n_posts(cs)
                    n_comments_to_add = faker.random_int(1, 10)
                    for _ in range(n_comments_to_add):
                        generate_comments(cs,
                                          faker.random_int(1, 2),
                                          faker.random_int(1, max_posts))
                    print("Comments generated.")
                    connection.commit()

                print("Data generation complete! Waiting for 30 seconds... 🐾")
                time.sleep(30)


    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        connection.close()
