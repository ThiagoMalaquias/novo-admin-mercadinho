namespace :users do
  desc "Users with courses lifetime"
  task users_with_courses_lifetime: :environment do
    users = User.distinct.joins(:user_courses).where("user_courses.lifetime = true and user_courses.authenticate = true")
    users.each do |user|
      UserTag.find_or_create_by(user: user, tag: Tag.find_by(name: "Aluno-Vitalicio"))
    end
  end
end
