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

  # 地の文を分割する際、文字数にかかわらず1行1文にする
  SPLIT_TEXT_IGNORE_LENGTH = false #true
  
  
  
  # 立ち絵
  # <IMAGE NAME="立ち絵中" SOURCE="立ち絵\サンプル用\琴里.gal" X=C Y=B PRIORITY="キャラクタ中間" FLIP="Flip1" MODE=N>
  # 立ち絵変更
  # <CHGIMG NAME="立ち絵左" SOURCE="立ち絵\サンプル用\日向_笑2.gal" FLIP="Flip4" MODE=N>日向<BR>
  # 削除
  # <DELIMG NAME="立ち絵左,立ち絵中,立ち絵右,立ち絵左中,立ち絵右中" FLIP="Flip2">
  
  # 背景
  #<CHGIMG NAME="背景" SOURCE="背景\学校\教室a.gal" FLIP="Flip0" MODE=N>
  # BGM
  #<SOUND SOURCE="BGM\A. 日常\Playground.ogg" TRACK=B MODE=R VOLUME="500" REPEATPOS="0">

  # ウェイト
  # <WAIT TIME=3000 CLICKABORT=OFF SKIPENABLED=ON>
  
  # フリップ定義
  # 背景変更
  # <FLIP NAME="Flip0" EFFECT="FADE" TIME=1500 REVERSE=OFF DIFFERENCEONLY=OFF PARAM1=0 PARAM2=0 SOURCE="" DEFAULT=OFF>
  # キャラクタ登場
  # <FLIP NAME="Flip3" EFFECT="FADE" TIME=500 REVERSE=OFF DIFFERENCEONLY=OFF PARAM1=0 PARAM2=0 SOURCE="" DEFAULT=OFF>


  # メッセージボックス削除 後で反映
  #<DELMESBOX TIME=-1>
  # 暗転
  # <DELMESBOX TIME=-1>
  # <IMAGE NAME="真っ暗背景" SOURCE="背景\その他\真っ暗背景.gal" X=C Y=B PRIORITY="キャラクタ手前" FLIP="Flip0" MODE=N>
  # <CHGIMG NAME="背景" SOURCE="背景\その他\真っ暗背景.gal" FLIP="Flip0" MODE=N>
  # <DELIMG NAME="立ち絵左,立ち絵中,立ち絵右,立ち絵左中,立ち絵右中,真っ暗背景" FLIP="Flip3">
  
  

  
  # フリップ
  #<FLIP NAME="Flip0" EFFECT="FADE" TIME=1500 REVERSE=OFF DIFFERENCEONLY=OFF PARAM1=0 PARAM2=0 SOURCE="" DEFAULT=OFF>
  FLIPS = [
    # 背景変更
    "<FLIP NAME='Flip0' EFFECT='FADE' TIME=1500 REVERSE=OFF DIFFERENCEONLY=OFF PARAM1=0 PARAM2=0 SOURCE='' DEFAULT=OFF>\n",
    # 立ち絵表示
    "<FLIP NAME='Flip1' EFFECT='FADE' TIME=500  REVERSE=OFF DIFFERENCEONLY=OFF PARAM1=0 PARAM2=0 SOURCE='' DEFAULT=OFF>\n",
    # 立ち絵削除
    "<FLIP NAME='Flip2' EFFECT='FADE' TIME=200  REVERSE=OFF DIFFERENCEONLY=OFF PARAM1=0 PARAM2=0 SOURCE='' DEFAULT=OFF>\n",
    # 裏画面に配置
    "<FLIP NAME='Flip3' EFFECT='NONE' TIME=0    REVERSE=OFF DIFFERENCEONLY=OFF PARAM1=0 PARAM2=0 SOURCE='' DEFAULT=OFF>\n",
    # 立ち絵変更 
    "<FLIP NAME='Flip4' EFFECT='FADE' TIME=300  REVERSE=OFF DIFFERENCEONLY=OFF PARAM1=0 PARAM2=0 SOURCE='' DEFAULT=OFF>\n",
    # 表情変更
    "<FLIP NAME='Flip5' EFFECT='FADE' TIME=100  REVERSE=OFF DIFFERENCEONLY=OFF PARAM1=0 PARAM2=0 SOURCE='' DEFAULT=OFF>\n"
  ]
  #<IMAGE NAME="立ち絵左" SOURCE="立ち絵\サンプル用\大地.gal" X=100 Y=B PRIORITY="キャラクタ中間" FLIP="Flip3" MODE=N>
  
  DEL_IMGS = "<DELIMG NAME='立ち絵左,立ち絵中,立ち絵右,立ち絵左中,立ち絵右中,真っ暗背景' FLIP='Flip2'>\n"
  
  # '<CHGIMG NAME="背景" SOURCE="背景\学校\教室a.gal" FLIP="Flip0" MODE=N>'
  
  # 背景変更タグ
  BG_CHANGE_TAG = "<CHGIMG NAME='背景' SOURCE='背景¥学校¥__PLACE_NAME__.gal' FLIP='Flip0' MODE=N>\n"
  
  # キャラ登場タグ
  CHARA_IN_TAG = "<IMAGE NAME='__IMG_NAME__' SOURCE='立ち絵¥サンプル用¥__CHARA_NAME__.gal' __POSITION__ PRIORITY='キャラクタ中間' FLIP='Flip1' MODE=N>\n"
  # 立ち絵変更タグ
  CHARA_CHANGE_TAG = "<CHGIMG NAME='__IMG_NAME__' SOURCE='立ち絵¥サンプル用¥__CHARA_NAME__.gal' FLIP='Flip4' MODE=N>日向<BR>\n"
  
  #　立ち絵のファイルパス
  HINATA = "立ち絵¥サンプル用¥日向.gal"
  KOTORI = "立ち絵¥サンプル用¥琴里.gal"
  DAICHI = "立ち絵¥サンプル用¥大地.gal"
  SORA   = "立ち絵¥サンプル用¥空.gal"
  YOU    = "立ち絵¥サンプル用¥優羽.gal"
    
  # 立ち絵があるキャラ
  EXIST_IMAGE_CHARAS = ["琴里", "少女", "日向", "優羽", "大地", "空"]

  # 配置ごとの立ち絵の名前
  IMG_CENTER_NAME = "立ち絵中"    
  IMG_RIGHT_NAME  = "立ち絵右"   
  IMG_LEFT_NAME   = "立ち絵左"   
  # 画像のポジション
  IMG_CENTER_POSITION = " X=C Y=B "    
  IMG_RIGHT_POSITION  = " X=400 Y=B "  
  IMG_LEFT_POSITION   = " X=100 Y=B "  
    
  PG = "<PG>\n"
  NAME_HEAD = "【 "
  NAME_TAIL = " 】<BR>\n"

  
  def initialize(file)
    # ファイルのテキスト取得
    @original_text = file.read.toutf8
    
    @s_charas = []
  end
  
  # 処理実行 
  #
  # @params [File] file フォームからアップロードされたファイル
  def exec()
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
      #puts script
      # テキストファイルに
      File.open('output.txt','w') do |f|
        f.write script #=> 書込みされる文字列
      end
    end
  end
  
  #
  #
  #
  def create_chapter_game_script(chapter)
    lines = chapter[:lines]
    script = ""
    # 先頭にフリップを入れる
    FLIPS.each do |flip|
      script += flip
    end
    
    lines.each_with_index do |line, i|
      if line[:kind] == "地の文"
        script += line[:text]
        script += PG        
      elsif line[:kind] == "セリフ"
        # 画像タグ
        script += get_img_tags(line[:chara_name])      
        # 名前欄とテキスト出力
        script += NAME_HEAD + line[:chara_name] + NAME_TAIL + line[:text]
        # 改行を改ページに。 \n　→　<pg>\n
        script += PG 
      elsif line[:kind] == "ト書き"
        if line[:text][/背景/] != nil
          # 場所が変わる場合はキャラ削除
          @s_charas = []
          script += DEL_IMGS
          # 背景変更タグ
          place  = line[:text][/背景.([^\s　】]+)/, 1] 
          script += BG_CHANGE_TAG.sub("__PLACE_NAME__",   place)          
        end        
      end
      # 4. 2行以上の改ページを1行に。 <pg>\n<pg> → <pg>\n
    end
    
    return script
  end
  
  

  # 立ち絵の表示
  #
  # ・誰も居ない時は真ん中に表示
  # ・直前に人がいた時は横に並べて表示
  def get_img_tags(chara_name)
    tag = "" 
    # 立ち絵がないキャラなら何も出力しない
    if is_skipable?(chara_name) == true
      return ""
    end
    
    # 画面上に誰もいない場合
    if @s_charas.length == 0
      # キャラ登場タグ取得
      tag = get_chara_in_tag(chara_name)
      # 配列にキャラを入れる
      chara = {
        :img_name   => IMG_CENTER_NAME,
        :chara_name => chara_name,
        :position   => IMG_CENTER_POSITION
      }
      @s_charas.push(chara)
    # 既に1人いる
    elsif @s_charas.length == 1
      # 登場キャラの配置を左、既にいるキャラの配置を右に
      @s_charas[0][:img_name] = IMG_RIGHT_NAME
      @s_charas[0][:position] = IMG_RIGHT_POSITION
        
      chara = {
        :img_name   => IMG_LEFT_NAME,
        :chara_name => chara_name,
        :position   => IMG_LEFT_POSITION
      }
      @s_charas.push(chara)
      
      # 立ち絵2人分まとめて登場
      tag = get_charas_in_tag
    # 既に2人いる
    elsif @s_charas.length == 2
      # キュー方式でキャラ退場。登場キャラの配置はそれと同じ
      del_chara = @s_charas.shift
      #
      new_chara = {
        :img_name   => del_chara[:img_name],
        :chara_name => chara_name,
        :position   => del_chara[:position]
      }
      @s_charas.push(new_chara)
      # 立ち絵変更
      tag = get_chara_change_tag(del_chara, new_chara)
    end
    
    return tag
  end
  
  # キャラクター登場タグを出力
  #
  # 
  def get_chara_in_tag(chara_name)
    tag = CHARA_IN_TAG
    tag = tag.sub("__IMG_NAME__",   IMG_CENTER_NAME)
    tag = tag.sub("__CHARA_NAME__", chara_name)
    tag = tag.sub("__POSITION__",   IMG_CENTER_POSITION)
      
    return tag
  end
  
  # キャラクター2人まとめて登場タグを出力
  #
  # 
  def get_charas_in_tag
    # 画像削除
    tag = DEL_IMGS
    # 画像タグ出力
    @s_charas.each do |c|
      tag += CHARA_IN_TAG
      tag = tag.sub("__IMG_NAME__",   c[:img_name])
      tag = tag.sub("__CHARA_NAME__", c[:chara_name])
      tag = tag.sub("__POSITION__",   c[:position])
    end
    
    return tag
  end
  
  # キャラクター変更タグを出力
  #
  # 
  def get_chara_change_tag(del_chara, new_chara)
    # 画像変更
    tag = CHARA_CHANGE_TAG
    
    tag = tag.sub("__IMG_NAME__",   del_chara[:img_name])
    tag = tag.sub("__CHARA_NAME__", new_chara[:chara_name])
      
    return tag
  end

  # 画面上に既にキャラがいる、もしくは
  # 立ち絵がないキャラならfalseを返す
  #
  #
  def is_skipable?(chara_name)
    is_skipable = true
    
    # 配列（画面）にそのキャラがいれば終了
    @s_charas.each do |c|
      if chara_name == c[:chara_name]
        return true
      end    
    end
    
    # 立ち絵があるキャラか？
    EXIST_IMAGE_CHARAS.each do |c|
      if chara_name == c
        is_skipable = false
      end
    end  
        
    return is_skipable
  end
  
  # 画像タグ作成
  #
  #
  def create_img_tag    
    if @s_charas.length == 1
      chara_str = "　□" + @s_charas[0][:chara_name] + "□　"
    elsif @s_charas.length == 2
      if @s_charas[0][:position] == LEFT
        chara_str = "　" + @s_charas[0][:chara_name] + "□" + @s_charas[1][:chara_name] + "　"
      else
        chara_str = "　" + @s_charas[1][:chara_name] + "□" + @s_charas[0][:chara_name] + "　"
      end
    end 
    
    return tag
  end
  
  #
  #
  #
  def show_charas_str
    chara_str = ""

    if @s_charas.length == 1
      chara_str = "　□" + @s_charas[0][:chara_name] + "□　"
    elsif @s_charas.length == 2
      if @s_charas[0][:position] == LEFT
        chara_str = "　" + @s_charas[0][:chara_name] + "□" + @s_charas[1][:chara_name] + "　"
      else
        chara_str = "　" + @s_charas[1][:chara_name] + "□" + @s_charas[0][:chara_name] + "　"
      end
    end 
    
    #puts chara_str
  end
  
end
