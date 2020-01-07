library(tidyverse)
library(stringr)
library(magrittr)
library(purrr)

pn <- read.table("http://www.lr.pi.titech.ac.jp/~takamura/pubs/pn_ja.dic", 
           sep = ":", stringsAsFactors = FALSE)
pn2 <- pn %>% select(V1, V4) %>% rename(TERM = V1)
pn2 %<>% distinct(TERM, .keep_all = TRUE)

mafilesList <- list.files("./maAnalysis/", pattern = "^maResult.*$", full.names = TRUE)
mafilesList %>% map_df(read_rds) -> maDF
maDF %<>% left_join(pn2)

maDF$V4 <- replace(maDF$V4, which(is.na(maDF$V4)), 0)
maDF %<>% filter(!is.na(reply_to_status_id))

maDF %>% mutate(Emotion = V4 * Row1) %>% 
  group_by(target, reply_to_status_id, fromuser, status_id) %>%
  summarise(Emotion_Value = sum(Emotion),
            AllCount = sum(Row1),
            Term_Count = sum(Row1[POS1 %in% c("形容詞","助動詞","動詞","副詞","名詞")])) ->maDF2

saveRDS(maDF2, "./outputDF/maResultDF.rds")

