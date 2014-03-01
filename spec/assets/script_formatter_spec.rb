# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'assets/script_formatter'

describe ScriptFormatter do
      
  subject do
    ScriptFormatter.new
  end
  
  
  describe :split_voice_line do
    context "50文字以下の文字列を渡した時" do
      it "そのまま返ってくること" do
        line = { 
          :kind => "セリフ",
          :chara_name => "日向",
          :text => "「高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人なんだよ？」"
        }
        expects = [line]
        
        results = subject.split_voice_line(line)   
        results.should eq(expects)
      end
    end
    
    context "50文字以上、1文の文字列を渡した時" do
      it "そのまま返ってくること" do    
        line = { 
          :kind => "セリフ",
          :chara_name => "日向",
          :text => "「高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人なんだよね…とか思いつつもそんなことは」"
        }
        expects = [line]
        
        results = subject.split_voice_line(line)   
        results.should eq(expects)
      end
    end
    
    context "50文字以上、2文の文字列を渡した時" do
      it "2つに分かれて返ってくること" do
        line = { 
          :kind => "セリフ",
          :chara_name => "日向",
          :text => "「……甘いよ翼。名前的に翼は〝ひこう〟タイプ。その弱点を突き、さらに特殊技で攻めれば、その牙城はかくも容易に崩す事ができる！」"
        }
        expects = [{
            :kind => "セリフ",
            :chara_name => "日向",
            :text => "「……甘いよ翼。名前的に翼は〝ひこう〟タイプ」"
          },{
            :kind => "セリフ",
            :chara_name => "日向",
            :text => "「その弱点を突き、さらに特殊技で攻めれば、その牙城はかくも容易に崩す事ができる！」"
          }]
         
        results = subject.split_voice_line(line)   
        results.should eq(expects)
      end
    end
    
    context "50文字以上、2文の文字列を渡した時、()付き" do
      it "2つに分かれて返ってくること" do
        line = { 
          :kind => "セリフ",
          :chara_name => "日向",
          :text => "「……甘いよ翼。名前的に翼は〝ひこう〟タイプ。その弱点を突き、さらに特殊技で攻めれば、その牙城はかくも容易に崩す事ができる！」（ドヤ顔）"
        }
        expects = [{
            :kind => "セリフ",
            :chara_name => "日向",
            :text => "「……甘いよ翼。名前的に翼は〝ひこう〟タイプ」（ドヤ顔）"
          },{
            :kind => "セリフ",
            :chara_name => "日向",
            :text => "「その弱点を突き、さらに特殊技で攻めれば、その牙城はかくも容易に崩す事ができる！」（ドヤ顔）"
          }]
         
        results = subject.split_voice_line(line)   
        results.should eq(expects)
      end
    end
  end
  
  describe :split_text_line do
    context "50文字以下の文字列を渡した時" do
      it "そのまま返ってくること" do
        line = { 
          :kind => "地の文", :chara_name => nil,
          :text => "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人なんだよ？"
        }
        expects = [line]
        
        results = subject.split_text_line(line)   
        results.should eq(expects)
      end
    end
    
    context "50文字以上、1文の文字列を渡した時" do
      it "そのまま返ってくること" do    
        line = { 
          :kind => "地の文", :chara_name => nil,
          :text => "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人なんだよね…とか思いつつもそんなことはなかなかに厳しい"
        }
        expects = [line]
        
        results = subject.split_text_line(line)   
        results.should eq(expects)
      end
    end
    
    context "3文の文字列, trueを渡した時" do
      it "3つに分かれて返ってくること" do
        line = { 
          :kind => "地の文", :chara_name => nil,
          :text => "……甘いよ翼。名前的に翼は〝ひこう〟タイプ。その弱点を突き、さらに特殊技で攻めれば、その牙城はかくも容易に崩す事ができる！！"
        }
        expect_texts = ["……甘いよ翼。", "名前的に翼は〝ひこう〟タイプ。", "その弱点を突き、さらに特殊技で攻めれば、その牙城はかくも容易に崩す事ができる！！"]
        expects = []
        expect_texts.each do |text| 
          expect = { :kind => line[:kind], :chara_name => nil, :text => text }
          expects.push expect
        end
         
        results = subject.split_text_line(line, true)   
        results.should eq(expects)
      end
    end
    
    context "3文の文字列を渡した時" do
      it "2つに分かれて返ってくること" do
        line = { 
          :kind => "地の文", :chara_name => nil,
          :text => "……甘いよ翼。名前的に翼は〝ひこう〟タイプ。その弱点を突き、さらに特殊技で攻めれば、その牙城はかくも容易に崩す事ができる！！"
        }
        expect_texts = ["……甘いよ翼。名前的に翼は〝ひこう〟タイプ。", "その弱点を突き、さらに特殊技で攻めれば、その牙城はかくも容易に崩す事ができる！！"]
        expects = []
        expect_texts.each do |text| 
          expect = { :kind => line[:kind], :chara_name => nil, :text => text }
          expects.push expect
        end
         
        results = subject.split_text_line(line)   
        results.should eq(expects)
      end
    end
    
    context "。。で分かれた3文の文字列を渡した時" do
      it "3つに分かれて返ってくること" do
        line = { 
          :kind => "地の文", :chara_name => nil,
          :text => "……甘いよ翼。。。名前的に翼は〝ひこう〟タイプ！！　その弱点を突き、さらに特殊技で攻めれば、その牙城はかくも容易に崩す事ができる！！"
        }
        expect_texts = ["……甘いよ翼。。。", "名前的に翼は〝ひこう〟タイプ！！　", "その弱点を突き、さらに特殊技で攻めれば、その牙城はかくも容易に崩す事ができる！！"]
        expects = []
        expect_texts.each do |text| 
          expect = { :kind => line[:kind], :chara_name => nil, :text => text }
          expects.push expect
        end
         
        results = subject.split_text_line(line, true)   
        results.should eq(expects)
      end
    end
  end
  
  describe :split_text_to_sentences do
    context "一定文字数以上、2文の文字列を渡した時" do
      it "2つに分かれて返ってくること" do
        text = "……甘いよ翼、名前的に翼は〝ひこう〟タイプ。その弱点を突き、さらに特殊技で攻めれば、その牙城はかくも容易に崩す事ができる"
        expects = [
           "……甘いよ翼、名前的に翼は〝ひこう〟タイプ。",
           "その弱点を突き、さらに特殊技で攻めれば、その牙城はかくも容易に崩す事ができる"
         ]
         
        res = subject.split_text_to_sentences(text)   
        res.should eq(expects)
      end
    end    
  end
  
  describe :split_msg_within_max_length do
    context "55文字以上、1文の文字列を渡した時" do
      it "そのまま返ってくること" do
        text = "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人なんだよとか思いつつも、実は全然そう思ってなかったり"
        expects = [
           "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人なんだよとか思いつつも、実は全然そう思ってなかったり"
         ]
         
        res = subject.split_msg_within_max_length(text, 55)   
        res.should eq(expects)
      end
    end
    
    context "55文字以上、2文の文字列を渡した時" do
      it "2つに分かれて返ってくること" do
        text = "……甘いよ翼、名前的に翼は〝ひこう〟タイプ。その弱点を突き、さらに特殊技で攻めれば、その牙城はかくも容易に崩す事ができる"
        expects = [
           "……甘いよ翼、名前的に翼は〝ひこう〟タイプ。",
           "その弱点を突き、さらに特殊技で攻めれば、その牙城はかくも容易に崩す事ができる"
         ]
         
        res = subject.split_msg_within_max_length(text, 55)   
        res.should eq(expects)
      end
    end
    
    context "40文字、8文字、30文字、20文字の4文を渡した時" do
      it "2つに分かれて返ってくること" do
        text = "123456789012345678901234567890123456789。1234567。12345678901234567890123456789。1234567890123456789。"
        expects = [
           "123456789012345678901234567890123456789。1234567。",
           "12345678901234567890123456789。1234567890123456789。"
         ]
         
        res = subject.split_msg_within_max_length(text, 55)   
        res.should eq(expects)
      end
      
      context "40文字、8文字、30文字、21文字の4文を渡した時" do
        it "2つに分かれて返ってくること" do
          text = "123456789012345678901234567890123456789。1234567。12345678901234567890123456789。12345678901234567890。"
          expects = [
             "123456789012345678901234567890123456789。1234567。",
             "12345678901234567890123456789。12345678901234567890。"            
           ]
           
          res = subject.split_msg_within_max_length(text, 55)   
          res.should eq(expects)
        end
        
        it "！マークで別れた文章でも2つに分かれて返ってくること" do
          text = "12345678901234567890123456789012345678！　1234567？　12345678901234567890123456789。12345678901234567890。"
          expects = [
             "12345678901234567890123456789012345678！　1234567？　",
             "12345678901234567890123456789。12345678901234567890。"            
           ]
           
          res = subject.split_msg_within_max_length(text, 55)   
          res.should eq(expects)
        end
      end
      
      context "7文字、30文字、14文字、11文字、20文字、23文字の5文を渡した時" do
        it "2つに分かれて返ってくること" do
          text = "はっはっは！　防御アップの〝まるくなる〟を今の会話中に三回積ませて貰った！　これで物理に対してはほぼ無敵！　対して貴様は物理特化！　そしてこれから僕が行うのは〝ねむる〟！　体力全回復する僕を止められるものは誰もいない！"
          expects = [
             "はっはっは！　防御アップの〝まるくなる〟を今の会話中に三回積ませて貰った！　これで物理に対してはほぼ無敵！　",
             "対して貴様は物理特化！　そしてこれから僕が行うのは〝ねむる〟！　体力全回復する僕を止められるものは誰もいない！"            
           ]
           
          res = subject.split_msg_within_max_length(text, 55)   
          res.should eq(expects)
        end
      end
      
      context "18文字、37文字、17文字の3文を渡した時" do
        it "2つに分かれて返ってくること" do
          text = "……朝は、本当に駄目なんだって……。元からの低血圧に加えて寝不足、さらには寝込みを襲ってくる輩までいるもんだ。せめて朝の強襲さえなければねえ……"
          expects = [
             "……朝は、本当に駄目なんだって……。元からの低血圧に加えて寝不足、さらには寝込みを襲ってくる輩までいるもんだ。",
             "せめて朝の強襲さえなければねえ……"            
           ]
           
          res = subject.split_msg_within_max_length(text, 55)   
          res.should eq(expects)
        end
      end
      
      context "18文字、47文字の2文を渡した時" do
        it "2つに分かれて返ってくること" do
          text = "……一応君のためにも言ってるんだよ？　寝る前と起きる前は、女の子は男の子の部屋に入っちゃ駄目だって、エリクソンだって言ってたでしょ？"
          expects = [
             "……一応君のためにも言ってるんだよ？　",
             "寝る前と起きる前は、女の子は男の子の部屋に入っちゃ駄目だって、エリクソンだって言ってたでしょ？"            
           ]
           
          res = subject.split_msg_within_max_length(text, 55)   
          res.should eq(expects)
        end
      end
      # 
    end    
  end
  
  describe :split_voice_to_3parts do
    context "役名、セリフの文字列を渡した場合" do
      it "3つに別れて配列で返ってくること" do
        text = "「高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人なんだよ？」"
        expects = { :head => "「", :body => "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人なんだよ？", :tail => "」"}  
        
        res = subject.split_voice_to_3parts(text)
        res.should eq(expects)
      end
    end
    
    context "役名、セリフ（）付きの文字列を渡した場合" do
      it "3つに別れて配列で返ってくること" do
        text = "「高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人なんだよ？」（残念そうに）"
        expects = { :head => "「", :body => "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人なんだよ？", :tail => "」（残念そうに）"}  
        
        res = subject.split_voice_to_3parts(text)
        res.should eq(expects)
      end
    end
    
    context "「「付きの文字列を渡した場合" do
      it "3つに別れて配列で返ってくること" do
        text = "日向&翼「「なん…だと…」」（驚愕）"
        expects = { :head => "日向&翼「「", :body => "なん…だと…", :tail => "」」（驚愕）"}  
        
        res = subject.split_voice_to_3parts(text)
        res.should eq(expects)
      end
    end
  end
  
  describe :split_voice_to_name_and_msg do
    next
    context "役名、セリフの文字列を渡した場合" do
      it "役名とセリフが配列で返ってくること" do
        text = "日向「高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人なんだよ？」"
        expects = { :name => "日向", :message => "「高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人なんだよ？」"}
            
        results = subject.split_voice_to_name_and_msg(text)   
        results.should eq(expects)
        
        text = "翼　「そんなことはありえない。」"
        expects = { :name => "翼　", :message => "「そんなことはありえない。」"}
        
        results = subject.split_voice_to_name_and_msg(text)   
        results.should eq(expects)
        
        text = "龍門渕透華&翼「宜しくお願いします」と呟いた"
        expects = { :name => "龍門渕透華&翼", :message => "「宜しくお願いします」と呟いた"}
        results = subject.split_voice_to_name_and_msg(text)   
        results.should eq(expects)
      end
    end
    
    context "「の前が8文字以上の場合" do
      it "nilが返ってくること" do
        text = "風秋さんは、戸惑いながらも「宜しくお願いします」と呟いた"
        results = subject.split_voice_to_name_and_msg(text)   
        results.should be_nil
      end
    end
  end
  
  describe :split_text_line do
    next
    context "50文字以下の文字列を渡した時" do
      it "そのまま返ってくること" do
        text = "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人。"
        expects = [
          "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人。"
        ]
        
        results = subject.split_text_line(text)   
        results.should == expects
      end
    end
    
    context "50文字以上、1文の文字列を渡した時" do
      it "そのまま返ってくること" do
        text = "いつも最後までこの光景を見ていられない僕には知る由も無い事だが、それでも、今日ぐらいは踏ん張ってみようと思う。"
        expects = [
          "いつも最後までこの光景を見ていられない僕には知る由も無い事だが、それでも、今日ぐらいは踏ん張ってみようと思う。"
        ]
        
        results = subject.split_text_line(text)   
        results.should == expects
      end
    end
    
    context "50文字以下、2文の文字列を渡した時" do
      it "1文ずつ2行に分かれて返ってくること" do
        text = "朝。今日ぐらいは踏ん張ってみようと思う。"
        expects = [
          "朝。", "今日ぐらいは踏ん張ってみようと思う。"
        ]
        
        results = subject.split_text_line(text, true)   
        results.should == expects
      end
    end
    
    context "50文字以上、2文の文字列を渡した時" do
      it "1文ずつ2行に分かれて返ってくること" do
        # 普通の2文。
        text = "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人。真面目で頑固な性格だけど別に冗談が通じないわけではない。"
        expects = [
          "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人。",
          "真面目で頑固な性格だけど別に冗談が通じないわけではない。"
        ]        
        results = subject.split_text_line(text)   
        results.should eq(expects)
        
        #　2文。最後に句点がないテキスト
        text = "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人。真面目で頑固な性格だけど別に冗談が通じないわけではない"
        expects = [
          "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人。",
          "真面目で頑固な性格だけど別に冗談が通じないわけではない"
        ]        
        results = subject.split_text_line(text)   
        results.should eq(expects)
        
        # ！　で分割されたテキスト
        text = "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人！　真面目で頑固な性格だけど別に冗談が通じないわけではない。"
        expects = [
          "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人！　",
          "真面目で頑固な性格だけど別に冗談が通じないわけではない。"
        ]        
        results = subject.split_text_line(text)   
        results.should eq(expects)
        
        # ！？　で分割されたテキスト
        text = "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人！？　真面目で頑固な性格だけど別に冗談が通じないわけではない。"
        expects = [
          "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人！？　",
          "真面目で頑固な性格だけど別に冗談が通じないわけではない。"
        ]        
        results = subject.split_text_line(text)   
        results.should eq(expects)
        
        # ！で分割されたテキスト
        text = "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人！真面目で頑固な性格だけど別に冗談が通じないわけではない。"
        expects = [
          "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人！真面目で頑固な性格だけど別に冗談が通じないわけではない。"
        ]        
        results = subject.split_text_line(text)   
        results.should == expects
      end
    end
    
    context "50文字以上、3文の文字列を渡した時" do
      it "1文ずつ3行に分かれて返ってくること" do
        # 普通の3文。
        text = "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人だ。真面目で頑固な性格。だけど別に冗談が通じないわけではない。"
        expects = [
          "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人だ。",
          "真面目で頑固な性格。",
          "だけど別に冗談が通じないわけではない。"
        ]        
        results = subject.split_text_line(text)   
        results.should eq(expects)
      end
      
      it "空白や句点が続いても、1文ずつ3行に分かれて返ってくること" do        
        # 空白が入ってる
        text = "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人だ。　真面目で頑固な性格。だけど別に冗談が通じないわけではない。"
        expects = [
          "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人だ。　",
          "真面目で頑固な性格。",
          "だけど別に冗談が通じないわけではない。"
        ]        
        results = subject.split_text_line(text)   
        results.should eq(expects)
        
        # 。。が入ってる
        text = "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人だ。。真面目で頑固な性格。だけど別に冗談が通じないわけではない。"
        expects = [
          "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人だ。。",
          "真面目で頑固な性格。",
          "だけど別に冗談が通じないわけではない。"
        ]        
        results = subject.split_text_line(text)   
        results.should eq(expects)
        
        # 。。　が入ってる
        text = "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人だ。。　真面目で頑固な性格。だけど別に冗談が通じないわけではない。"
        expects = [
          "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人だ。。　",
          "真面目で頑固な性格。",
          "だけど別に冗談が通じないわけではない。"
        ]        
        results = subject.split_text_line(text)   
        results.should eq(expects)
        
        # 。。　が入ってる
        text = "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人だ！？　真面目で頑固な性格。　だけど別に冗談が通じないわけではない。"
        expects = [
          "高校に入ってから三年間、ずっと俺と同じクラスで一年の頃から交流がある友人の一人だ！？　",
          "真面目で頑固な性格。　",
          "だけど別に冗談が通じないわけではない。"
        ]        
        results = subject.split_text_line(text)   
        results.should eq(expects)
      end
    end
  end

  
=begin 

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

=end

end
