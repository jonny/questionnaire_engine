# this should be taken care of in lib/qe.rb
# require 'qe/model_extensions'

module Qe
  class Admin::QuestionPagesController < ApplicationController
    include Qe::Concerns::Controllers::Admin::QuestionPagesController
  end
end