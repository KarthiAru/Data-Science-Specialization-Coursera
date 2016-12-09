# function to parse the string and clean

word_count <- function(string) length(strsplit(unlist(string),' ')[[1]])

parse <- function (corpus){
    corpus <- corpus %>%
        # replace diacritic/accent characters
        stri_trans_general("Latin-ASCII") %>%
        iconv(to="ASCII", sub="") %>%
        # remove leading/trailing/extraneou space
        stri_replace_all(regex = "^ +|(?<= ) +| +$", replacement = "") %>%
        # expand contractions
        # stri_replace_all(regex = "\\by'all\\b", replacement = "you all") %>%
        # stri_replace_all(regex = "\\bY'all\\b", replacement = "You all") %>%
        # stri_replace_all(regex = "\\bcan't\\b", replacement = "can not") %>%
        # stri_replace_all(regex = "\\bCan't\\b", replacement = "Can not") %>%
        # stri_replace_all(regex = "\\bain't\\b", replacement = "is not") %>%
        # stri_replace_all(regex = "\\bAin't\\b", replacement = "Is not") %>%
        # stri_replace_all(regex = "\\bwon't\\b", replacement = "would not") %>%
        # stri_replace_all(regex = "\\bWon't\\b", replacement = "Would not") %>%
        # stri_replace_all(regex = "n't\\b", replacement = " not") %>%
        # stri_replace_all(regex = "'ve\\b", replacement = " have") %>%
        # stri_replace_all(regex = "'re\\b", replacement = " are") %>%
        # stri_replace_all(regex = "'ll\\b", replacement = " will") %>%
        # stri_replace_all(regex = "'d\\b", replacement = " would") %>%
        # stri_replace_all(regex = "\\b(i'm|im)\\b", replacement = "i am") %>%
        # stri_replace_all(regex = "\\b(I'm|Im)\\b", replacement = "I am") %>%
        # stri_replace_all(regex = "\\b(it)'s\\b", replacement = "$1 is") %>%
        # stri_replace_all(regex = "\\b(It)'s\\b", replacement = "$1 is") %>%
        # stri_replace_all(regex = "\\b(he|she|how|that|there|what|when|who|why|where)'?s\\b", replacement = "$1 is") %>%
        # stri_replace_all(regex = "\\b(He|She|How|That|There|What|When|Who|Why|Where)'?s\\b", replacement = "$1 is") %>%
        # stri_replace_all(regex = "\\bu\\b", replacement = "you") %>%
        # stri_replace_all(regex = "\\bur\\b", replacement = "your") %>%
        # find and replace date
        stri_replace_all(regex = "\\b((\\d{4}|\\d{1,2})[-\\.\\/]\\d{1,2}[-\\.\\/](\\d{4}|\\d{1,2}))\\b", replacement = " _DATE_ ") %>%
        stri_replace_all(regex = "\\b((\\w*(M|m)+(O|o)+(N|n)+\\w*|\\w*(T|t)+(U|u)+(E|e)+\\w*|\\w*w+(E|e)+d+\\w*|\\w*(T|t)+h+(U|u)+\\w*|\\w*(F|f)+(R|r)+(I|i)+\\w*|\\w*(S|s)+(A|a)+(T|t)+\\w*|\\w*(S|s)+(U|u)+(N|n)+\\w*|)?[,]?\\s?(\\d{1,2}[-\\.])?\\s?(\\w*(J|j)+(A|a)+(N|n)+\\w*|\\w*(F|f)+(E|e)+(B|b)+\\w*|\\w*(M|m)+(A|a)+(R|r)+\\w*|\\w*(A|a)+(P|p)+(R|r)+\\w*|\\w*(M|m)+(A|a)+(Y|y)+\\w*|\\w*(J|j)+(U|u)+(N|n)+\\w*|\\w*(J|j)+(U|u)+(L|l)+\\w*|\\w*(A|a)+(U|u)+(G|g)+\\w*|\\w*(S|s)+(E|e)+(P|p)+\\w*|\\w*(O|o)+(C|c)+(T|t)+\\w*|\\w*(N|n)+(O|o)+(V|v)+\\w*|\\w*(D|d)+(E|e)+(C|c)+\\w*)[-,\\.]?\\s(\\d{1,4})[-,\\.]?\\s?(\\d{2,4})?)\\b", replacement = " _DATE_ ") %>%
        # find and replace time
        stri_replace_all(regex ="\\b\\d{1,2}\\s?[\\:\\.]\\s?\\d{1,2}\\s?([\\:\\.]\\s?\\d{2})?\\s?([AaPp][\\.]?[Mm][\\.]?)?\\b", replacement =" _TIME_ ") %>%
        stri_replace_all(regex ="\\b\\d{1,2}[AaPp][\\.]?[Mm][\\.]?\\b", replacement =" _TIME_ ") %>%
        # find and replace phone
        stri_replace_all(regex ="([\\+]?\\d{1,3})?[-\\.]?\\s?[\\(]?(\\d{3})[\\)]?[-\\.\\s]?(\\d{3})[-\\.]?\\s?(\\d{4})(\\s?(x\\d{4})?)", replacement= " _PHONE_ ") %>%
        # find and replace geo-coordinates
        # stri_replace_all(regex = "^[-+]?(90((\\.0{1,6})?)|([0-9]|[1-8][0-9])((\\.[0-9]{4,6})?)),\\s*[-+]?(180((\\.0{1,6})?)|([0-9]|[1-9][0-9]|1[0-7][0-9])((\\.[0-9]{4,6})?))$", replacement =" _LATLONG_ ") %>%
        # find and replace email
        stri_replace_all(regex = "([\\w_.-]+)@([\\w.-]+)\\.([\\w.]{2,6})", replacement = " _EMAIL_ ") %>%
        # find and replace url
        stri_replace_all(regex ="(http[s]?|://|www)(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+", replacement = " _URL_ ") %>%
        # find and replace twitter handle and hashtag
        stri_replace_all(regex ="\\bRT\\b", replacement = " ") %>%
        stri_replace_all(regex =" @+\\w+[^\\w]", replacement = " ") %>%
        # stri_replace_all(regex =" #+\\w+[^\\w]", replacement = " _TWHASHTAG_ ") %>%
        # find and replace emoticon
        # stri_replace_all(regex = "[<>0O%]?[:;=8]([-o*']+)?[()dbp/ocs]+ | [()dbp/}{#|c]+([-o*']+)?[:;=8][<>]?|<+3+|<+/+3+|[-o0><^][_.]+[-o0><^]|([<>0O%]?[:;=8]([-o*']+)?[()dbp/ocs]+|[()dbp/}{#|c]+([-o*']+)?[:;=8][<>]?|<+3+|<+/+3+|[-o0><^][_.]+[-o0><^])$", replacement = " _EMOTICON_ ") %>%
        # find and remove apostrophes not occuring in between words
        stri_replace_all(regex = "\\s*'\\B|\\B'\\s*", replacement = "") %>%
        # remove repeated EOL and other punctuation marks
        stri_replace_all(regex = "&+", replacement = " and ") %>%
        stri_replace_all(regex = "(?<=[!/,-.:;#?])[!/,-.:;#?]+|<+[^a-zA-Z0-9]", replacement = " ") %>%
        stri_replace_all(regex = "(\\s?[,]\\s?)+", replacement = " , ")  %>%
        stri_replace_all(regex = "(\\s?[-]\\s?)+", replacement = " - ")  %>%
        # remove profanity
        stri_replace_all(regex = "\\b((A|a|4)+(R|r)+(S|s|5)+(E|e|3)+|(A|a|4)+(R|r)+(S|s|5)+(E|e|3)+\\s?(H|h)+(O|o|0)+l+(E|e|3)+\\w*|(A|a|4)+(S|s|5)+(S|s|5)+|(A|a|4)+(S|s|5)+(S|s|5)+\\s?(B|b)+(A|a|4)+(N|n)+(G|g)+\\w*|(A|a|4)+(S|s|5)+(S|s|5)+(E|e|3)+(S|s|5)+|(A|a|4)+(S|s|5)+(S|s|5)+\\s?(H|h)+(O|o|0)+(L|l|1|\\!)+(E|e|3)+\\w*|\\w*(B|b)+(I|i|L|l|1|\\!)+(T|t|\\+)+(C|c|K|k|X|x)+(H|h)+\\w*|\\w*(B|b)+(A|a|4)+(S|s|5)+(T|t|\\+)+(A|a|4)+(R|r)+(D|d)+\\w*|\\w*(B|b)+(D|d)+(S|s|5)+(M|m)+\\w*|\\w*(B|b)+(L|l|1|\\!)+(O|o|0)+(W|w)+\\s?(J|j)+(O|o|0)+(B|b)+\\w*|\\w*(B|b)+(O|o|0)+(N|n)+(D|d)+(A|a|4)+(G|g)+(E|e|3)+\\w*|\\w*(B|b)+(O|o|0)+(N|n)+(E|e|3)+(R|r|D|d)+\\w*|\\w*(B|b)+(O|o|0)+(O|o|0)+(T|t|\\+)+(Y|y|I|i|E|e)+\\w*|\\w*(B|b)+(R|r)+(E|e|3)+(A|a|4)+(S|s|5)+(T|t|\\+)+\\w*|\\w*(B|b)+(O|o|0)+(O|o|0)+(B|b)+\\w*|\\w*(B|b)+(U|u)+(G|g)+(G|g)+(E|e|3)+(R|r)+\\w*|\\w*(B|b)+(U|u)+(T|t|\\+)+(T|t|\\+)+\\w*|\\w*(C|c|K|k|X|x)+(I|i|L|l|1|\\!)+(I|i|L|l|1|\\!)+(T|t|\\+)+\\w*|\\w*(C|c|K|k|X|x)+(O|o|0)+(C|c|K|k|X|x)+(K|k)+\\w*|\\w*(C|c|K|k|X|x)+(U|u)+(M|m)+\\s?(S|s|5)+(H|h)+(O|o|0)+(T|t|\\+)+\\w*|\\w*(C|c|K|k|X|x)+(U|u)+(M|m)+(M|m)+(I|i|L|l|1|\\!)+(N|n)+(G|g)+\\w*|\\w*(C|c|K|k|X|x)+(U|u)+(M|m)+(S|s|5)+\\w*|\\w*(C|c|K|k|X|x)+(U|u)+(M|m)+(M|m)+(I|i|L|l|1|\\!)+(N|n)+\\w*|\\w*(C|c|K|k|X|x)+(O|o|0)+(N|n)+(D|d)+(O|o|0)+(M|m)+\\w*|\\w*(C|c|K|k|X|x)+(R|r)+(E|e|3)+(A|a|4)+(M|m)+(P|p)+(I|i|L|l|1|\\!)+(E|e|3)+\\w*|\\w*(C|c|K|k|X|x)+(U|u)+(M|m)+|\\w*(C|c|K|k|X|x)+(U|u)+(N|n)+(T|t|\\+)+\\w*|\\w*(D|d)+(I|i|L|l|1|\\!)+(C|c|K|k|X|x)+(K|k)+\\w*|\\w*(D|d)+(E|e|3)+(e|3)+(P|p)+\\s?(T|t)+(H|h)+(R|r)+(O|o|0)+(A|a|4)+(T|t|\\+)+\\w*|\\w*(D|d)+(I|i|L|l|1|\\!)+(I|i|L|l|1|\\!)+(D|d)+(O|o|0)+\\w*|\\w*(D|d)+(O|o|0)+(G|g)+(G|g)+(Y|y|I|i|E|e)+\\s?(S|s|5)+(T|t|\\+)+(Y|y)+(L|l|1|\\!)+(E|e|3)+|\\w*(D|d)+(O|o|0)+(U|u)+(B|b)+(L|l|1|\\!)+(E|e|3)+\\s?(P|p)+(E|e|3)+(N|n)+(E|e|3)+(T|t|\\+)+(R|r)+(A|a|4)+(T|t|\\+)+(I|i|L|l|1|\\!)+(O|o|0)+(N|n)+\\w*|\\w*(e|3)+(J|j)+(A|a|4)+(C|c|K|k|X|x)+(U|u)+(L|l|1|\\!)+(A|a|4)+(T|t|\\+)+\\w*|\\w*(e|3)+(R|r)+(E|e|3)+(C|c|K|k|X|x)+(T|t|\\+)+(I|i|L|l|1|\\!)+(O|o|0)+(N|n)+\\w*|\\w*(F|f)+(A|a|4)+(G|g)+(G|g)+(O|o|0)+(T|t|\\+)+\\w*|\\w*(F|f)+(C|c|K|k|X|x)+(U|u)+(K|k)+\\w*|\\w*(F|f)+(I|i|L|l|1|\\!)+(N|n)+(G|g)+(E|e|3)+(R|r)+\\s?(B|b)+(A|a|4)+(N|n)+(G|g)+\\w*|\\w*(F|f)+(I|i|L|l|1|\\!)+(N|n)+(G|g)+(E|e|3)+(R|r)+(I|i|L|l|1|\\!)+(N|n)+\\w*|\\w*(F|f)+(U|u)+(C|c|K|k|X|x)+(K|k)+\\w*|\\w*(G|g)+(A|a|4)+(N|n)+(G|g)+\\s?(B|b)+(A|a|4)+(N|n)+(G|g)+\\w*|\\w*(H|h)+(A|a|4)+(R|r)+(D|d)+\\s?(C|c)+(O|o|0)+(R|r)+(E|e|3)+\\w*|\\w*(M|m)+(A|a|4)+(S|s|5)+(T|t|\\+)+(e|u)+(R|r)+(B|b)+(A|a|4)+(T|t|\\+)+\\w*|\\w*(M|m)+(I|i|L|l|1|\\!)+(L|l|1|\\!)+(F|f)+\\w*|\\w*(N|n)+(I|i|L|l|1|\\!)+(G|g)+(G|g)+(A|a|4)+\\w*|\\w*(N|n)+(I|i|L|l|1|\\!)+(G|g)+(G|g)+(E|e|3)+(R|r)+\\w*|\\w*(N|n)+(I|i|L|l|1|\\!)+(P|p)+(P|p)+(L|l|1|\\!)+(E|e|3)+\\w*|\\w*(o|0)+(R|r)+(G|g)+(A|a|4)+(S|s|5)+(M|m)+\\w*|\\w*(o|0)+(R|r)+(G|g)+(Y|y|I|i|E|e)+|\\w*(P|p)+(E|e|3)+(N|n)+(I|i|L|l|1|\\!)+(S|s|5)+\\w*|\\w*(P|p)+(I|i|L|l|1|\\!)+(S|s|5)+(S|s|5)+\\w*|\\w*(P|p)+(U|u)+(S|s|5)+(S|s|5)+(Y|y|I|i|E|e)+\\w*|\\w*(S|s|5)+(E|e|3)+(M|m)+(E|e|3)+(N|n)+\\w*|\\w*(S|s|5)+(H|h)+(I|i|L|l|1|\\!)+(T|t|\\+)+\\w*|\\w*(S|s|5)+(L|l|1|\\!)+(U|u)+(T|t|\\+)+\\w*|\\w*(S|s|5)+(P|p)+(E|e|3)+(R|r)+(M|m)+\\w*|\\w*(S|s|5)+(Q|q)+(U|u)+(I|i|L|l|1|\\!)+(R|r)+(T|t|\\+)+\\w*|\\w*(S|s|5)+(U|u)+(C|c|K|k|X|x)+(K|k)+\\w*|\\w*(T|t|\\+)+(I|i|L|l|1|\\!)+(T|t|\\+)+|\\w*(T|t|\\+)+(I|i|L|l|1|\\!)+(T|t|\\+)+(T|t|\\+)+(Y|y|I|i|E|e)+\\w*|\\w*(T|t|\\+)+(I|i|L|l|1|\\!)+(T|t|\\+)+(S|s|5)\\w*|\\w*(T|t|\\+)+(W|w)+(A|a|4)+(T|t|\\+)+\\w*|\\w*(V|v)+(A|a|4)+(G|g)+(I|i|L|l|1|\\!)+(N|n)+(A|a|4)+\\w*|\\w*(V|v)+(I|i|L|l|1|\\!)+(A|a|4)+(G|g)+(R|r)+(A|a|4)+\\w*|\\w*(W|w)+(H|h)+(O|o|0)+(R|r)+(E|e|3)+\\w*|\\w*(W|w)+(T|t|\\+)+(F|f)+\\w*)\\b", replacement = " _VULGAR_ ") %>%
        # find and replace number
        stri_replace_all(regex = "^,+|(?<=\\d),+|,+$", replacement = "") %>%
        stri_replace_all(regex ="[\\d]+([-,.\\d]+)?\\s?(th|st|nd|rd)?", replacement= " _NUM_ ") %>%
        
        # placeholders for ',' and '-'
        stri_replace_all(fixed=",", replacement = " _COMMA_ ") %>%
        stri_replace_all(fixed="-", replacement = " _HYPHEN_ ") %>%
        
        # break lines into sentences
        #stri_split(regex = "\\s*?[!?;:.]+\\s*", omit_empty=T) %>%
        stri_split(regex = "(?<!\\w\\.\\w.)(?<![A-Z][a-z]\\.)(?<=[!?.])\\s", omit_empty=T) %>%
        unlist() %>%
        stri_replace_all(fixed=".", replacement = "")
        # mark the start and end of a sentence
        # corpus <- paste("_START_",corpus,"_END_")
        corpus <- corpus %>%
        # remove all left over symbols
        stri_replace_all(regex = "[^ a-zA-Z0-9'_]+", replacement = " ") %>%
        # remove leading/trailing/extraneou space
        stri_replace_all(regex = "^ +|(?<= ) +| +$", replacement = "") %>%
        # split up by word
        #lapply(function (i) stri_split_boundaries(i, type="word", skip_word_none=TRUE)) %>% 
        # remove unnecessary list format
        #unlist(recursive = F)
        stri_replace_all(fixed="_COMMA_", replacement = ",")  %>%
        stri_replace_all(fixed="_HYPHEN_", replacement = "-")
    # drop sentences with less than 5 words
        corpus <- corpus[unlist(lapply(corpus, function(x) word_count(x)>=5))]
    return(corpus)
}