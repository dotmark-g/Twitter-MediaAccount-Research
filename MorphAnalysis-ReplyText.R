library(tidyverse)
library(RMeCab)
library(stringr)
library(magrittr)

#rds読み込み
setwd("C:/Users/Tomoya/Documents/R/mongodbTest")

replytweetCleanedDF <- readRDS("./outputDF/ReplyTweetDF.rds")
replytext <- select(replytweetCleanedDF,
                    created_at, target, reply_to_status_id, fromuser, status_id, text) %>%
  distinct(fromuser, status_id, text, .keep_all = TRUE)

#ASCII削除
replytext$text <- str_replace_all(replytext$text, "\\p{ASCII}", "")

#空白行削除
replytext$text <- iconv(replytext$text, from = "UTF-8", to = "Shift-JIS", sub = "")
replytext %<>% filter(text != "")

#形態素解析
options(warn=-1)
ResultDF <- data.frame()
for (i in 1:nrow(replytext)) {
  tempDF <- replytext[i,]
  suppressWarnings(docDF(tempDF, "text", type = 1) -> tempResultDF)
  
  tempResultDF2 <- data.frame(
    created_at = tempDF$created_at,
    target = tempDF$target,
    reply_to_status_id = tempDF$reply_to_status_id,
    fromuser = tempDF$fromuser,
    status_id = tempDF$status_id,
    tempResultDF
  )
    ResultDF <- rbind(ResultDF, tempResultDF2)

  if (i %% 1000 == 0) {
    print(paste0("Now ", i, " Ended."))
    q <- paste0("./maAnalysis/maResult-", i, ".rds")
    saveRDS(ResultDF, q)
    ResultDF <- data.frame()
  }
  if (i == nrow(replytext)) {
    print(paste0("Now ", i, " Ended."))
    q <- paste0("./maAnalysis/maResult-", i, ".rds")
    saveRDS(ResultDF, q)
  }  
}

print("Scraping Ended!")


