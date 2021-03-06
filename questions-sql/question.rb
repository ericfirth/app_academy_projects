
class Question

  def self.all
    results = QuestionDatabase.instance.execute('SELECT * FROM questions')
    results.map { |result| Question.new(result) }
  end

  def self.find_by_id(id)
    results = QuestionDatabase.instance.execute(<<-SQL, id)

    SELECT
      *
    FROM
      questions
    WHERE
      id = ?
    SQL

    Question.new(results.first)
  end

  def self.find_by_author_id(author_id)
    results = QuestionDatabase.instance.execute(<<-SQL, author_id)

    SELECT
      *
    FROM
      questions
    WHERE
      user_id = ?

    SQL

    results.map {|result| Question.new(result)}

  end

  def self.most_followed(n)
    QuestionFollow::most_followed_questions(n)
  end

  def self.most_liked(n)
    QuestionLike::most_liked_questions(n)
  end

  attr_accessor :title, :body
  attr_reader :id, :user_id

  def initialize(options = {})
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def save
    if id.nil?
      QuestionDatabase.instance.execute(<<-SQL, title, body, user_id)
        INSERT INTO
          questions(title, body, user_id)
        VALUES
          (?, ?, ?)
      SQL

      @id = QuestionDatabase.instance.last_insert_row_id
    else
      QuestionDatabase.instance.execute(<<-SQL, title, body, user_id, self.id)
        UPDATE
          questions
        SET
          title = ?,
          body = ?,
          user_id = ?
        WHERE
          id = ?
      SQL
    end

  end

  def author
    User::find_by_id(self.user_id)
  end

  def replies
    Reply::find_by_question_id(self.id)
  end

  def followers
    QuestionFollow::followers_for_question_id(self.id)
  end

  def likers
    QuestionLike::likers_for_question_id(self.id)
  end

  def num_likes
    QuestionLike::num_likes_for_question_id(self.id)
  end

end
