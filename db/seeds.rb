User.create!(name:  "User 1",
             email: "user1@gmail.com",
             logged: false,
             password:              "foobar",
             password_confirmation: "foobar",
             host: false)

99.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@gmail.com"
  password = "password"
  User.create!(name:  name,
               email: email,
               logged: false,
               password:              password,
               password_confirmation: password,
               host: false)
end

#Game.create!(name: "Game 1",
 #           pending: true,
  #          done: false)
