if ENV["TRAVISCI"].nil?
  dbconfig({
    host: "localhost",
    dbname: "crawly-test",
    user: "crawly",
    password: "crawly"
  })
else
  dbconfig({
    host: "localhost",
    dbname: "crawly-test",
    user: "postgres"
  })
end

entry_point "http://www.cnn.com"
append_filter -> (a) { a }
continue true
cluster_size 25
log_level "warn"

