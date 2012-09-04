#!/bin/zsh

rm *.gem
gem build winston_mongodb_rails.gemspec
gem push `ls *.gem`