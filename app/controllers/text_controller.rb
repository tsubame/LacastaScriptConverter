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
  
  #
  def create_game_script
    f = params[:file]
p f    
    action = TextCreateGameScriptAction.new(f)
    @script = action.exec
  end
  
  def test
    action = TextTestAction.new
    #@script = action.exec
  end
  
end
