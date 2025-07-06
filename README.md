**scrap**

A simple cli web scrapper in julia to collect links of a given website - code by Antonius (indodev)

install required packages : 

**
import Pkg
Pkg.add("HTTP")
Pkg.add("Gumbo")
**


Usage: julia web_scraper.jl <URL_or_Domain>
    
Example: julia web_scraper.jl http://www.phrack.org/
    
Example: julia web_scraper.jl phrack.org

