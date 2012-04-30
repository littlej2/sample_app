# By using the symbol ':user', we get Factory Girl to simulate the User model.
Factory.define :user do |user|
  user.name                  "Janelle Littlejohn"
  user.email                 "littlej2@umbc.edu"
  user.password              "Haruka87"
  user.password_confirmation "Haruka87"
end

Factory.sequence :email do |n|
  "person-#{n}@example.com"
end

Factory.define :micropost do |micropost|
  micropost.content "Foo bar"
  micropost.association :user
end
