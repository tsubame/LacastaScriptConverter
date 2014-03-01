# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'assets/entry_content_getter'

describe EntryContentGetter do
      
  subject do
    EntryContentGetter.new
  end

  LIVEDOOR_URLS = [
    "http://blog.livedoor.jp/livejupiter2/archives/6845392.html",
    "http://blog.livedoor.jp/yakiusoku/archives/54032456.html",
    "http://blog.livedoor.jp/insidears/archives/52626197.html"
  ]
  
  FC2_URLS = [
    "http://llabtooflatot.blog102.fc2.com/blog-entry-4009.html",
    "http://nofootynolife.blog.fc2.com/blog-entry-520.html",
    "http://2ch11soccer.blog.fc2.com/blog-entry-1742.html",
    "http://yakyuboz.blog.fc2.com/blog-entry-8420.html"
  ]
  
  HATENA_URLS = [
    "http://d.hatena.ne.jp/Chikirin/20131003",
    "http://d.hatena.ne.jp/tomy2291/20131005/1380972455",
    "http://zeitra.hateblo.jp/entry/2013/10/05/083355"
  ]
  
  describe :get_content do
    next
    context "ライブドアブログのURLを渡した時" do      
      next
      it "結果がnilでなく、返り値のデータサイズが100バイトより大きいこと" do
        
        LIVEDOOR_URLS.each do |url|
          content = subject.get_content(url)          
          content.should_not be_nil        
          content.length.should >= 100
          puts "#{content.length} byte"
          puts content
        end
      end
    end
    
    context "FC2ブログのURLを渡した時" do
      it "結果がnilでなく、返り値のデータサイズが80バイトより大きいこと" do
        FC2_URLS.each do |url|
          content = subject.get_content(url)          
          content.should_not be_nil        
          content.length.should >= 80
          puts "#{content.length} byte"
          puts content
        end
      end
    end
    
    context "はてなブログのURLを渡した時" do
      it "結果がnilでなく、返り値のデータサイズが80バイトより大きいこと" do
        HATENA_URLS.each do |url|
          content = subject.get_content(url)          
          content.should_not be_nil        
          content.length.should >= 80
          puts "#{content.length} byte"
          puts content
        end
      end
    end
    
    context "Yahooニュース、ブログのURLを渡した時" do
      it "結果がnilでなく、返り値のデータサイズが100バイトより大きいこと" do
        urls = [
          "http://headlines.yahoo.co.jp/hl?a=20131005-00000018-kana-l14",
          "http://llabtooflatot.blog102.fc2.com/blog-entry-4009.html",
          "http://d.hatena.ne.jp/Chikirin/20131003"
          ]
        
        urls.each do |url|
          content = subject.get_content(url)          
          content.should_not be_nil        
          content.length.should >= 80
          puts "#{content.length} byte"
          puts content
        end
      end
    end
  end
  
  describe :get_content_from_yahoo do
    next
    context "YahooニュースのURLを渡した時" do
      it "結果がnilでなく、返り値のデータサイズが100バイトより大きいこと" do
        urls = [
          "http://headlines.yahoo.co.jp/hl?a=20131005-00000018-kana-l14",
          "http://headlines.yahoo.co.jp/hl?a=20131005-00000011-asahi-soci",
          "http://headlines.yahoo.co.jp/hl?a=20131005-00000441-yom-soci"
          ]
        
        urls.each do |url|
          content = subject.get_content_from_yahoo(url)          
          content.should_not be_nil        
          content.length.should >= 100
          puts "#{content.length} byte"
          puts content
        end
      end
    end
  end


end
