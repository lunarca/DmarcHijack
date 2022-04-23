# DmarcHijack

Find domains vulnerable to From/MailFrom confusion. This can lead to email spoofing.

## Usage

First, install Elixir using the methods described [here](https://elixir-lang.org/install.html). 

Next. run `mix deps.get` to fetch the dependencies.

Finally, run the program in either single-domain or list mode

### Single-domain
Single-domain mode checks a single domain for vulnerable DMARC configurations

```
$ mix single [domain]
```

### List Mode
List mode checks a list of domains for vulnerable DMARC configurations. Domains should be one per line.

```
$ mix list [path_to_domains.txt]
```

If you want to check the Alexa top 1M domains, the raw dataset can be found here:

[Alexa 1M Dataset](http://s3.amazonaws.com/alexa-static/top-1m.csv.zip)

Since it's available as a CSV of subdomains, it needs to be processed before it's used.

First, install [Unfurl](https://github.com/tomnomnom/unfurl) to parse out root domains.

Then, run the following command to get just the domains in the proper format:

```bash
$ cat top-1m.csv | cut -d "," -f2 | unfurl --unique format %r.%t | sort -u > top-1m-domains.txt
```

Finally, run the following command:

```
$ mix list [path_to_top-1m-domains.txt]
```

This will take a _very_ long time so be ready. Eventually, it will spit out a file named `all-results.txt` with the full DMARC results for all domains checked. You can grep the file for domains with a policy of `none`.


