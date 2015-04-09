class Response < ActiveRecord::Base
  validates :responder_id, :answer_choice_id, presence: true

  belongs_to :respondent,
    class_name: "User",
    foreign_key: :responder_id,
    primary_key: :id

  belongs_to :answer_choice,
    class_name: "AnswerChoice",
    foreign_key: :answer_choice_id,
    primary_key: :id

end
