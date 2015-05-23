# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

AuthenticationProvider.create(name: 'facebook', enabled: false)
AuthenticationProvider.create(name: 'twitter', enabled: true)
AuthenticationProvider.create(name: 'google_oauth2', enabled: false)
