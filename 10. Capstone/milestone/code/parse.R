# function to parse the string and clean
parse <- function (corpus){
    corpus <- tolower(corpus) %>%
        # replace diacritic/accent characters
        stri_trans_general("Latin-ASCII") %>%
        iconv(to="ASCII", sub="") %>%
        # expand contractions
        stri_replace_all(regex = "\\bcan't\\b", replacement = "can not") %>%
        stri_replace_all(regex = "\\bain't\\b", replacement = "is not") %>%
        stri_replace_all(regex = "\\bwon't\\b", replacement = "would not") %>%
        stri_replace_all(regex = "n't\\b", replacement = " not") %>%
        stri_replace_all(regex = "'ve\\b", replacement = " have") %>%
        stri_replace_all(regex = "'re\\b", replacement = " are") %>%
        stri_replace_all(regex = "'ll\\b", replacement = " will") %>%
        stri_replace_all(regex = "'d\\b", replacement = " would") %>%
        stri_replace_all(regex = "\\b(i'm|im)\\b", replacement = "i am") %>%
        stri_replace_all(regex = "\\b(he|she|it|how|that|there|what|when|who|why|where)'?s\\b", replacement = "$1 is") %>%
        stri_replace_all(regex = "\\bu\\b", replacement = "you") %>%
        stri_replace_all(regex = "\\bur\\b", replacement = "your") %>%
        # find and replace date
        stri_replace_all(regex = "\\b((\\d{4}|\\d{1,2})[-\\.\\/]\\d{1,2}[-\\.\\/](\\d{4}|\\d{1,2}))\\b", replacement = " <DATE> ") %>%
        stri_replace_all(regex = "\\b((\\w*m+o+n+\\w*|\\w*t+u+e+\\w*|\\w*w+e+d+\\w*|\\w*t+h+u+\\w*|\\w*f+r+i+\\w*|\\w*s+a+t+\\w*|\\w*s+u+n+\\w*|)?[,]?\\s?(\\d{1,2}[-\\.])?\\s?(\\w*j+a+n+\\w*|\\w*f+e+b+\\w*|\\w*m+a+r+\\w*|\\w*a+p+r+\\w*|\\w*m+a+y+\\w*|\\w*j+u+n+\\w*|\\w*j+u+l+\\w*|\\w*a+u+g+\\w*|\\w*s+e+p+\\w*|\\w*o+c+t+\\w*|\\w*n+o+v+\\w*|\\w*d+e+c+\\w*)[-,\\.]?\\s(\\d{1,4})[-,\\.]?\\s?(\\d{2,4})?)\\b", replacement = " <DATE> ") %>%
        # find and replace time
        stri_replace_all(regex ="\\b\\d{1,2}\\s?[\\:\\.]\\s?\\d{1,2}\\s?([\\:\\.]\\s?\\d{2})?\\s?([ap][\\.]?[m][\\.]?)?\\b", replacement =" <TIME> ") %>%
        stri_replace_all(regex ="\\b\\d{1,2}[ap][\\.]?[m][\\.]?\\b", replacement =" <TIME> ") %>%
        # find and replace phone
        stri_replace_all(regex ="([\\+]?\\d{1,3})?[-\\.]?\\s?[\\(]?(\\d{3})[\\)]?[-\\.\\s]?(\\d{3})[-\\.]?\\s?(\\d{4})(\\s?(x\\d{4})?)", replacement= " <PHONE> ") %>%
        # find and replace geo-coordinates
        # stri_replace_all(regex = "^[-+]?(90((\\.0{1,6})?)|([0-9]|[1-8][0-9])((\\.[0-9]{4,6})?)),\\s*[-+]?(180((\\.0{1,6})?)|([0-9]|[1-9][0-9]|1[0-7][0-9])((\\.[0-9]{4,6})?))$", replacement =" <LATLONG> ") %>%
        # find and replace email
        stri_replace_all(regex = "([\\w_.-]+)@([\\w.-]+)\\.([\\w.]{2,6})", replacement = " <EMAIL> ") %>%
        # find and replace url
        stri_replace_all(regex ="(http[s]?|://|www)(?:[a-z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-f][0-9a-f]))+", replacement = " <URL> ") %>%
        # find and replace twitter handle and hashtag
        # stri_replace_all(regex =" @+\\w+[^\\w]", replacement = " <TWHANDLE> ") %>%
        # stri_replace_all(regex =" #+\\w+[^\\w]", replacement = " <TWHASHTAG> ") %>%
        # find and replace emoticon
        # stri_replace_all(regex = "[<>0O%]?[:;=8]([-o*']+)?[()dbp/ocs]+ | [()dbp/}{#|c]+([-o*']+)?[:;=8][<>]?|<+3+|<+/+3+|[-o0><^][_.]+[-o0><^]|([<>0O%]?[:;=8]([-o*']+)?[()dbp/ocs]+|[()dbp/}{#|c]+([-o*']+)?[:;=8][<>]?|<+3+|<+/+3+|[-o0><^][_.]+[-o0><^])$", replacement = " <EMOTICON> ") %>%
        # find and remove apostrophes not occuring in between words
        stri_replace_all(regex = "\\s*'\\B|\\B'\\s*", replacement = "") %>%
        # remove repeated EOL and other punctuation marks
        stri_replace_all(regex = "&+", replacement = " and ") %>%
        stri_replace_all(regex = "(?<=[!/,.:;?#])[!,.:;#?]+|<+[^a-zA-Z0-9]", replacement = "") %>%
        
        # remove profanity
        stri_replace_all(regex = "\\b(\\w*(a|4)+r+(s|5)+(e|3)+|\\w*(a|4)+r+(s|5)+(e|3)+\\s?h+(o|0)+l+(e|3)+\\w*|\\w*(a|4)+(s|5)+(s|5)+|\\w*(a|4)+(s|5)+(s|5)+\\s?b+(a|4)+n+g+\\w*|\\w*(a|4)+(s|5)+s+(e|3)+(s|5)+\\w*|\\w*(a|4)+(s|5)+(s|5)+\\s?h+(o|0)+(l|1|\\!)+(e|3)+\\w*|\\w*b+(i|l|1|\\!)+(t|\\+)+(c|k|x)+h+\\w*|\\w*b+(a|4)+(s|5)+(t|\\+)+(a|4)+r+d+\\w*|\\w*b+d+(s|5)+m+\\w*|\\w*b+(l|1|\\!)+(o|0)+w+\\s?j+(o|0)+b+\\w*|\\w*b+(o|0)+n+d+(a|4)+g+(e|3)+\\w*|\\w*b+(o|0)+n+(e|3)+(r|d)+\\w*|\\w*b+(o|0)+(o|0)+(t|\\+)+(y|i|e)+\\w*|\\w*b+r+(e|3)+(a|4)+(s|5)+(t|\\+)+\\w*|\\w*b+(o|0)+(o|0)+b+\\w*|\\w*b+u+g+g+(e|3)+r+\\w*|\\w*b+u+(t|\\+)+(t|\\+)+\\w*|\\w*(c|k|x)+(i|l|1|\\!)+(i|l|1|\\!)+(t|\\+)+\\w*|\\w*(c|k|x)+(o|0)+(c|k|x)+k+\\w*|\\w*(c|k|x)+u+m+\\s?(s|5)+h+(o|0)+(t|\\+)+\\w*|\\w*(c|k|x)+u+m+m+(i|l|1|\\!)+n+g+\\w*|\\w*(c|k|x)+u+m+(s|5)+\\w*|\\w*(c|k|x)+u+m+m+(i|l|1|\\!)+n+\\w*|\\w*(c|k|x)+(o|0)+n+d+(o|0)+m+\\w*|\\w*(c|k|x)+r+(e|3)+(a|4)+m+p+(i|l|1|\\!)+(e|3)+\\w*|\\w*(c|k|x)+u+m+|\\w*(c|k|x)+u+n+(t|\\+)+\\w*|\\w*d+(i|l|1|\\!)+(c|k|x)+k+\\w*|\\w*d+(e|3)+(e|3)+p+\\s?t+h+r+(o|0)+(a|4)+(t|\\+)+\\w*|\\w*d+(i|l|1|\\!)+(i|l|1|\\!)+d+(o|0)+\\w*|\\w*d+(o|0)+g+g+(y|i|e)+\\s?(s|5)+(t|\\+)+y+(l|1|\\!)+(e|3)+|\\w*d+(o|0)+u+b+(l|1|\\!)+(e|3)+\\s?p+(e|3)+n+(e|3)+(t|\\+)+r+(a|4)+(t|\\+)+(i|l|1|\\!)+(o|0)+n+\\w*|\\w*(e|3)+j+(a|4)+(c|k|x)+u+(l|1|\\!)+(a|4)+(t|\\+)+\\w*|\\w*(e|3)+r+(e|3)+(c|k|x)+(t|\\+)+(i|l|1|\\!)+(o|0)+n+\\w*|\\w*f+(a|4)+g+g+(o|0)+(t|\\+)+\\w*|\\w*f+(c|k|x)+u+k+\\w*|\\w*f+(i|l|1|\\!)+n+g+(e|3)+r+\\s?b+(a|4)+n+g+\\w*|\\w*f+(i|l|1|\\!)+n+g+(e|3)+r+(i|l|1|\\!)+n+\\w*|\\w*f+u+(c|k|x)+k+\\w*|\\w*g+(a|4)+n+g+\\s?b+(a|4)+n+g+\\w*|\\w*h+(a|4)+r+d+\\s?c+(o|0)+r+(e|3)+\\w*|\\w*m+(a|4)+(s|5)+(t|\\+)+(e|u)+r+b+(a|4)+(t|\\+)+\\w*|\\w*m+(i|l|1|\\!)+(l|1|\\!)+f+\\w*|\\w*n+(i|l|1|\\!)+g+g+(a|4)+\\w*|\\w*n+(i|l|1|\\!)+g+g+(e|3)+r+\\w*|\\w*n+(i|l|1|\\!)+p+p+(l|1|\\!)+(e|3)+\\w*|\\w*(o|0)+r+g+(a|4)+(s|5)+m+\\w*|\\w*(o|0)+r+g+(y|i|e)+|\\w*p+(e|3)+n+(i|l|1|\\!)+(s|5)+\\w*|\\w*p+(i|l|1|\\!)+(s|5)+(s|5)+\\w*|\\w*p+u+(s|5)+(s|5)+(y|i|e)+\\w*|\\w*(s|5)+(e|3)+m+(e|3)+n+\\w*|\\w*(s|5)+h+(i|l|1|\\!)+(t|\\+)+\\w*|\\w*(s|5)+(l|1|\\!)+u+(t|\\+)+\\w*|\\w*(s|5)+p+(e|3)+r+m+\\w*|\\w*(s|5)+q+u+(i|l|1|\\!)+r+(t|\\+)+\\w*|\\w*(s|5)+u+(c|k|x)+k+\\w*|\\w*(t|\\+)+(i|l|1|\\!)+(t|\\+)+|\\w*(t|\\+)+(i|l|1|\\!)+(t|\\+)+(t|\\+)+(y|i|e)+\\w*|\\w*(t|\\+)+(i|l|1|\\!)+(t|\\+)+(s|5)\\w*|\\w*(t|\\+)+w+(a|4)+(t|\\+)+\\w*|\\w*v+(a|4)+g+(i|l|1|\\!)+n+(a|4)+\\w*|\\w*v+(i|l|1|\\!)+(a|4)+g+r+(a|4)+\\w*|\\w*w+h+(o|0)+r+(e|3)+\\w*|\\w*w+(t|\\+)+f+\\w*)\\b", replacement = " ") %>%
        
        # find and replace number
        stri_replace_all(regex ="[\\d]+([-,.\\d]+)?\\s?(th|st|nd|rd)?", replacement= " <NUM> ") %>%
        
        # break lines into sentences
        stri_split(regex = "\\s*?[!?;:.]+\\s*", omit_empty=T) %>%
        unlist() %>%
        # remove all left over symbols
        stri_replace_all(regex = "[^ a-zA-Z0-9<>']+", replacement = " ") %>%
        # remove leading/trailing/extraneou space
        stri_replace_all(regex = "^ +|(?<= ) +| +$", replacement = "")
    return(corpus)
}