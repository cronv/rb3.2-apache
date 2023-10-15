[![Docker Hub](https://img.shields.io/docker/pulls/cronv/rb3.2-apache)](https://hub.docker.com/r/cronv/rb3.2-apache)
<i class="fab fa-docker"></i>

## Menu
1.  [Project Installation (RoR)](#project-installation-ror)
2.  [Working with the `cgi` Module in Apache2](#working-with-the-cgi-module-in-apache2)

# Project Installation (RoR)

1. ## Install the Project (RoR)
   Project installation and generation of a controller for the initial page.

   `myapp` - Project name (your own designation)

    ```bash
    cd /var/www/localhost/htdocs/ && \
      rails new myapp && \
      cd myapp && \
      rails generate controller welcome index
    ```

2. ## Route Configuration

   > Allows opening the initial page `GET "/"` as `'welcome#index'`
   In the project folder `myapp`, find `config/routes.rb` and add the following:

    ```rb
    root 'welcome#index'
    ```

3. ## Check File Permissions
   File permission for `config/master.key`

    ```bash
    chmod 644 /var/www/localhost/htdocs/myapp/config/master.key
    ```
4. ## Configure Application Mode

   In the configuration file of the RoR application, find the mode that suits you and configure it, e.g., `myapp/config/environments/production/development`

   ```rb
   # Do not fallback to assets pipeline if a precompiled asset is missed. (default: false)
   config.assets.compile = true
   
   # Disable serving static files from the `/public` folder by default since
   # Apache or NGINX already handles this.
   config.public_file_server.enabled = true
   ```

5. ## Create an Apache2/httpd Virtual Host

   > :warning: myapp.local - Make sure this host is added to /etc/hosts

   Add a file /etc/apache2/conf.d/vhosts.conf

   ```apacheconf
   <VirtualHost *:80>
     ServerName myapp.local
     DocumentRoot /var/www/localhost/htdocs/myapp/public

     # The directive sets the execution environment of your application to "production" mode
     # (Directory: myapp/configs/environments/[test,development,production])
     # PassengerEnabled on
     PassengerAppEnv production

     <Directory /var/www/localhost/htdocs/myapp/public>
         Options Indexes FollowSymLinks MultiViews ExecCGI
         AllowOverride All
         Order allow,deny
         allow from all
         AddHandler cgi-script .cgi
     </Directory>
   </VirtualHost>
   ```

6. ## Precompile Static Resources and Set Mode

   > :information_source: Optional

   ```bash
   rails assets:precompile RAILS_ENV=production
   ```

   After running the command, restart the web server, for example

   ```bash
   httpd -k restart
   ```

# Working with the `cgi` Module in Apache2

1. ## Configure httpd (Apache2) Configuration

   To work with *.rb scripts, uncomment the cgi_module in the file /etc/apache2/httpd.conf:
   ```apacheconf
   <IfModule mpm_prefork_module>
        LoadModule cgi_module modules/mod_cgi.so
   </IfModule>
   ```

2. ## Add Execute Permissions to a File

   ```bash
   chmod +x my_script.rb
   ```
