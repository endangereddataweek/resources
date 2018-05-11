# Introduction to Data Manipulation in R

**Creator**: Jason A. Heppler, University of Nebraska at Omaha

The slides (data-manipulation-r.html) and interactive worksheet
(data-manipulation-r-worksheet.Rmd) are designed to introduce the basics of
data manipulation in R. 

The slides cover a range of issues about how data is organized, the basics of
tidy data, and an overview of [tidyverse]() packages. The slides are meant to
introduce the concepts that will be completed within the worksheet.

## Dependencies

The following R packages and their dependencies will be required:

- `tidyverse`
- `historydata`
- `rmdshower`

## Digital Ocean setup for R workshops

When teaching this in a workshop, it is recommended to set up RStudio Server
for each of the participants in order to avoid troubleshooting RStudio on
individual machines. The following steps are what is used for setting up
RStudio Server on Digital Ocean droplets.

```
sudo apt-get update
sudo apt-get -y install r-base libapparmor1 gdebi-core libcurl4-openssl-dev libssl-dev libxml2-dev nginx

wget https://download2.rstudio.org/rstudio-server-1.0.136-amd64.deb
sudo gdebi rstudio-server-1.0.136-amd64.deb
sudo adduser <user>
```

Then install the required R packages.

```
install.packages(c('tidyverse, historydata'), repos='http://cran.rstudio.com',
dependencies=TRUE)
```

### Rstudio clean URL

To have a cleaner URL (e.g., `http://123.456.789/rstudio/`) install `nginx`:

```
sudo apt-get update
sudo apt-get -y install nginx
``

Then edit the sites-enabled default file to create a clean URL:

```
$ sudo vim /etc/nginx/sites-enabled/default

default:
server {
  listen 80; 

  location /rstudio/ {
    rewrite ^/rstudio/(.*)$ /$1 break;
    proxy_pass http://localhost:8787;
    proxy_redirect http://localhost:8787/ $scheme://$host/rstudio/;
  }
}

sudo service nginx restart
```

### Add a swap file to manage memory

In order to avoid memory issues with using or installing packages, it is
recommended to install a swap file.

```
cd /var
touch swap.img
chmod 600 swap.img

dd if=/dev/zero of=/var/swap.img bs=1024k count=1000

mkswap /var/swap.img

swapon /var/swap.img

swapoff /var/swap.img
```

Generally, the Digital Ocean droplets are kept online for workshop attendees
for three days following the workshop before they are wiped.
