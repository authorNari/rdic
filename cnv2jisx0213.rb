$KCODE = "EUC"

while(line = ARGF.gets)
  if line =~ /(【発音！?】)([^【\t]+)(【|\t|\n)+?/
    f1 = $`
    f2 = $1
    f4 = $3
    f5 = $'
    f3 = $2.gsub(/ae'/,"\xab\xc5")\
    .gsub(/ae`/,"\xab\xc4")\
    .gsub(/ae/,"\xa9\xdc")\
    .gsub(/э'/,"\xab\xcd")\
    .gsub(/э`/,"\xab\xcc")\
    .gsub(/э/,"\xab\xb0")\
    .gsub(/α'/,"\xab\xc7")\
    .gsub(/α`/,"\xab\xc6")\
    .gsub(/α/,"\xab\xb9")\
    .gsub(/Λ'/,"\xab\xcb")\
    .gsub(/Λ`/,"\xab\xca")\
    .gsub(/Λ/,"\xab\xb7")\
    .gsub(/ｏ'/,"\xab\xc9")\
    .gsub(/ｏ`/,"\xab\xc8")\
    .gsub(/ｏ/,"\xab\xb8")\
    .gsub(/a'/,"\xa9\xd7")\
    .gsub(/a`/,"\xa9\xd6")\
    .gsub(/i'/,"\xa9\xe3")\
    .gsub(/i`/,"\xa9\xe2")\
    .gsub(/e'/,"\xa9\xdf")\
    .gsub(/e`/,"\xa9\xde")\
    .gsub(/o'/,"\xa9\xca")\
    .gsub(/o`/,"\xa9\xc9")\
    .gsub(/u'/,"\xa9\xef")\
    .gsub(/u`/,"\xa9\xee")\
    .gsub(/y'/,"\xa9\xf2")\
    .gsub(/n'/,"\xa8\xf5")\
    .gsub(/r'/,"\xaa\xc8")\
    .gsub(/δ/,"\xa9\xe6")\
    .gsub(/з/,"\xaa\xe9")\
    .gsub(/η/,"\xaa\xfa")\
    .gsub(/∫/,"\xaa\xe8")
    ###.gsub(/θ/,"\xab\xa3")\
    $stdout.puts( f1 + f2 + f3 + f4 + f5 )
  else 
    $stdout.puts( line )
  end
end
