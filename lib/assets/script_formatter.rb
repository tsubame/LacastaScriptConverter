# -*- encoding: utf-8 -*-
#require 'open-uri'
require 'kconv'
#require 'nokogiri'
#require 'assets/rss_fetcher'

# 台本の整型を行うモジュール
#
#
#== 依存ライブラリ
# ・
#
#=== 使用例
# 
#
class ScriptFormatter

  # エラーメッセージ
  attr_reader   :error_message
  attr_accessor :split_text_ignore_length, :split_voice_min_length, :split_text_min_length
  
  # 1行の文字数がこれを超えたら2行に分ける
  SPLIT_TEXT_MIN_LENGTH = 50
  # ↑の台詞の場合
  SPLIT_VOICE_MIN_LENGTH = 55
  
  # セリフ横の役名を何文字で揃えるか　3の場合: 翼「こんにちは」→ 翼　　「こんにちは」
  CHARA_NAME_WIDTH = 2
  
  # 台本のセリフ番号を囲う文字
  VOICE_NUM_SIM_START = "["
  VOICE_NUM_SIM_END   = "]"
  
  # セリフか地の文かト書きかの判定用
  VOICE   = "セリフ"
  TEXT    = "地の文"
  TOGAKI  = "ト書き"
  COMMENT = "コメント"
  
  # チャプター分割器号
  CHAPTER_SPLIT_STR = "\r\n###"  
  # コメントの行の先頭文字
  COMMENT_STR = "#"
  # チャプタータイトル表記の正規表現パターン　【C01 共通ルート シーン01 夢〜自宅朝】
  CHAPTER_TITLE_PATTERN = /[【『]\w+?.+?[】』]/

  
  def initialize
    @error_message = ""
    @split_text_min_length  = SPLIT_TEXT_MIN_LENGTH
    @split_voice_min_length = SPLIT_VOICE_MIN_LENGTH
  end
    
  # 処理内容にエラーがあればtrue
  #
  # @return [Bool] 
  def error?
    if 0 < @error_message.length
      return true
    else
      return false
    end
  end
  
  # 台本を作成
  #
  #
  def exec (text)
    script = ""
    # チャプターごとに分割
    chapters = split_by_chapter(text)
    chapters.each do |chapter|
      # 各行のテキストの種類を取得
      lines = get_lines_from_text(chapter[:text])
      # 行を分割
      lines = split_lines(lines)
      # 空白行は削除
      lines = cut_no_use_line(lines)
      # セリフにファイル名をつける
      lines = set_file_name_to_voice_line(lines, chapter[:title])
        
      lines.each do |line|
        #p line
      end
      
      #output_lines_as_script(lines)
      chapter[:lines] = lines
    end

    return chapters
  end

  # セリフにファイル名をつける
  # 
  # 共通ルート シーン01 → キャラ名_共通01_セリフ番号
  #
  #
  def set_file_name_to_voice_line(lines, c_title)

    # メソッド化
    # チャプターのタイトルからファイル名の接中辞をつける
    if c_title != nil
      str  = c_title[/[\w]+/]
      file_str = str
    else
      file_str = ""
    end

#file_str = "ssss"
    
    c_voice_counts = {}
    # キャラごとのセリフを取得する
    lines.each_with_index do |line, i|
      if line[:kind] != VOICE
        next
      end
      
      # キャラ名を配列に
      if c_voice_counts.include?(line[:chara_name]) == false
        c_voice_counts[line[:chara_name]] = 1
        voice_num_s = "01"
      else
        c_voice_counts[line[:chara_name]] += 1
        voice_num = c_voice_counts[line[:chara_name]]
        voice_num_s = voice_num.to_s.rjust(2, "0")
      end

      #line[:file_name] = line[:chara_name] + "_" + file_str + "_" + voice_num_s
      line[:file_name] = file_str + "_" + line[:chara_name] + "_" + voice_num_s   
      lines[i] = line
    end
    
    return lines
  end
  
  
  # テキストをチャプターごとに分割し、ハッシュの配列で返す。
  # セリフが無く、チャプタータイトルが含まれない箇所はスキップ。
  #
  # @params [String] text
  # @return [Array]  chapters ハッシュcahpterの配列  chapter = { :title => "", :text => "" }
  def split_by_chapter(text)
    # チャプターごとにテキストを分割
    chapter_texts = text.split(CHAPTER_SPLIT_STR)
    
    # チャプターのタイトル、テキストを配列に入れる
    chapters = []
    chapter_texts.each do |c_text|  
p      c_title = c_text[CHAPTER_TITLE_PATTERN]

      chapter = { :title => c_title, :text => c_text }
      # セリフ、タイトルが含まれない箇所はスキップ
      if c_text.count("「") == 0 && c_title == nil
        next
      end
      
      chapters.push(chapter)
    end
    
    return chapters
  end
    
  # テキストを受け取って各行に分割し、配列 lines を返す。
  # セリフの場合は line[:kind] にキャラ名を入れる。
  #
  # @params [String] text  
  # @return [Array]  lines  ハッシュ line の配列  line = {:kind => VOICE, :chara_name => "翼", :text => "「こんにちは」", :file_name => nil}
  def get_lines_from_text(text)
    # テキストを改行で分割
    line_texts = text.split("\r\n")  
    
    lines = []
    line_texts.each do |line_text|
      # 行の種類を判定
      kind = judge_line_kind(line_text)
      # セリフの場合は役名を取得
      if kind == VOICE
        line = pickup_chara_name(line_text)
      # 地の文の場合は、最初の空白を削除
      elsif kind == TEXT
        line_text = cut_head_blank(line_text)
        line = { :kind => kind, :chara_name => nil, :text => line_text, :file_name => nil } 
      else
        line = { :kind => kind, :chara_name => nil, :text => line_text, :file_name => nil }
      end
      
      lines.push(line)
    end
    
    return lines
  end
  
  # セリフか地の文かト書きかを判定する。
  #
  # 以下の順番に実行し、条件に引っかかった次点で判定。
  #
  #   ・【】で囲まれている箇所はト書き
  #   ・注釈部分はト書き
  #   ・同じ文字が続けばト書き（区切り文字）
  #   ・「 が含まれていなければ地の文
  #   ・「「 が含まれていればセリフ
  #   ・「 の前の文字が6文字以内なら地の文
  #   ・それ以外はセリフとみなす
  #
  # @params [String] line_str
  # @return [String] VOICE or TEXT or TOGAKI
  def judge_line_kind (line_str)
  # 囲み文字を定数に変えたい    
     #　【】で挟まれていればト書き
     if line_str[/^[\s　]*【.+?】[\s　\r\n]*/] != nil
       return TOGAKI
     end
     # 注釈部分
     if line_str[0, COMMENT_STR.length] == COMMENT_STR
       return COMMENT
     end
     
     # 同じ文字が続けばト書き（区切り文字）
     char = line_str[0, 1]
     if line_str.length == line_str.count(char)
       return TOGAKI
     end
     
     # 「が含まれていなければ地の文
     if line_str.count("「") == 0
       return TEXT
     end
   
     # 「「が含まれていればセリフ
     if line_str[/「「/] != nil
       return VOICE
     end
     
     # 「の前を取り出す
     pre_voice = line_str[/^[^「]+?「/]
     # 文字数が6文字以下ならセリフとみなす  
     if pre_voice == nil
       return TEXT
     elsif 6 < pre_voice.length 
       return TEXT
     end
     
     return VOICE
   end
  
  # 最初の空白を削除
  #
  # @param  [String] str
  # @return [String] str
  def cut_head_blank(str)
    head_blank = str[/^[　\s\t]+/]
    if head_blank != nil
      str = str[head_blank.length, 9999]
    end    
    str.strip!
    
    return str
  end
  
  # セリフの行から役名、台詞を取り出す。
  #
  # @params [String] line_text
  # @return [Hash] line line = {:kind => TOGAKI, :chara_name => "翼", :text => "「こんにちは」"}
  def pickup_chara_name(line_text)
      # 「 の前後で分割
      strs = line_text.split(/「+/)
      if strs.length == 1 
        return line = { :kind => VOICE, :chara_name => nil, :text => strs[0] }
      end
      
      name = strs[0]
      line = { :kind => VOICE, :chara_name => name, :text => "「" + strs[1] }
      
      return line
  end
  
  # 長すぎる行を分割し、配列new_linesを返す。
  # 
  # ・ト書きは分割しない。
  #
  # @param  [Array] org_lines
  # @return [Array] new_lines  lineの配列  line = {:kind => VOICE, :chara_name => "", :text => "「〜〜〜」"}
  def split_lines(org_lines)
    new_lines = []    
    
    org_lines.each do |line|
      # セリフ、地の文、ト書きで処理分岐
      if line[:kind] == VOICE
        split_lines = split_voice_line(line)
        new_lines += split_lines
      elsif line[:kind] == TEXT
        split_lines = split_text_line(line, @split_text_ignore_length)
        new_lines += split_lines
      else
        new_lines.push(line)
      end
    end
    
    return new_lines
  end
  
  # セリフを分割し、配列linesを返す
  #
  # line = {:kind => VOICE, :chara_name => "日向", text => "「こんにちは。…。元気ですか？」"}
  # 　↓
  # lines = [ {:kind => VOICE, :chara_name => "日向", text => "「こんにちは」"}, 
  #           {:kind => VOICE, :chara_name => "日向", text => "「…。元気ですか？」"}]
  #
  # @params [Hash]  line 
  # @return [Array] lines
  def split_voice_line(line)   
    lines = []

    # セリフが特定の文字数以下なら分割せず返す
    if line[:text].length < SPLIT_VOICE_MIN_LENGTH
      return lines.push(line)
    end
    
    # セリフを鍵括弧と中身に分割
    strs = split_voice_to_3parts(line[:text])
    # セリフの中身を分割
    messages = split_msg_within_max_length(strs[:body], SPLIT_VOICE_MIN_LENGTH)

    messages.each do |msg|
      # 句点か空白で終わっていれば最後をカット
      if msg[/[。　]$/] != nil
        msg = msg.chop
      end
      # 鍵括弧の最初と最後をつける
      text = strs[:head] + msg + strs[:tail]
      # 配列に入れる
      new_line = { :kind => line[:kind], :chara_name => line[:chara_name], :text => text}
      lines.push(new_line)
    end
    
    return lines
  end
  
  # 地の文のうち、単一の行で長いものを複数に分ける。
  #　
  #　[仕様]
  # ・特定文字数以上で2文以上の時に分割。
  # ・ignores_length に true を設定した時は文字数にかかわらず1行1文に分割。
  #
  # @params [String] text
  # @params [Book]   ignores_length  文字数を無視して1行1文にする場合はtrue
  # @return [Array]  line_texts
  def split_text_line(line, ignores_length = false)
    lines = []   
    # 特定の文字数以下なら分割しない
    if line[:text].length < SPLIT_TEXT_MIN_LENGTH && ignores_length == false
      return lines.push(line)
    end
    
    # 文字数にかかわらず分割するか
    if ignores_length == true
      texts = split_text_to_sentences(line[:text])
    else
      texts = split_msg_within_max_length(line[:text], SPLIT_TEXT_MIN_LENGTH)
    end
    
    # 配列に入れる
    texts.each do |line_text|
      new_line = { :kind => line[:kind], :chara_name => nil, :text => line_text }
      lines.push(new_line)
    end
    
    return lines
  end
  
  # 文字列を"。", "　"で区切って複数の文字列に分ける。
  # 
  # @params [String] text
  # @return [Array]  sentences　
  def split_text_to_sentences(text)        
    # "。", "　"で分割
    split_strs = text.split(/([。　])/)
    # 分割できなかった時はそのまま返す
    if split_strs.length == 1
      return split_strs
    end
    
    # 文ごとに分けて配列に。
    sentences = add_array_text_to_period(split_strs)
       
    return sentences
  end
  
  # "。", "　"で分割したテキストの配列に、"。", "　"をくっつけて返す。
  #
  #　空文字は省く。　"。。"が続く場合は2つくっつける。　"こんにちは。。"
  #
  #（例）
  # "あいうえお", "。" , "こんにちは", "　"　
  #　 ↓
  # "あいうえお。", "こんにちは　"
  #
  # @params [Array] splits
  # @params [Array] sentences
  def add_array_text_to_period(splits)
    sentences = []
    # 空文字列を省く
    splits.delete("")
    
    # 配列から"。", "　"を探して前の要素にくっつける
    sentence = ""
    splits.each_with_index do |str, i|
      sentence += str
      
      # 最後の要素の時は配列に入れる
      if i == splits.length - 1
        sentences.push(sentence)
      # "。か　"が来たら配列に入れる
      elsif str == "。" || str == "　" 
        # 次の文字も"。", "　"だった時はスキップ
        if splits[i + 1] == "。" || splits[i + 1] == "　"     
          next
        end        
        sentences.push(sentence)
        sentence = ""
      end
    end
    
    return sentences
  end
  
  # 台詞を「」の前、中身、後に分けて、ハッシュを返す。
  # 
  #   text = "「そうですか…」（残念そうに）"
  #    ↓
  #   res = { :head => "「", :body => "そうですか…", :tail    => "」（残念そうに）" }
  #
  # @params [String] text
  # @return [Hash]   res  
  def split_voice_to_3parts(text)
    res = {}
    # 「 の前後で分割
    head_strs = text.split(/(「+)/)
    res[:head] = head_strs[0] + head_strs[1]
    
    # 」の前後で分割
    tail_strs = head_strs[2].split(/(」+)/)    
    if 2 < tail_strs.length 
      res[:body] = tail_strs[0]      
      res[:tail] = tail_strs[1] + tail_strs[2]
    else
      res[:body] = tail_strs[0]      
      res[:tail] = tail_strs[1]
    end
      
    return res
  end
  
  # 1つの文字列が一定の文字数以内に収まるよう、文字列を分割。
  #
  # within_length以下に収まるよう分割する。
  #
  # @params [String]  text
  # @params [Integer] within_length 文字数
  # @return [Array]   texts 
  def split_msg_within_max_length(text, within_length)
    texts = []
    # 文ごとに分割
    sentences = split_text_to_sentences(text)
    if sentences.length <= 1  
      return texts.push(text)
    end
  
    plused_str = ""
    # 文の数ループ
    sentences.each_with_index do |sent, i|      
      # 一定の文字数を超える直前に配列に入れる
      if plused_str.length + sent.length <= within_length
        plused_str += sent
      else
        texts.push(plused_str)
        plused_str = sent
      end
      # 最後の要素を配列に入れる
      if i == sentences.length - 1
        texts.push(plused_str)
      end
    end
    
    return texts
  end
  
  # 配列linesを受け取って、空白行、不要な行を除いて返す。
  # コメントの行もスキップ。
  #
  #   lines[i][:text] が空白だけ、もしくは改行と空白だけだった場合にカット。
  #
  # @params [Array]  lines  
  # @return [Array]  res_lines  
  def cut_no_use_line(lines)
    res_lines = []      
    lines.each do |line|
      # 空白行はスキップ
      if line[:text].length == 0
        next
      elsif line[:text][/^[　\s]+$/] != nil
        next
      end
      

      
# コメントの行、【場面暗転】の行もスキップ
if line[:text][/場面暗転/] != nil
  next
end
if line[:kind] == "コメント"
  next
end     
      
      res_lines.push(line)
    end
    
    return res_lines
  end
  
  
  
  
  
  
  
  
  # 地の文のうち、単一の行で長いものを複数に分ける。
  #　
  #　[仕様]
  # ・特定文字数以上で2文以上の時に分割。
  # ・
  #
  # @params [String] text
  # @params [Book]   ignores_length  文字数を無視して1行1文にする場合はtrue
  # @return [Array]  line_texts
  def split_text_line_org(line, ignores_length = false)
    lines = []
    
    # 特定の文字数以下なら分割せず返す
    if line[:text].length < SPLIT_TEXT_MIN_LENGTH && ignores_length == false
      return lines.push(line)
    end

    # 最初の空白を削除
    head_blank = line[:text][/^[　]+/]
    if head_blank != nil
      line[:text] = line[:text][head_blank.length, 9999]
    end
    
    # "。", "！　", "？　"で分割
    split_strs = line[:text].split(/([。　])/)
    # 分割できなかった時はそのまま返す
    if split_strs.length == 1
      return lines.push(line)    
    end
    
    # 文ごとに分割
    line_texts = add_array_text_to_period(split_strs)
    line_texts.each do |line_text|
      new_line = { :kind => line[:kind], :text => line_text}
      lines.push(new_line)
    end
    
    return lines
  end
  

  
      # 1つのセリフが一定の文字数以内に収まるようにセリフを分割。
      #
      # ・SPLIT_VOICE_MIN_LENGTH 以下に収まるよう分割
      #
      # @params [String] text
      # @return [Array]  texts
      def part_voice_msg_to_right_length(text)
        texts = []
        # 文ごとに分割
        sentences = split_text_to_sentences(text)
        if sentences.length <= 1  
          return texts.push(text)
        end
    
        plused_str = ""
        # 文の数ループ
        sentences.each_with_index do |sent, i|
          if plused_str.length + sent.length <= SPLIT_VOICE_MIN_LENGTH
            plused_str += sent
          else
            texts.push(plused_str)
            plused_str = sent
          end
          # 最後の要素を突っ込む
          if i == sentences.length - 1
            texts.push(plused_str)
          end
        end
        
        return texts
      end
  

  

     

    
  
  

  # 見やすく出力
  #
  # @params [Array]  lines  
  # @return [String] script
  def output_lines_as_script(lines)
    script = ""
    line_num = 1
    
    lines.each_with_index do |line, i|
      # 空白行はスキップ
      if line[:text].length == 0
        next
      elsif line[:text][/^[　\s]+$/] != nil
        next
      end
      
      # セリフ
      if line[:kind] == VOICE
        # 「の前の文字数を揃える
        puts "[" + line[:file_name].rjust(10, "　") + "]" + "　" + line[:chara_name].ljust(2, "　") + line[:text]
        #puts line[:text]
      # 地の文
      elsif line[:kind] == TEXT
        puts "　　" + line[:text]
      # ト書き
      else        
        puts line[:text]
      end
      
      # 次の行と文の種類が違えば1行開ける
      if i == lines.length - 1
        break
      elsif line[:kind] != lines[i + 1][:kind]
        puts ""
      end
    end
    
    return script
  end
  
  # 行の分割と、行のテキストの種類を取得
  # 地の文 or セリフ or ト書き
  #
  # @param  [String] line_text
  # @return [Array]  lines      lineの配列  line = {:kind => VOICE, :text => "〜〜〜"}
  def split_line_org_and_get_kind(line_text)
    lines = []    
    devided_strs= []

    # セリフ、ト書き、地の文で処理を分ける
    kind = judge_line_kind(line_text)
    # セリフ
    if kind == VOICE
      devided_strs = split_voice_line(line_text)
    # 地の文
    elsif kind == TEXT
      devided_strs = split_text_line(line_text, @split_text_ignore_length)
    # ト書き
    else
      line = { :kind => kind, :text => line_text }
      lines.push(line)
    end
    
    devided_strs.each do |str|
      line = { :kind => kind, :text => str }
      lines.push(line)
    end
    
    return lines
  end
  
  #
  #
  #
  def split_line_org(line_text)
    return_text = ""
    part_texts = []
      
    # セリフ、ト書き、地の文で処理を分ける
    kind = judge_line_kind(line_text)
    
    # セリフ
    if kind == VOICE
      part_texts = split_voice_line(line_text)
    # 地の文
    elsif kind == TEXT
      part_texts = split_text_line(line_text, @split_text_ignore_length)
    # ト書き
    else
      return_text = line_text + "\r\n"
    end
    
    part_texts.each do |part_text|
      return_text += part_text + "\r\n"
    end
    
    return return_text
  end
  
  # 地の文のうち、単一の行で長いものを複数に分ける。
  #　
  #　[仕様]
  # ・特定文字数以上で2文以上の時に分割。
  # ・
  #
  # @params [String] text
  # @params [Book]   ignores_length  文字数を無視して1行1文にする場合はtrue
  # @return [Array]  line_texts
  def split_text_line_org(text, ignores_length = false)
    line_texts = []
    
    # 特定の文字数以下なら分割せず返す
    if text.length < SPLIT_TEXT_MIN_LENGTH && ignores_length == false
      return line_texts.push(text)
    end
    
    # 最初の空白を削除
    head_blank = text[/^[　]+/]
    if head_blank != nil
      text = text[head_blank.length, 9999]
    end
    
    # "。", "！　", "？　"で分割
    split_strs = text.split(/([。　])/)
    # 分割できなかった時はそのまま返す
    if split_strs.length == 1
      return split_strs      
    end
    
    # 文ごとに分割
    line_texts = add_array_text_to_period(split_strs)
       
    return line_texts
  end
  

  
  
  
  # セリフを分割
  #
  #　[仕様]
  # ・特定文字数以上で2文以上の時に分割。
  # 
  # "日向「……甘いよ翼。名前的に翼は〝ひこう〟タイプ。その弱点を突き、さらに特殊技で攻めれば、その牙城はかくも容易に崩す事ができる！」",
  # 　↓
  # "日向「……甘いよ翼。名前的に翼は〝ひこう〟タイプ」",
  # "日向「その弱点を突き、さらに特殊技で攻めれば、その牙城はかくも容易に崩す事ができる！」"
  #
  # @params [String] text
  # @return [Array]  line_texts Stringの配列
  def split_voice_line_from_text(text)
    line_texts = []
    
    # 台詞の文字列を取り出す
    voice_strs = split_voice_to_3parts(text)
    # セリフが特定の文字数以下なら分割せず返す
    if voice_strs[:body].length < SPLIT_VOICE_MIN_LENGTH
      return line_texts.push(text)
    end
    
    # 中身を特定文字数以下に分割
    messages = part_voice_msg_to_right_length(voice_strs[:body])
    
    messages.each do |msg|
      if msg[/[。　]$/] != nil
        msg = msg.chop
      end
      
      line_text = voice_strs[:head] + msg + voice_strs[:tail]
      line_texts.push(line_text)
    end
    
    return line_texts
  end
  

  

  
  # 台詞と役名に分ける
  # エラー時にはnilを返す
  # ・「の前が8文字以上の場合は、セリフとみなさない
  # 
  # @params [String] text
  # @return [Hash]   voice    voice = {:name => "日向", :body => "「こんにちは」"}
  def split_voice_to_name_and_msg(text)    
    # 「 がなければスキップ
    if text.count("「") < 1
      return nil
    end

    voice = pickup_chara_name_org(text)
    # 役名が8文字以上ならセリフ以外とみなす
    if 8 <= voice[:name].length 
      return nil
    end    
    
    return voice
  end
  
  # セリフの行から役名、台詞を取り出す
  #
  # @params [String] text
  # @return [Hash]   voice  = {:name => "翼", :body => "「こんにちは」"}
  def pickup_chara_name_org(text)
      # 「 の前後で分割
      strs = text.split(/「+/)
      name = strs[0]
      
      voice = {}
      voice[:name]    = name 
      voice[:body] = "「" + strs[1]
      
      return voice
  end
  
  

 
end