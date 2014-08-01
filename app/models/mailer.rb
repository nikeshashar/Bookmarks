
def send_email(user,token)
  RestClient.post "https://api:key-dd499fed82249487919e1af19f7fd66f"\
  "@api.mailgun.net/v2/sandbox43830a12e14e48f0823d1f1f846435cc.mailgun.org/messages",
  :from => "Mailgun Sandbox <postmaster@sandbox43830a12e14e48f0823d1f1f846435cc.mailgun.org>",
  :to => user.email,
  :subject => "Bookmark Manager Password Reset Email",
  :text => "Click on this link to reset your password. http://localhost:9393/users/reset_password/:#{token}"
end

