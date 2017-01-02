import Control.Exception (SomeException, try)
import System.Console.CmdArgs (cmdArgs)
import Data.Either (either)
import ParseArgs (R34(..), r34)
import MainDriver (askURL, getDir, openURL, noImagesExist, desiredSection,
                   getPageNum, getPageNum, allURLs, takeNLinks, getLinks,
                   niceDownload)
import Utilities (noInternet, noImages)
import Find (find)

main :: IO ()
main = do
    args <- cmdArgs r34
    if null $ search args
    then do
        url <- askURL (tag args)
        dir <- getDir (directory args)
        firstpage <- try $ openURL url :: IO (Either SomeException String)
        case firstpage of
            Left _ -> putStrLn noInternet
            Right val -> if noImagesExist val
                            then putStrLn $ noImages url
                            else do
                let lastpage = desiredSection start end getPageNum val
                    urls = allURLs url lastpage
                    start = "<section id='paginator'>"
                    end = "</section"
                links <- takeNLinks args <$> getLinks urls putStr
                niceDownload dir links putStr
    else do
        eitherResult <- find (search args)
        either putStrLn (mapM_ putStrLn) eitherResult
