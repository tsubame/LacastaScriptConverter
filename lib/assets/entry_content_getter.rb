# -*- encoding: utf-8 -*-
require 'open-uri'
require 'kconv'
require 'nokogiri'
require 'assets/rss_fetcher'

# 記事のURLを受け取って、記事本文の概要を返すクラス。
# 
# ブログの場合はRSSを取得してcontentデータの先頭一部を返す。
# Yahooニュースの場合はHTMLを取得して記事の先頭一部を返す。
#
# それ以外のメディアには非対応。nilを返す。
#
#== 依存ライブラリ
# ・nokogiri 
# ・assets/rss_fetcher
#
#=== 使用例
# ・単一の記事の概要を取得
#
#   url = "http://~"
#   getter  = EntryContentGetter.new
#   content = getter.get_content(url)
#
# ・複数の記事の概要を取得
#
#   urls = ["http://~", "http://~",...]
#   getter  = EntryContentGetter.new
#   content_hash = getter.get_contents(urls)
#
#   content_hash.each do |url, text|
#     content = text
#   end
#
class EntryContentGetter

  # エラーメッセージ
  attr_reader   :error_message

  # 取得する記事概要の最大のバイト数。これを超えたらカット。
  CONTENT_MAX_LENGTH = 1000
  
  def initialize
    @error_message = ""
    @max_thread = 10
    @content_hash = {}
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
  
  # 複数のエントリの概要のテキストを取得し、@content_hashに格納する。
  #
  # マルチスレッドで並列に取得。
  # スレッドの最大数は @max_thread に従う。
  #
  #   @content_hash = {"http://~（URL）" => "エントリの概要"}
  #
  # @param  [Array] urls URLの配列
  # @return [Hash]  @content_hash
  def get_contents(urls)
    urls_que  = []
    req_count = 1
        
    urls.each_with_index do |url, i|
      # URLをキューに入れる
      urls_que << url
      
      # キュー内のURLの数が @max_thread と同じになったらHTMLを取得
      if @max_thread <= urls_que.size || urls.size - 1 <= i
        puts "#{req_count}回目のアクセス"
        get_contents_with_thread(urls_que)
        urls_que  = []
        req_count += 1
      end
    end
    
    return @content_hash
  end

  # 複数のエントリの概要のテキストを取得し、@content_hashに格納する。
  #
  # マルチスレッドで並列に取得。
  # スレッドの最大数の上限なし。
  # 
  #   @content_hash = {"http://~（URL）" => "エントリの概要"}
  #
  # @param [Array] urls フィードURLの配列  
  def get_contents_with_thread(urls)
    ths = []
    urls.each do |url|
      ths << Thread.start(url) do |u|
        desc = get_content(u)
        @content_hash[u] = desc
      end
    end
    
    ths.each do |th|
      th.join      
    end
  end  
  
  # 記事の概要を取得
  # 
  # エラー時にはnilを返す
  #
  # @param  [String] url
  # @return [String] 
  def get_content(url)
    unless url.is_a?(String) then return nil end
      
    # ブログの概要を取得
    content = get_content_from_blog(url) 
    if content != nil
      return content
    end
    
    # Yahooニュースの概要を取得
    content = get_content_from_yahoo(url)

# <div><p>などを改行で統一
    
    
    return content
  end  
  
  # ブログ記事の概要を取得
  # RSSからCDATAの一部を取り出す
  # エラー時にはnilを返す
  #
  # 長さが一定以上なら最後のHTMLタグ以降をカット。
  #
  # @param [String] url
  # @return [String] 
  def get_content_from_blog(url) 
    content = nil
    
    # フィードURLを取得
    fetcher =  RssFetcher.new
    feed_url = fetcher.get_feed_url_of_blog(url)
    if feed_url == nil
      return nil
    end
   
    # RSSを取得
    feed = fetcher.fetch_rss_and_atom(feed_url)
    feed.items.each do |item|
      if url =~ /#{item.url}/
        content = item.content
      end
    end
    # 長さが一定以上ならカット
    if content.length > CONTENT_MAX_LENGTH
      content = content[0, CONTENT_MAX_LENGTH]
      content = content[/(.+)<[^\/^<]+$/m, 1]
    elsif content.length == 0
      return nil
    end

    return content
  end
  
  # Yahooニュースの概要を取得
  # <div id="ynDetail"><p class="ynDetailText">の中身を取得
  # テキストとともに画像も取得する。
  # 
  # 長さが一定以上なら最後の<br>以降をカット。
  # エラー時にはnilを返す
  #
  # @param [String] url
  # @return [String] 
  def get_content_from_yahoo(url)      
    content = ""
    
    # HTMLを取得
    begin
      doc = Nokogiri::HTML(open(url))
    rescue => e
      puts @error_message = 'HTMLの取得に失敗しました' + e.message
      return nil
    end
    # 画像
    doc.css("div.ymuiContainerNopad img").each do |elm|      
      content += elm.to_s.toutf8
    end
    # テキスト
    doc.css("div#ynDetail p.ynDetailText").each do |elm|      
      content += elm.inner_html.toutf8
    end
    
    # 長さが一定以上ならカット 
    if content.length > CONTENT_MAX_LENGTH
      content = content[0, CONTENT_MAX_LENGTH]
      content = content.sub(/<br>[^<]+$/im, "")
    elsif content.length == 0
      return nil
    end
    
    return content
  end
  

end