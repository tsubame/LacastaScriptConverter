# -*- encoding: UTF-8 -*-
require 'kconv'
require 'assets/script_formatter'

# アクションの処理を担当するクラス
# テキストファイルのフォーマットを行う
#
# 1. 台本の作成
#　　・台詞の横に番号を付ける
#　　・見やすく整形
#　　・長いセリフ、地の文は2行に。
#
class TextFormatAction 
  
  # チャプターの区切り文字　このテキストの箇所でチャプターを分割
  CHAPTER_DIVIDE_STR = "□□□□"  
  # チャプターのタイトルの形式　【共通ルート シーン01 朝の自宅】
  CHAPTER_TITLE_PATTERN = /【.+?ルート.+?シーン.+?】/
  
  # セリフか地の文かト書きかの判定用
  VOICE  = "セリフ"
  TEXT   = "地の文"
  TOGAKI = "ト書き"
  
  # 注釈部分の先頭文字列
  COMMENT_STR = "#"
  
  # セリフ横の役名を何文字で揃えるか　3の場合: 翼「こんにちは」→ 翼　　「こんにちは」
  ACTOR_CHAR_WIDTH = 3
  
  # 台本のセリフ番号を囲う文字
  VOICE_NUM_SIM_START = "["
  VOICE_NUM_SIM_END   = "]"
  
  # 1画面の文字数がこれを超えたら2画面に分ける
  MAX_LENGTH_OF_LINE = 55
  
  # 地の文を分割する際、文字数にかかわらず1行1文にする
  SPLIT_TEXT_IGNORE_LENGTH = false #true
  
  
  def initialize(file)
    # ファイルのテキスト取得
    @original_text = file.read.toutf8
  end
  
  # 台本を作成
  # 
  # 1. 長い行、セリフを2つに分ける
  # 
  def create_author_script
    formatter = ScriptFormatter.new
    formatter.split_text_ignore_length = SPLIT_TEXT_IGNORE_LENGTH
    chapters = formatter.exec(@original_text)
        
    t_html = output_table(chapters)
  end
  
  # 処理実行 
  #
  # @params [File] file フォームからアップロードされたファイル
  def exec ()

  end

  # テーブルタグ出力
  #
  #
  def output_table(chapters)
    t_html = ""
    chapters.each do |chapter|
      lines = chapter[:lines]
      lines.each_with_index do |line, i|
        if line[:kind] == "コメント"
          next
        elsif line[:kind] == "ト書き" && line[:text][/【背景/]
          place = line[:text][/【背景.([^】]+)】/, 1]
          t_html += "</table>\n\n<div class='place'>" + place + "</div>\n\n"
          t_html += "<table class='script_table'>"
          t_html +=   "<tr class = 'blank'><td class = 'chara_name'>　</td><td class = 'text'></td><td class = 'file_name'></td></tr>"
          next
        end        
        
        if line[:chara_name]
          if line[:chara_name] == "日向"
            t_html += "<tr class = 'voice bold'>"        
          else
            t_html += "<tr class = 'voice'>"
          end
        elsif line[:kind] == "地の文"
          t_html += "<tr class = 'text'>"
        else    
          t_html += "<tr>"        
        end
        
        if line[:chara_name]
          t_html += "<td class = 'chara_name'>" + line[:chara_name] + "</td>"
        else
          t_html += "<td class = 'chara_name'></td>"
        end
        
        if line[:kind] == "ト書き" && line[:text][/【背景/]
          place = line[:text][/【(背景.[^】]+)】/, 1]
          t_html += "<td class = 'text'><div class='place'>" + place + "</div></td>"
        else
          t_html += "<td class = 'text'>" + line[:text] + "</td>"          
        end
        

        if line[:file_name]
          t_html += "<td class = 'file_name'>" + line[:file_name] + "</td>"
        else
          t_html += "<td class = 'file_name'></td>"
        end
        t_html += "</tr>\n"
        
        if i == lines.length - 1
          break
        elsif lines[i + 1][:kind] != line[:kind]
          t_html += "<tr class = 'blank'><td class = 'chara_name'>　</td><td class = 'text'></td><td class = 'file_name'></td></tr>"
        end
      end
    end
        
    return t_html
  end
  

end
