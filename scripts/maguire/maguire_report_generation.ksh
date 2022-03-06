(
  echo To: sagnik.sarkar@vodafone.com
  echo From: el@defiant.com
  echo "Content-Type: text/html; "
  echo Subject: a logfile
  echo
  cat mail.html
) | sendmail -t
