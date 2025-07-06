# Import necessary packages.
# HTTP.jl is used for making HTTP requests (fetching web pages).
# Gumbo.jl is used for parsing HTML documents.
using HTTP
using Gumbo


function extract_links_from_node!(links::Vector{String}, node::HTMLNode)
    if isa(node, HTMLElement)
        if tag(node) == :a
            # Check if the 'href' attribute exists
            if haskey(attrs(node), "href")
                link = attrs(node)["href"]
                # Add the link to our list if it's not empty
                if !isempty(link)
                    push!(links, link)
                end
            end
        end

        for child in children(node)
            extract_links_from_node!(links, child)
        end
    end
end

function scrape_links(url::String)
    println("Attempting to scrape: $url")
    links = String[] # Initialize an empty array to store the found links

    try
        response = HTTP.get(url, readtimeout=10) # Set a timeout for the request
        html_content = String(response.body)
        println("Successfully fetched content from $url")

        doc = parsehtml(html_content)

        extract_links_from_node!(links, doc.root)

        unique_links = unique(links)
        println("Found $(length(unique_links)) unique links.")
        return unique_links

    catch e
        if isa(e, HTTP.Exceptions.ConnectError)
            println("Error: Could not connect to $url. Check URL or network connection.")
        elseif isa(e, HTTP.Exceptions.StatusError)
            println("Error: HTTP status error for $url. Status code: $(e.status)")
        else
            println("An unexpected error occurred while scraping $url: $e")
        end
        return String[] # Return an empty array on error
    end
end

function info()
    println("\n\tsimple web scrapper in julia - code by Anton (www.indodev.asia)
    \n\tUsage: julia scrap.jl <URL_or_Domain>
    \n\tExample: julia scrap.jl http://www.phrack.org/
    \n\tExample: julia scrap.jl phrack.org
    \n");
end

if length(ARGS) == 0
    info()
    exit(1) # Exit with an error code
end

input_arg = ARGS[1]
target_url = ""

if startswith(input_arg, "http://") || startswith(input_arg, "https://")
    target_url = input_arg
else
    target_url = "https://" * input_arg
    println("No URL scheme detected. Prepending 'https://'. Target URL: $target_url")
end

found_links = scrape_links(target_url)

if !isempty(found_links)
    println("\n--- Links found on $target_url ---")
    for link in found_links
        println(link)
    end
else
    println("\nNo links found or an error occurred.")
end

