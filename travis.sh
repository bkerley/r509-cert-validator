#!/usr/bin/env bash
bundle exec rake ca:all
bundle exec ruby spec/support/ca_server.rb &
sleep 5
bundle exec rspec
