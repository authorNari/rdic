# 全角記号の半角化と pdic風レイアウト変換
def full2half(s)
  if s
    # {ひらがな}の除去
    if midashi_len = s.index(' : ')
      s = s[0..midashi_len] + s[midashi_len..s.length].gsub(/\｛[^｛]*｝/,"")
    end
    s.gsub!(/＝/, "=")
    s.gsub!(/×/, "X")
    s.gsub!(/％/, "%")
    s.gsub!(/＿/, "_")
    s.gsub!(/？/, "?")
    s.gsub!(/（/, "(")
    s.gsub!(/）/, ")")
    s.gsub!(/［/, "[")
    s.gsub!(/］/, "]")
    s.gsub!(/\s*\/\s*【用例/, "\t【用例")
    s.gsub!(/■・/,"\t・")
    s.gsub!(/／/,"/")
    # 品詞の編集
    if midashi_len = s.index(' : ')
      if s[0..midashi_len] =~ /(\{[^\}]*\})/
        midashi = $`
        hinshi = $1
        hinshi.gsub!(/\{/,"\t【")
        hinshi.gsub!(/\}/,'】')
        s = midashi + ' : ' + hinshi + s[(midashi_len+' : '.length)..s.length]
      end
    end
    s.gsub!(/  +/, " ")
  end
  return s.strip
end

# 用例の移動
def yourei_idou(s)
  if s =~ /【用例/
    ary = s.split("\t")
    ary1 = []
    ary2 = []
    ary.each{|x| 
      if x =~ /^【用例/
        ary2.push(x)
      else
        ary1.push(x)
      end
    }
    s = ""
    ary1.each{|x| s << x + "\t" } 
    ary2.each{|x| s << x + "\t" } 
  end
  return s
end

# 機種依存コードの変換
def kishu_izon(s)
  s.gsub!(/\x87\x92/s, CNV_CHR3)
  s.gsub!(/\x87\x54/s, "I")
  s.gsub!(/\x87\x55/s, "II")
  s.gsub!(/\x87\x56/s, "III")
  s.gsub!(/\x87\x57/s, "IV")
  s.gsub!(/\x87\x58/s, "V")
  s.gsub!(/\x87\x59/s, "VI")
  s.gsub!(/\x87\x5a/s, "VII")
  s.gsub!(/\x87\x5b/s, "VIII")
  s.gsub!(/\x87\x5c/s, "IX")
  s.gsub!(/\x87\x5d/s, "X")
  s.gsub!(/\x87\x70/s, "cm")
  s.gsub!(/\xee\x9d/s, CNV_CHR2)
  s.gsub!(/[\x84\xbf-\x88\x9d]/s, CNV_CHR)
  return s
end

require "nkf"

CNV_CHR = '〓'
# とう小平　語彙の先頭あってbinary検索不可
CNV_CHR2 = 'とう'
CNV_CHR3 = '∫'

ARGF.set_encoding('sjis')
sold = full2half(NKF.nkf('-S -w -Lu', kishu_izon(ARGF.gets)))
sold =~ / : /
midashi_old = $`
i = 0
while line = ARGF.gets
  s = full2half(NKF.nkf('-S -w -Lu', kishu_izon(line)))
  if s =~ / : /
    midashi = $`
    imi = $'
    if midashi_old == midashi 
      i+=1
      if imi =~ /^\t/
        sold << imi
      else
        sold << "\t" << imi
      end   
    else
      if i == 0
        $stdout.puts(sold.sub(/ : \t/, " : "))
      else
        $stdout.puts(yourei_idou(sold))
      end
      i=0
      midashi_old = midashi
      sold = s
    end
  end
end
if i == 0
  $stdout.puts(sold.sub(/ : \t/, " : "))
else
  $stdout.puts(yourei_idou(sold))
end
