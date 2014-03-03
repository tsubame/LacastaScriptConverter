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
class TextCreateGameScriptAction 
  
  # チャプターの区切り文字　このテキストの箇所でチャプターを分割
  CHAPTER_DIVIDE_STR = "□□□□"  
  # チャプターのタイトルの形式　【共通ルート シーン01 朝の自宅】
  CHAPTER_TITLE_PATTERN = /【.+?ルート.+?シーン.+?】/
  
  # セリフか地の文かト書きかの判定用
  VOICE  = "セリフ"
  TEXT   = "地の文"
  TOGAKI = "ト書き"

  
  
  def initialize(file)
    # ファイルのテキスト取得
    @original_text = file.read.toutf8
  end
  
  # 処理実行 
  #
  # @params [File] file フォームからアップロードされたファイル
  def exec ()
    create_game_script
  end

  #
  #
  #
  def create_game_script
    formatter = ScriptFormatter.new
    formatter.split_text_ignore_length = SPLIT_TEXT_IGNORE_LENGTH
    chapters = formatter.exec(@original_text)
    
    chapters.each do |chapter|
      script = create_chapter_game_script(chapter)
      p script
    end
  end
  
  #
  #
  #
  def create_chapter_game_script(chapter)
    lines = chapter[:lines]
    script = ""
    name_head = "【 "
    name_tail = " 】\n"
    
    lines.each_with_index do |line, i|
      if line[:kind] == "地の文"
        script += line[:text]
        script += "<PG>\n"
        #1. 先頭の空白を削除 \n□ → \n
        
      elsif line[:kind] == "セリフ"
        # 2. 名前欄を改行 「　→　<br>\n「
        script += name_head + line[:chara_name] + name_tail
        script += line[:text]
        script += "<PG>\n"
        # 3. 改行を改ページに。 \n　→　<pg>\n
      elsif line[:kind] == "ト書き"
          
      end
      # 4. 2行以上の改ページを1行に。 <pg>\n<pg> → <pg>\n
    end
    
    return script
  end
  
  

end
