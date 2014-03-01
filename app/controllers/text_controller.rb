# -*- encoding: utf-8 -*-
require 'kconv'

class TextController < ApplicationController

  # 
  def index
    
  end
  
  #
  def format
    f = params[:file]
    
    action = TextFormatAction.new(f)
    #action.exec
    @table = action.create_author_script
  end
  
end
